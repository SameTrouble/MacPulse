@testable import MacPulse
import XCTest

final class TemperatureMetricTests: XCTestCase {
    private func sharedMetrics(cpu: Double, gpu: Double?) -> (CPUTemperatureMetric, GPUTemperatureMetric) {
        let usage = TemperatureUsage(cpuCelsius: cpu, gpuCelsius: gpu)
        let sampler = TemperatureSampler(provider: FakeTemperatureProvider(result: .success(usage)))
        return (CPUTemperatureMetric(sampler: sampler), GPUTemperatureMetric(sampler: sampler))
    }

    func testCPUMetadata() {
        let (cpu, _) = sharedMetrics(cpu: 42, gpu: 40)

        XCTAssertEqual(cpu.id, "cpu-temperature")
        XCTAssertEqual(cpu.displayNameKey, .metricCPUTemperatureName)
        XCTAssertEqual(cpu.symbolName, "thermometer")
        XCTAssertEqual(cpu.supportedStyles, [.iconAndText, .text])
    }

    func testGPUMetadata() {
        let (_, gpu) = sharedMetrics(cpu: 42, gpu: 40)

        XCTAssertEqual(gpu.id, "gpu-temperature")
        XCTAssertEqual(gpu.displayNameKey, .metricGPUTemperatureName)
        XCTAssertEqual(gpu.symbolName, "thermometer.medium")
        XCTAssertEqual(gpu.supportedStyles, [.iconAndText, .text])
    }

    func testDefaultSamplingIntervalIsFiveSeconds() {
        let (cpu, gpu) = sharedMetrics(cpu: 42, gpu: nil)

        XCTAssertEqual(cpu.defaultSamplingInterval, 5)
        XCTAssertEqual(gpu.defaultSamplingInterval, 5)
    }

    func testSampleIsNilBeforeFirstRefresh() {
        let (cpu, gpu) = sharedMetrics(cpu: 42, gpu: 40)

        XCTAssertNil(cpu.currentSample())
        XCTAssertNil(gpu.currentSample())
    }

    func testCPUSampleShowsCelsiusAndFraction() {
        let (cpu, _) = sharedMetrics(cpu: 42.4, gpu: 40)
        cpu.refresh()

        let sample = cpu.currentSample()
        XCTAssertEqual(sample?.text, "42°")
        XCTAssertEqual(sample?.fraction ?? -1, 0.424, accuracy: 0.0001)
    }

    func testGPUSampleShowsCelsiusAndFraction() {
        let (_, gpu) = sharedMetrics(cpu: 42, gpu: 40.6)
        gpu.refresh()

        let sample = gpu.currentSample()
        XCTAssertEqual(sample?.text, "41°")
        XCTAssertEqual(sample?.fraction ?? -1, 0.406, accuracy: 0.0001)
    }

    func testGPUSampleShowsDashWhenGpuMissing() {
        let (_, gpu) = sharedMetrics(cpu: 42, gpu: nil)
        gpu.refresh()

        let sample = gpu.currentSample()
        XCTAssertEqual(sample?.text, "--")
        XCTAssertNil(sample?.fraction)
    }

    func testSharedSamplerHitsProviderOnceForBothMetrics() {
        let usage = TemperatureUsage(cpuCelsius: 42, gpuCelsius: 40)
        let provider = FakeTemperatureProvider(result: .success(usage))
        let sampler = TemperatureSampler(provider: provider, coalesceInterval: 1)
        let cpu = CPUTemperatureMetric(sampler: sampler)
        let gpu = GPUTemperatureMetric(sampler: sampler)

        cpu.refresh()
        gpu.refresh()

        XCTAssertEqual(provider.callCount, 1)
        XCTAssertEqual(cpu.currentSample()?.text, "42°")
        XCTAssertEqual(gpu.currentSample()?.text, "40°")
    }

    func testFailedRefreshClearsSamples() {
        let provider = FakeTemperatureProvider(result: .success(TemperatureUsage(cpuCelsius: 42, gpuCelsius: 40)))
        let sampler = TemperatureSampler(provider: provider, coalesceInterval: 0)
        let cpu = CPUTemperatureMetric(sampler: sampler)
        let gpu = GPUTemperatureMetric(sampler: sampler)
        cpu.refresh()
        gpu.refresh()

        provider.result = .failure(SamplingTestError())
        cpu.refresh()
        gpu.refresh()

        XCTAssertNil(cpu.currentSample())
        XCTAssertNil(gpu.currentSample())
    }

    func testCPUMenuLineShowsOnlyCpu() {
        let (cpu, _) = sharedMetrics(cpu: 42, gpu: 40)
        cpu.refresh()

        XCTAssertEqual(
            cpu.menuLines(localizedBy: localizationService(language: .zhHans)),
            ["CPU：42°"]
        )
        XCTAssertEqual(
            cpu.menuLines(localizedBy: localizationService(language: .english)),
            ["CPU: 42°"]
        )
    }

    func testGPUMenuLineShowsOnlyGpu() {
        let (_, gpu) = sharedMetrics(cpu: 42, gpu: 40)
        gpu.refresh()

        XCTAssertEqual(
            gpu.menuLines(localizedBy: localizationService(language: .zhHans)),
            ["GPU：40°"]
        )
        XCTAssertEqual(
            gpu.menuLines(localizedBy: localizationService(language: .english)),
            ["GPU: 40°"]
        )
    }

    func testGPUMenuLineShowsDashWhenGpuMissing() {
        let (_, gpu) = sharedMetrics(cpu: 42, gpu: nil)
        gpu.refresh()

        XCTAssertEqual(
            gpu.menuLines(localizedBy: localizationService(language: .zhHans)),
            ["GPU：--"]
        )
        XCTAssertEqual(
            gpu.menuLines(localizedBy: localizationService(language: .english)),
            ["GPU: --"]
        )
    }

    func testMenuLinesShowDashesWithoutSample() {
        let (cpu, gpu) = sharedMetrics(cpu: 42, gpu: nil)

        XCTAssertEqual(
            cpu.menuLines(localizedBy: localizationService(language: .zhHans)),
            ["CPU：--"]
        )
        XCTAssertEqual(
            gpu.menuLines(localizedBy: localizationService(language: .zhHans)),
            ["GPU：--"]
        )
        XCTAssertEqual(
            cpu.menuLines(localizedBy: localizationService(language: .english)),
            ["CPU: --"]
        )
        XCTAssertEqual(
            gpu.menuLines(localizedBy: localizationService(language: .english)),
            ["GPU: --"]
        )
    }

    func testWidestDisplayTextIsThreeDigitCelsius() {
        let (cpu, gpu) = sharedMetrics(cpu: 42, gpu: nil)

        XCTAssertEqual(cpu.widestDisplayText(), "100°")
        XCTAssertEqual(gpu.widestDisplayText(), "100°")
        XCTAssertEqual(cpu.widestDisplayText(), TemperatureUsageDisplay.widestText)
    }
}
