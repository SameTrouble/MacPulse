import Foundation

struct MetricSample: Equatable {
    let text: String
    let fraction: Double?
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
