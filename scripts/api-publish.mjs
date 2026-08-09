#!/usr/bin/env node
// 通过 REST API 完成：建仓库 → 上传全部文件 → 触发 Actions 编译 → 轮询 → 下载 ipa
// 用法: node scripts/api-publish.mjs <GITHUB_PAT> [repoName]
// 全程走 api.github.com（github.com 域被网络卡死时也能用）

import { readdirSync, readFileSync, statSync, mkdirSync, writeFileSync } from 'node:fs'
import { resolve, dirname, join, relative } from 'node:path'
import { fileURLToPath } from 'node:url'

const here = dirname(fileURLToPath(import.meta.url))
const root = resolve(here, '..')

const PAT = process.argv[2]
const REPO_NAME = process.argv[3] || 'embers-ios'
if (!PAT) {
  console.error('用法: node scripts/api-publish.mjs <GITHUB_PAT> [repoName]')
  process.exit(1)
}

const BASE = 'https://api.github.com'
const H = {
  Authorization: `Bearer ${PAT}`,
  Accept: 'application/vnd.github+json',
  'User-Agent': 'embers-publish-script',
  'Content-Type': 'application/json',
}
const outDir = resolve(root, '..', '..') // 桌面
const outFile = join(root, '..', 'api-publish.out.txt') // 进程间传递结果

async function jfetch(url, opts = {}, retries = 3) {
  for (let i = 0; i < retries; i++) {
    try {
      const res = await fetch(url, { ...opts, headers: H })
      if (res.status === 204 || res.status === 202) return {}
      const text = await res.text()
      if (res.status >= 400) {
        throw new Error(`HTTP ${res.status}: ${text.slice(0, 300)}`)
      }
      try { return JSON.parse(text) } catch { return text }
    } catch (e) {
      if (i === retries - 1) throw e
      await sleep(3000 * (i + 1))
    }
  }
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms))

function collectFiles(dir, list = []) {
  for (const name of readdirSync(dir)) {
    const full = join(dir, name)
    if (statSync(full).isDirectory()) {
      if (!['.git', 'build', 'node_modules', '.next'].includes(name)) collectFiles(full, list)
    } else {
      list.push(full)
    }
  }
  return list
}

const IGNORE = new Set(['scripts/api-publish.example.mjs'])

async function main() {
  console.log(`1/6 检查仓库 ${REPO_NAME} ...`)
  let repo
  try {
    repo = await jfetch(`${BASE}/repos/${(await jfetch(`${BASE}/user`)).login}/${REPO_NAME}`)
  } catch (e) {
    console.log('   仓库不存在，创建中 ...')
    const me = await jfetch(`${BASE}/user`)
    repo = await jfetch(`${BASE}/user/repos`, {
      method: 'POST',
      body: JSON.stringify({ name: REPO_NAME, private: false, auto_init: false }),
    })
  }

  console.log(`2/6 上传文件到 ${repo.full_name} ...`)
  const files = collectFiles(root).filter((f) => {
    const rel = relative(root, f).replaceAll('\\', '/')
    return !IGNORE.has(rel) && !rel.startsWith('.git/')
  })
  for (const f of files) {
    const rel = relative(root, f).replaceAll('\\', '/')
    const isBinary = rel.endsWith('.png')
    const content = readFileSync(f)
    const b64 = content.toString('base64')
    try {
      await jfetch(`${BASE}/repos/${repo.full_name}/contents/${rel}`, {
        method: 'PUT',
        body: JSON.stringify({
          message: `Add ${rel}`,
          content: b64,
        }),
      })
      console.log(`   ✓ ${rel} (${content.length} bytes)`)
    } catch (e) {
      console.error(`   ✗ ${rel}: ${e.message}`)
      process.exit(1)
    }
  }

  console.log('3/6 触发 Build IPA workflow ...')
  const wf = 'build-ipa.yml'
  await jfetch(
    `${BASE}/repos/${repo.full_name}/actions/workflows/${encodeURIComponent(wf)}/dispatches`,
    { method: 'POST', body: JSON.stringify({ ref: 'main' }) }
  )

  console.log('4/6 等待编译完成 ...')
  let run
  for (let i = 0; i < 90; i++) {
    await sleep(8000)
    const runs = await jfetch(`${BASE}/repos/${repo.full_name}/actions/runs?per_page=1`)
    run = runs.workflow_runs?.[0]
    if (run && (run.status === 'completed' || run.conclusion)) break
    process.stdout.write(`   [${i * 8}s] ${run?.status ?? 'queued'} ...\n`)
  }
  if (!run || run.conclusion !== 'success') {
    console.error(`✗ 编译未成功: ${JSON.stringify(run ?? null)}`)
    process.exit(1)
  }
  console.log(`   ✓ 编译成功 (${run.conclusion})`)

  console.log('5/6 下载 ipa artifact ...')
  const arts = await jfetch(`${BASE}/repos/${repo.full_name}/actions/artifacts?per_page=5`)
  const art = arts.artifacts?.find((a) => a.name === 'Embers-unsigned-ipa')
  if (!art) throw new Error('artifact 不存在')
  const dl = await fetch(`${BASE}/repos/${repo.full_name}/actions/artifacts/${art.id}/zip`, { headers: H })
  const buf = Buffer.from(await dl.arrayBuffer())
  mkdirSync(outDir, { recursive: true })
  const zip = join(outDir, 'Embers-unsigned-ipa.zip')
  writeFileSync(zip, buf)
  console.log(`   ✓ 已保存 ${zip} (${buf.length} bytes)`)

  console.log('6/6 完成！解压 zip 得 Embers-unsigned.ipa')
}

main().catch((e) => { console.error('✗', e.message); process.exit(1) })