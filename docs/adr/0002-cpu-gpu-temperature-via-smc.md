# ADR-0002: 通过 SMC 私有接口读取 CPU/GPU 温度

## 状态

已接受（2026-08-03）

## 背景

需要 CPU 与 GPU 核心温度指标（issue #7）。Apple Silicon 上没有公开的温度 API，
参考开源 Stats 的思路经 SMC（AppleSMC）私有接口读取。要求无需 root，且应用处于
App Sandbox（`ENABLE_APP_SANDBOX: YES`）内。

## 决策

经 `AppleSMC` 服务打开 SMC 用户客户端（`AppleSMCClient`），用
`IOConnectCallStructMethod` 发送 keyinfo / read-bytes 命令读取温度键值：

- CPU：`Tp*` / `Te*` / `Tf*` 系列（M1–M4 各代键名超集），GPU：`Tg*` / `Tf*` 系列。
  启动后探测一遍可读键并缓存，之后每次采样只读缓存键，对多个传感器取平均。
- 数据解码支持 `sp78`（16.8 定点，标准温度格式）与 `flt `（M4 实测格式），
  另兼容 `ui16` / `ui8`；解码为纯函数 `SMCTemperatureDecoder`。
- Provider：`Sources/Sampling/SMCTemperatureProvider.swift`；采样层
  `TemperatureSampler`；指标 `TemperatureMetric`（默认采样 5 秒，可在设置中调整）。
- 已在 M4 Pro / macOS 27（macOS 26 beta SDK）验证：**沙箱内读取成功**，无需 root，
  单次读 1 个键约 0.14ms。
- 失败（非 Apple Silicon 或键缺失）时抛错，指标层显示 `--`；GPU 读不到时菜单显示
  `GPU：--`。

### 沙箱授权（关键发现）

沙箱下 `IOServiceOpen(AppleSMC)` 返回 `kIOReturnNotPermitted`（0xE00002E2）。
`/System/Library/Sandbox/Profiles/application.sb` 中对应授权键为
**`com.apple.security.temporary-exception.iokit-user-client-class`**
（注意：不是同名非 temporary 版本）。因此在 `Resources/MacPulse.entitlements`
中声明该键并列出用户客户端类名 `AppleSMCClient`（`AppleSMC` 服务的
`IOUserClientClass` 属性，不是 `AppleSMC`）。

## 后果

- 私有接口非承诺稳定：macOS 升级可能改变 SMC 键名或用户客户端行为，指标降级为
  `--`。接受此风险；读取失败不影响其他指标。
- `isSupported` 仅按编译架构（arm64）判断；Intel Mac 上不注册温度指标。
- `temporary-exception` 类授权无法用于 Mac App Store 分发（仅 Developer ID /
  ad-hoc 可签入），若未来需要上架 MAS 需重新评估（例如去掉沙箱或以其他方式读取）。
