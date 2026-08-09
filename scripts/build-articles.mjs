#!/usr/bin/env node
// 从桌面 workbuddy 打包文章进 App 资源：my-app/lib/posts.json → ios-app/Resources/articles.json
// 用法：node scripts/build-articles.mjs

import { readFileSync, writeFileSync } from 'node:fs'
import { resolve, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

const here = dirname(fileURLToPath(import.meta.url))
const postsJson = resolve(here, '../../my-app/lib/posts.json')
const out = resolve(here, '../Resources/articles.json')

if (!readFileSync) throw new Error()

let posts
try {
  posts = JSON.parse(readFileSync(postsJson, 'utf8'))
} catch (err) {
  console.error(`✗ 无法读取 ${postsJson}：${err.message}`)
  console.error('  请确认桌面 workbuddy/my-app/lib/posts.json 存在（先运行 my-app 的 merge-posts.cjs）')
  process.exit(1)
}

const articles = posts.map(({ slug, title, date, tags, excerpt, readingTime, content }) => ({
  slug,
  title,
  date,
  tags,
  excerpt,
  readingTime,
  content,
}))

writeFileSync(out, JSON.stringify(articles, null, 2), 'utf8')
console.log(`✓ ${articles.length} 篇文章已打包 → ${out}`)