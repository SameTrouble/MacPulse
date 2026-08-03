import Foundation

final class GPUMetric: Metric {
    static let metricID = "gpu"

    let id = GPUMetric.metricID
    let displayName = "GPU"
    let symbolName = "speedometer"
    let supportedStyles: Set<MetricStyle> = [.iconAndText, .text]

    private let provider: GPUUtilizationProviding
    private var sample: MetricSample?

    init(provider: GPUUtilizationProviding = AGXGPUUtilizationProvider()) {
        self.provider = provider
    }

    func refresh() {
        guard let utilization = try? provider.currentUtilization() else {
            sample = nil
            return
        }
        sample = MetricSample(text: PercentDisplay.percent(utilization.device), fraction: utilization.device)
    }

    func currentSample() -> MetricSample? {
        sample
    }

    func menuLines() -> [String] {
        guard let sample else {
            return ["GPU 利用率：--"]
        }
        return ["GPU 利用率：\(sample.text)"]
    }
}
