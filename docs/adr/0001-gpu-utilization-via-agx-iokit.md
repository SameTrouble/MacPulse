# ADR-0001: GPU 利用率通过 IOKit AGXAccelerator 读取

## 状态

已接受（issue #6）

## 背景

Apple Silicon 上没有公开的 GPU 利用率 API。需要一条无需 root、且能在 App Sandbox 下工作的读取路径。

## 调研结论

- IOKit 注册表中的 `AGXAccelerator` 服务（Apple GPU 驱动）暴露 `PerformanceStatistics` 字典，其中 `Device Utilization %`（0–100 整数）即 GPU 利用率。同一字典还含 `Renderer Utilization %`、`Tiler Utilization %`。
- 已通过 `ioreg -r -c AGXAccelerator` 与 Swift 探针验证：普通用户、无 root、沙盒进程均可读取（测试宿主即沙盒应用，冒烟测试通过）。
- 开源 Stats 采用同一思路（IORegistry 读取 PerformanceStatistics）。
- 该接口为私有接口，键名可能随 macOS 版本变化；读取失败时指标显示 `--`。
- Intel Mac 无 `AGXAccelerator` 服务，`isSupported` 返回 false，GPU 指标不注册（设置编辑器中不出现）。

## 决定

`AGXGPUUtilizationProvider` 经 IOKit 匹配 `AGXAccelerator`，读取 `PerformanceStatistics["Device Utilization %"]` 并除以 100 归一化；仅暴露 device 利用率（spec 只要求利用率）。`AppDelegate` 仅在 `isSupported` 为 true 时注册 `GPUMetric`。

## 后果

- 依赖私有接口，未来系统升级可能需要适配；失败路径已有 `--` 兜底。
- 无 GPU 图标类 SF Symbol（`gpu`/`gpu.fill` 在当前系统不存在），图标采用 `speedometer`（利用率仪表语义）。
