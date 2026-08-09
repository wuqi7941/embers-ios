# 余烬 EMBERS — iPhone App 安装说明

签名侧载工具：**全能签**（iPhone 上安装，自带签名证书，无需电脑）。

## 一、获取 ipa

每次 GitHub Actions 编译完成后：

1. 打开仓库 Actions 页：`https://github.com/<你的账号>/embers-ios/actions`
2. 点进「Build IPA」最新一次运行
3. 底部 Artifacts → 下载 `Embers-unsigned-ipa`

Windows 电脑上也可用命令行下载（已配置 gh 后）：

```
gh run download --repo <账号>/embers-ios --pattern "Embers-unsigned-ipa" --dir Desktop
```

## 二、用全能签安装

1. iPhone 打开「全能签」App
2. 导入上方下载的 `Embers-unsigned.ipa`
3. 若全能签已配置签名证书，直接「签名并安装」
4. 安装完成，桌面出现「余烬」App（签名有效期内可正常打开）

> 签名有效期：付费证书通常 1 年；免费证书约 7 天，到期后在全能签里重新签名一次即可，文章数据不丢。

## 三、更新文章（重新发版）

新写文章后，在桌面 `workbuddy` 下执行（需要先跑 my-app 的 `merge-posts.cjs` 保证 posts.json 是最新的）：

```
node ios-app/scripts/build-articles.mjs   # 把文章打包进 Resources/articles.json
git -C ios-app add -A
git -C ios-app commit -m "publish: 新文章"
git -C ios-app push
```

push 自动触发云端编译 → 回到第一步下载新 ipa → 全能签覆盖安装（旧 app 数据保留）。

## 常问

- **为什么是未签名 ipa？** Windows 无法跑 Xcode，编译和打包都在 GitHub 云端 macOS 完成；签名交给全能签，用你自己的证书，更自由。
- **第一次想先看看效果？** 同样的流程，ipa 下载即用。
- **bundle id**：`com.guanjin.embers`，签名时保持不动（换 id 会被系统当作新 App）。