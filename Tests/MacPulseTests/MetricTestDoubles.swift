import Foundation
@testable import MacPulse

final class FakeMetric: Metric {
    let id: String
    let displayName: String
    let symbolName = "chart.bar.fill"
    let supportedStyles: Set<MetricStyle>

    init(id: String, supportedStyles: Set<MetricStyle> = [.iconAndText, .text]) {
        self.id = id
        self.displayName = id.uppercased()
        self.supportedStyles = supportedStyles
    }

    func refresh() {}
    func currentSample() -> MetricSample? { nil }
    func menuLines() -> [String] { [] }
}
