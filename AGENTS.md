# AGENTS.md

macOS 菜单栏系统监控工具（Swift / SwiftUI + AppKit，macOS 14+，无 Dock 图标）。

## 命令

- 生成工程：`xcodegen generate`（`project.yml` 是唯一事实来源；**新增/删除/移动源文件后必须重新生成**，并把更新后的 `MacPulse.xcodeproj` 一起提交）
- 构建：`xcodebuild -project MacPulse.xcodeproj -scheme MacPulse build`
- 测试：`xcodebuild -project MacPulse.xcodeproj -scheme MacPulse test`
- 单个测试：`xcodebuild ... test -only-testing:MacPulseTests/<类名>/<方法名>`
- Lint：`swiftlint lint`（构建时 pre-build script 也会跑）
- 验证顺序：lint → build → test

## 架构

- 入口 `Sources/App/MacPulseApp.swift`：SwiftUI `App` 壳 + `AppDelegate`（定时器驱动采样，`LSUIElement` 纯菜单栏）。
- `Sources/Models/`：`MetricRegistry`（指标注册，`Metric` 协议）与配置模型（`AppConfiguration`/`CarouselItem`/`Placeholder` + 校验）。
- `Sources/Sampling/`：CPU 采样（host_processor_info 差值计算）。
- `Sources/Carousel/CarouselEngine.swift`：纯函数轮播调度（给定时间算当前项/下次切换时间）。
- `Sources/StatusBar/`：`PlaceholderManager` 按配置创建 `PlaceholderController`（每个对应一个菜单栏项）。
- 新增指标：实现 `Metric` 协议 → 在 `AppDelegate` 注册。

## 约定

- SwiftLint 启用了 opt-in 规则，注意：禁止 force unwrap（`force_unwrapping`）、`sorted_imports`（import 按字母排序）、行宽 140。见 `.swiftlint.yml`。
- Issue 用 `gh` CLI 管理（`SameTrouble/MacPulse`），见 `docs/agents/issue-tracker.md`。
- Triage 标签（needs-triage / needs-info / ready-for-agent / ready-for-human / wontfix），见 `docs/agents/triage-labels.md`。
- 领域文档约定：根目录 `CONTEXT.md` + `docs/adr/`（当前尚未创建，按需懒创建），见 `docs/agents/domain.md`。
