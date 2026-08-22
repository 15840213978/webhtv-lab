# GitHub 全自动构建：实验室版 APK

这套文件上传到你的 GitHub 仓库后，GitHub 会自动：

1. 每次构建都读取上游 `Silent1566/webhtv` 的最新 Release（含 beta），并下载对应 Release 标签源码；
2. 合并实验室覆盖层（`lab-overlay.zip`）；
3. 应用补丁（包名改为 `com.myself.movie.lab`、应用名改为“默影视实验室版”、补齐依赖）；
4. 构建手机/电视 × arm64/armv7 四个 APK；
5. 自动发布到 Release（标签 `lab-latest`），并上传构建日志工件。

## 上游源码与致谢

本仓库只保存自动化构建配置，不包含上游完整源码。这里发布的 APK 全部来自以下开源项目，请尊重原作者的开源成果：

- 直接上游：[Silent1566/webhtv](https://github.com/Silent1566/webhtv) —— 基于鱼佬的 WebHomeTV 二次开发，GitHub 标注 GPL-3.0；
- WebHomeTV 原版：[fish2018/webhtv](https://github.com/fish2018/webhtv) —— 鱼佬作品，基于 FongMi 二次开发，GitHub 标注 GPL-3.0；
- 生态基础：[FongMi/TV](https://github.com/FongMi/TV) 及 CatVod 开源生态。

每次自动构建使用的上游 Release 标签都会写在对应构建的 Release 说明里。使用、分发本仓库 APK 时，请遵守上游项目的开源许可证，并保留对原作者与所有贡献者的署名和致谢。
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
- `.github/workflows/check-upstream-release.yml`：每天北京时间 22:00 检查上游 Release 的跟随工作流
- `patch-lab.ps1`：实验室补丁脚本
- `lab-overlay.zip`：实验室缝合覆盖层（必须放在仓库根目录）

## 自动更新时机

- 每天北京时间 22:00 检查一次上游 `Silent1566/webhtv` 的 Release；上游发布新版本（含 beta）后自动用该 Release 标签的源码构建，并更新 `lab-latest`；
- 你推送 `lab-overlay.zip`、`patch-lab.ps1` 或工作流文件到 `main` 时立即构建，始终使用上游最新 Release（含 beta）源码；
- 手动触发：Actions → 实验室版自动构建 → Run workflow，同样始终使用上游最新 Release（含 beta）源码；
- 想立即检查一次上游版本，可手动触发 Actions → 跟随上游 Release 自动构建。

## 固定下载地址

每次自动构建会更新同一个 Release，地址不变，分享给任何人都能拿到最新版。

## 注意事项

- GitHub 免费版 Actions 每月 2000 分钟额度，一次构建约 10–20 分钟，后续有缓存会更快；
- 上游源码约 120MB，第一次构建会下载依赖，之后依赖有缓存；
- APK 超过 GitHub 100MB 的仓库文件限制，所以自动发布走 Release 附件，不要手动把 APK 提交进仓库；
- 如果上游更新导致编译失败，打开 Actions 日志看报错，修好 `lab-overlay.zip` 后推送即可自动重跑。
