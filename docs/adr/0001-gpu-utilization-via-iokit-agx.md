# ADR-0001: 通过 IOKit AGX 私有接口读取 GPU 利用率

## 状态

已接受（2026-08-03）

## 背景

需要 GPU 利用率指标（issue #6）。Apple Silicon 上没有公开的 GPU 利用率 API，
需要参考开源 Stats 的思路经 IOKit / AGX 私有接口实现。要求无需 root。

## 决策

经 IORegistry 读取 `AGXAccelerator` 服务类的 `PerformanceStatistics` 字典中的
`Device Utilization %`（整数百分比），多 GPU 时取最大值。已在 M5 / macOS 27 上
验证：沙箱与非沙箱均可读取，无需 root，单次读取约 6ms。

- Provider：`Sources/Sampling/AGXGPUStatsProvider.swift`（IOKit 实现）
- 失败（非 Apple Silicon 或键缺失）时抛错，指标层显示 `--`

## 后果

- `PerformanceStatistics` 是私有/非承诺稳定的接口，macOS 升级可能改变键名或类名，
  导致该指标降级为 `--`。接受此风险；读取失败不影响其他指标。
- `isSupported` 仅按编译架构（arm64）判断；Intel Mac 上不注册 GPU 指标。
