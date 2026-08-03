import Foundation
@testable import MacPulse

final class FakeMetric: Metric {
    let id: String
    let displayName: String
    let symbolName = "chart.bar.fill"
    let supportedStyles: Set<MetricStyle>
    let defaultSamplingInterval: TimeInterval

    init(id: String, supportedStyles: Set<MetricStyle> = [.iconAndText, .text], defaultSamplingInterval: TimeInterval = 2) {
        self.id = id
        self.displayName = id.uppercased()
        self.supportedStyles = supportedStyles
        self.defaultSamplingInterval = defaultSamplingInterval
    }

    func refresh() {}
    func currentSample() -> MetricSample? { nil }
    func menuLines() -> [String] { [] }
}
