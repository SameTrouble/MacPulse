import Foundation
@testable import MacPulse

final class FakeMetric: Metric {
    init(
        id: String,
        displayNameKey: LocalizationKey = .metricCPUName,
        supportedStyles: Set<MetricStyle> = [.iconAndText, .text],
        defaultSamplingInterval: TimeInterval = 2
    ) {
        super.init(
            id: id,
            displayNameKey: displayNameKey,
            symbolName: "chart.bar.fill",
            supportedStyles: supportedStyles,
            defaultSamplingInterval: defaultSamplingInterval
        )
    }
}
