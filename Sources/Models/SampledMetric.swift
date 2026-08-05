import Foundation

protocol Sampling: AnyObject {
    associatedtype Sample
    func refresh() throws -> Sample
}

class SampledMetric<Usage, Sampler: Sampling>: Metric where Sampler.Sample == Usage {
    let id: String
    let displayNameKey: LocalizationKey
    let symbolName: String
    let supportedStyles: Set<MetricStyle>
    let defaultSamplingInterval: TimeInterval

    private let sampler: Sampler
    private(set) var usage: Usage?
    private(set) var sample: MetricSample?

    init(
        id: String,
        displayNameKey: LocalizationKey,
        symbolName: String,
        supportedStyles: Set<MetricStyle>,
        defaultSamplingInterval: TimeInterval = 2,
        sampler: Sampler
    ) {
        self.id = id
        self.displayNameKey = displayNameKey
        self.symbolName = symbolName
        self.supportedStyles = supportedStyles
        self.defaultSamplingInterval = defaultSamplingInterval
        self.sampler = sampler
    }

    func refresh() {
        do {
            usage = try sampler.refresh()
        } catch {
            usage = nil
        }
        sample = usage.flatMap { makeSample(from: $0) }
    }

    func currentSample() -> MetricSample? {
        sample
    }

    func makeSample(from usage: Usage) -> MetricSample? {
        nil
    }

    func menuLines(localizedBy localization: LocalizationProviding) -> [String] {
        []
    }

    func widestDisplayText() -> String {
        MetricWidth.fallbackText
    }
}
