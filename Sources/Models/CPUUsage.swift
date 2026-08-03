import Foundation

struct CPUTick {
    let user: UInt64
    let system: UInt64
    let idle: UInt64
    let nice: UInt64

    var active: UInt64 {
        user + system + nice
    }

    var total: UInt64 {
        active + idle
    }
}

struct CPUUsage {
    let overall: Double
    let perCore: [Double]
}
