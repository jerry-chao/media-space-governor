# MediaGovernorDemo

最小 iOS App 壳工程：链接本地 `MediaSpaceGovernorCore` 包，扫描真实相册的可见照片和视频，做浅分类（截图/相机照片/普通视频）、生成治理建议，并后台测量冷资源的本机原文件空间。不读取媒体内容、不上传、不删除。

## 运行到真机（USB）

1. 打开工程：`open apps/MediaGovernorDemo/MediaGovernorDemo.xcodeproj`
2. **签名**：Target → Signing & Capabilities → Team 选你的 Apple ID
   - 免费个人账号即可，但 7 天过期需重签；Bundle ID 也可改成你自己的
3. iPhone 开启**开发者模式**（iOS 16+ 必须）：设置 → 隐私与安全性 → 开发者模式 → 打开并重启
4. 数据线连 Mac，手机上点「信任此电脑」
5. Xcode 顶部 destination 选你的 iPhone，⌘R

首次启动会请求照片访问权限（读写级别，因为全库盘点需要；应用本身不会调用任何修改 API）。

模拟器直接 ⌘R 即可，无需签名（模拟器照片库默认为空，可先拖入照片再测）。

## 命令行构建

```sh
# 真机架构（跳过签名，仅验证编译）
xcodebuild -project apps/MediaGovernorDemo/MediaGovernorDemo.xcodeproj \
  -scheme MediaGovernorDemo -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO build
```

## 真机验收清单（device smoke checklist）

- [ ] 首次启动弹出照片权限说明，文案与功能一致（分析存储、不会自动上传或删除）
- [ ] 授予「允许访问所有照片」后，显示已扫描数量，分类列表出现真实资源的截图/相机照片/普通视频
- [ ] 授予「有限照片」后，顶部明确显示「有限访问 · 已扫描 N 项（部分）」
- [ ] 拒绝权限后显示恢复指引，不崩溃、不显示空结果
- [ ] 收藏的媒体显示为 Protected Resource，且不出现在建议中
- [ ] 冷资源（旧且无使用证据）被标记 cold，测量进度逐项推进，页面不卡顿
- [ ] 测量完成后，清理建议显示测得的本机空间，总节省只含已测得部分
- [ ] 测量进行中可点「停止测量」，进度停止且结果不被破坏
- [ ] 启用「优化 iPhone 储存空间」的 iCloud-only 原文件显示「本机无原文件，未计入」，且设备流量不增长（测量不下载）
- [ ] 隐藏相册的媒体不出现在列表中
- [ ] 全程无删除、无上传：相册内容与测量前后一致

## 结构

```
apps/MediaGovernorDemo/
├── MediaGovernorDemo.xcodeproj     # 手写工程，链接 ../../packages/MediaSpaceGovernorCore
└── MediaGovernorDemo/
    ├── MediaGovernorDemoApp.swift  # @main 入口
    ├── ContentView.swift           # 覆盖信息 / 分类 / 测量进度 / 建议
    ├── PhotoLibraryScanner.swift   # Photos 授权 + 可见媒体枚举（平台胶水）
    └── LocalSizeMeasurer.swift     # 禁用网络的本地原文件字节测量
```
