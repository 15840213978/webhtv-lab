# 默影视实验室版自动构建

本仓库将实验室覆盖层合并到 [Silent1566/webhtv](https://github.com/Silent1566/webhtv) 最新正式 Release 源码，并通过 GitHub Actions 自动构建和发布 APK。

## 自动更新流程

1. 每天北京时间 10:00 查询上游最新正式 Release；
2. 与 `upstream-last.txt` 中上次成功构建的 Release ID 和标签比较；
3. 仅在上游发布新正式 Release 时下载该标签的源码、应用 `lab-overlay.zip` 和 `patch-lab.ps1`；
4. 构建手机/电视 × arm64/armv7 四个 APK；
5. 更新固定的 `lab-latest` Release；
6. 发布成功后记录本次上游 Release，避免无变化时重复构建。

上游 `main` 分支的普通提交和预发布版不会触发定时构建。更新覆盖层、补丁或工作流，以及手动运行工作流时，会忽略 Release 版本比较并使用最新正式 Release 强制构建一次。

## 下载

- [最新 Release](https://github.com/woaiguyu1314/webhtv-lab/releases/latest)
- [手机版 arm64](https://github.com/woaiguyu1314/webhtv-lab/releases/latest/download/WebHTV-Lab-mobile-arm64-debug.apk)
- [手机版 armv7](https://github.com/woaiguyu1314/webhtv-lab/releases/latest/download/WebHTV-Lab-mobile-armv7-debug.apk)
- [电视版 arm64](https://github.com/woaiguyu1314/webhtv-lab/releases/latest/download/WebHTV-Lab-tv-arm64-debug.apk)
- [电视版 armv7](https://github.com/woaiguyu1314/webhtv-lab/releases/latest/download/WebHTV-Lab-tv-armv7-debug.apk)

## 仓库文件

- `lab-overlay.zip`：覆盖到上游源码根目录的实验室功能文件；
- `patch-lab.ps1`：修改应用名、包名并补充实验室功能依赖；
- `.github/workflows/build-lab.yml`：上游检测、构建和 Release 发布工作流；
- `upstream-last.txt`：最近一次成功构建的上游 Release ID 和标签，由工作流自动维护。

## 维护

替换仓库根目录的 `lab-overlay.zip` 并推送到 `main` 后，会立即触发完整构建。若上游结构变化导致编译失败，请根据 Actions 日志调整覆盖层或补丁后重新推送。
