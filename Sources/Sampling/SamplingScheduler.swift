import Foundation

enum SamplingScheduler {
    static func dueIDs(
        now: Date,
        intervals: [String: TimeInterval],
        lastSample: [String: Date]
    ) -> Set<String> {
        var due: Set<String> = []
        for (id, interval) in intervals {
            if let last = lastSample[id], now.timeIntervalSince(last) < interval {
                continue
            }
            due.insert(id)
        }
        return due
    }
}
