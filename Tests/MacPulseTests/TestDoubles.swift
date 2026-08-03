import Foundation
@testable import MacPulse

final class FakeTickProvider: CPUTickProviding {
    var result: Result<[CPUTick], Error>

    init(result: Result<[CPUTick], Error>) {
        self.result = result
    }

    func currentTicks() throws -> [CPUTick] {
        try result.get()
    }
}

struct SamplingTestError: Error {}

final class FakeGPUUtilizationProvider: GPUUtilizationProviding {
    var result: Result<GPUUtilization, Error>

    init(result: Result<GPUUtilization, Error>) {
        self.result = result
    }

    func currentUtilization() throws -> GPUUtilization {
        try result.get()
    }
}
