import Foundation

enum CPUUsageCalculator {
    static func usage(previous: [CPUTick], current: [CPUTick]) -> CPUUsage? {
        guard !previous.isEmpty, previous.count == current.count else { return nil }

        var perCore: [Double] = []
        perCore.reserveCapacity(current.count)
        var activeDeltaSum: UInt64 = 0
        var totalDeltaSum: UInt64 = 0

        for (old, new) in zip(previous, current) {
            guard new.total >= old.total, new.active >= old.active else { return nil }
            let activeDelta = new.active - old.active
            let totalDelta = new.total - old.total
            activeDeltaSum += activeDelta
            totalDeltaSum += totalDelta
            perCore.append(totalDelta == 0 ? 0 : Double(activeDelta) / Double(totalDelta))
        }

        let overall = totalDeltaSum == 0 ? 0 : Double(activeDeltaSum) / Double(totalDeltaSum)
        return CPUUsage(overall: overall, perCore: perCore)
    }
}
