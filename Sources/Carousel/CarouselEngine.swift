import Foundation

struct CarouselEngine: Equatable {
    let entries: [CarouselItem]
    let epoch: TimeInterval

    private var cycleDuration: TimeInterval {
        entries.reduce(0) { $0 + $1.duration }
    }

    func index(at time: TimeInterval) -> Int? {
        guard !entries.isEmpty else { return nil }
        guard entries.count > 1 else { return 0 }

        var elapsed = elapsedInCycle(at: time)
        var index = 0
        for item in entries {
            elapsed -= item.duration
            if elapsed < 0 { return index }
            index += 1
        }
        return entries.count - 1
    }

    func nextSwitchTime(after time: TimeInterval) -> TimeInterval? {
        guard entries.count > 1 else { return nil }

        let elapsed = elapsedInCycle(at: time)
        let cycleStart = time - elapsed

        var boundary: TimeInterval = 0
        for item in entries {
            boundary += item.duration
            if elapsed < boundary {
                return cycleStart + boundary
            }
        }
        return cycleStart + cycleDuration
    }

    private func elapsedInCycle(at time: TimeInterval) -> TimeInterval {
        var elapsed = (time - epoch).truncatingRemainder(dividingBy: cycleDuration)
        if elapsed < 0 { elapsed += cycleDuration }
        return elapsed
    }
}
