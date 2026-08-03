import Foundation
@testable import MacPulse

final class FakeMetric: Metric {
    let id: String
    let displayNameKey: LocalizationKey
    let symbolName = "chart.bar.fill"
    let supportedStyles: Set<MetricStyle>
    let defaultSamplingInterval: TimeInterval

    init(
        id: String,
        displayNameKey: LocalizationKey = .metricCPUName,
        supportedStyles: Set<MetricStyle> = [.iconAndText, .text],
        defaultSamplingInterval: TimeInterval = 2
    ) {
        self.id = id
        self.displayNameKey = displayNameKey
        self.supportedStyles = supportedStyles
        self.defaultSamplingInterval = defaultSamplingInterval
    }

    func refresh() {}
    func currentSample() -> MetricSample? { nil }
    func menuLines(localizedBy localization: LocalizationProviding) -> [String] { [] }
}
