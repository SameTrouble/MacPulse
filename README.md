# MacPulse

macOS 菜单栏系统监控工具（CPU / 内存 / GPU / 温度），纯菜单栏运行，无 Dock 图标。

## 状态

开发中（scaffold 阶段）。

## 开发

- 依赖：Xcode、[XcodeGen](https://github.com/yonaskolb/XcodeGen)、[SwiftLint](https://github.com/realm/SwiftLint)
- 生成工程：`xcodegen generate`
- 构建：`xcodebuild -project MacPulse.xcodeproj -scheme MacPulse build`
- 测试：`xcodebuild -project MacPulse.xcodeproj -scheme MacPulse test`
- Lint：`swiftlint lint`

## 许可

MIT（见 [LICENSE](LICENSE)）
