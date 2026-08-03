import Foundation

struct MetricSample: Equatable {
    let text: String
    let fraction: Double?
}

protocol Metric: AnyObject {
    var id: String { get }
    var displayNameKey: LocalizationKey { get }
    var symbolName: String { get }
    var supportedStyles: Set<MetricStyle> { get }
    var defaultSamplingInterval: TimeInterval { get }
    func refresh()
    func currentSample() -> MetricSample?
    func menuLines(localizedBy localization: LocalizationProviding) -> [String]
}

extension Metric {
    var defaultSamplingInterval: TimeInterval { 2 }
}

final class MetricRegistry {
    private var storage: [String: Metric] = [:]
    private var insertionOrder: [String] = []

    func register(_ metric: Metric) {
        if storage[metric.id] == nil {
            insertionOrder.append(metric.id)
        }
        storage[metric.id] = metric
    }

    func metric(id: String) -> Metric? {
        storage[id]
    }

    var metrics: [Metric] {
        insertionOrder.compactMap { storage[$0] }
    }
}
