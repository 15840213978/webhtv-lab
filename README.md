# GitHub 全自动构建：实验室版 APK

这套文件上传到你的 GitHub 仓库后，GitHub 会自动：

1. 下载默影视上游最新源码；
2. 合并实验室覆盖层（`lab-overlay.zip`）；
3. 应用补丁（包名改为 `com.myself.movie.lab`、应用名改为“默影视实验室版”、补齐依赖）；
4. 构建手机/电视 × arm64/armv7 四个 APK；
5. 自动发布到 Release（标签 `lab-latest`），并上传构建日志工件。

## 本文件夹包含

- `.github/workflows/build-lab.yml`：自动化工作流
- `patch-lab.ps1`：实验室补丁脚本
- `lab-overlay.zip`：实验室缝合覆盖层（必须放在仓库根目录）

## 首次设置步骤

1. 在 GitHub 新建一个仓库（公开或私有都可以）；
2. 把上面三个文件上传到仓库根目录（保持 `.github` 目录结构不变）；
3. 打开仓库 `Settings → Actions → General → Workflow permissions`，选择 **Read and write permissions** 并保存（否则无法自动发布 Release）；
4. 打开仓库 `Actions` 页面，左侧点“实验室版自动构建”，再点 `Run workflow` 手动跑第一次；
5. 完成后打开仓库 `Releases` 页面，在 `lab-latest` 里下载四个 APK。

## 自动更新时机

- 每天北京时间 10:00 自动检查上游并构建（可改 `.github/workflows/build-lab.yml` 里的 `cron`）；
- 手动触发：Actions → Run workflow；
- 你推送 `lab-overlay.zip`、`patch-lab.ps1` 或工作流文件到 `main` 分支时也会触发。

## 固定下载地址

```text
https://github.com/你的用户名/你的仓库/releases/latest/download/WebHTV-实验室版-手机arm64-debug.apk
https://github.com/你的用户名/你的仓库/releases/latest/download/WebHTV-实验室版-手机armv7-debug.apk
https://github.com/你的用户名/你的仓库/releases/latest/download/WebHTV-实验室版-电视arm64-debug.apk
https://github.com/你的用户名/你的仓库/releases/latest/download/WebHTV-实验室版-电视armv7-debug.apk
```

每次自动构建会更新同一个 Release，地址不变，分享给任何人都能拿到最新版。

## 注意事项

- GitHub 免费版 Actions 每月 2000 分钟额度，一次构建约 10–20 分钟，后续有缓存会更快；
- 上游源码约 120MB，第一次构建会下载依赖，之后依赖有缓存；
- APK 超过 GitHub 100MB 的仓库文件限制，所以自动发布走 Release 附件，不要手动把 APK 提交进仓库；
- 如果上游更新导致编译失败，打开 Actions 日志看报错，修好 `lab-overlay.zip` 后推送即可自动重跑。
