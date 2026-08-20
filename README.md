# GitHub 全自动构建：实验室版 APK

这套文件上传到你的 GitHub 仓库后，GitHub 会自动：

1. 跟随上游 `Silent1566/webhtv` 的 Release，发布新版本（含 beta）时自动下载对应 Release 源码；
2. 合并实验室覆盖层（`lab-overlay.zip`）；
3. 应用补丁（包名改为 `com.myself.movie.lab`、应用名改为“默影视实验室版”、补齐依赖）；
4. 构建手机/电视 × arm64/armv7 四个 APK；
5. 自动发布到 Release（标签 `lab-latest`），并上传构建日志工件。

## 实际仓库（已完成配置）

仓库：https://github.com/woaiguyu1314/webhtv-lab

Release 页面：https://github.com/woaiguyu1314/webhtv-lab/releases/latest

固定下载地址（英文附件名，稳定可靠）：

```text
https://github.com/woaiguyu1314/webhtv-lab/releases/latest/download/WebHTV-Lab-mobile-arm64-debug.apk
https://github.com/woaiguyu1314/webhtv-lab/releases/latest/download/WebHTV-Lab-mobile-armv7-debug.apk
https://github.com/woaiguyu1314/webhtv-lab/releases/latest/download/WebHTV-Lab-tv-arm64-debug.apk
https://github.com/woaiguyu1314/webhtv-lab/releases/latest/download/WebHTV-Lab-tv-armv7-debug.apk
```

## 本文件夹包含

- `.github/workflows/build-lab.yml`：自动化构建工作流
- `.github/workflows/check-upstream-release.yml`：每 30 分钟检查上游 Release 的跟随工作流
- `patch-lab.ps1`：实验室补丁脚本
- `lab-overlay.zip`：实验室缝合覆盖层（必须放在仓库根目录）

## 首次设置步骤

1. 在 GitHub 新建一个仓库（公开或私有都可以）；
2. 把上面文件上传到仓库根目录（保持 `.github` 目录结构不变）；
3. 打开仓库 `Settings → Actions → General → Workflow permissions`，选择 **Read and write permissions** 并保存（否则无法自动发布 Release）；
4. 打开仓库 `Actions` 页面，左侧点“实验室版自动构建”，再点 `Run workflow` 手动跑第一次；
5. 完成后打开仓库 `Releases` 页面，在 `lab-latest` 里下载四个 APK。

## 自动更新时机

- 每 30 分钟检查一次上游 `Silent1566/webhtv` 的 Release；上游发布新版本（含 beta）后自动用该 Release 标签的源码构建，并更新 `lab-latest`；
- 你推送 `lab-overlay.zip`、`patch-lab.ps1` 或工作流文件到 `main` 时立即构建（使用上游 `main` 最新代码）；
- 手动触发：Actions → 实验室版自动构建 → Run workflow，可填写 `upstream_ref` 指定构建某个 Release tag；
- 想立即检查一次上游版本，可手动触发 Actions → 跟随上游 Release 自动构建。

## 固定下载地址

每次自动构建会更新同一个 Release，地址不变，分享给任何人都能拿到最新版。

## 注意事项

- GitHub 免费版 Actions 每月 2000 分钟额度，一次构建约 10–20 分钟，后续有缓存会更快；
- 上游源码约 120MB，第一次构建会下载依赖，之后依赖有缓存；
- APK 超过 GitHub 100MB 的仓库文件限制，所以自动发布走 Release 附件，不要手动把 APK 提交进仓库；
- 如果上游更新导致编译失败，打开 Actions 日志看报错，修好 `lab-overlay.zip` 后推送即可自动重跑。