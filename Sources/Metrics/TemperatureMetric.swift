import Foundation

class TemperatureMetric: SampledMetric<TemperatureUsage, TemperatureSampler> {
    private let prefix: String
    private let menuKey: LocalizationKey

    init(
        id: String,
        prefix: String,
        displayNameKey: LocalizationKey,
        symbolName: String,
        menuKey: LocalizationKey,
        sampler: TemperatureSampler
    ) {
        self.prefix = prefix
        self.menuKey = menuKey
        super.init(
            id: id,
            displayNameKey: displayNameKey,
            symbolName: symbolName,
            supportedStyles: [.iconAndText, .text],
            defaultSamplingInterval: 5,
            sampler: sampler
        )
    }

    func celsiusValue(from usage: TemperatureUsage) -> Double? {
        nil
    }

    override func makeSample(from usage: TemperatureUsage) -> MetricSample? {
        guard let celsius = celsiusValue(from: usage) else {
            return MetricSample(text: "\(prefix) \(ValueFormatting.fallback)", fraction: nil)
        }
        return MetricSample(
            text: "\(prefix) \(ValueFormatting.celsius(celsius))",
            fraction: min(max(celsius / 100, 0), 1)
        )
    }

    override func currentSample() -> MetricSample? {
        sample ?? MetricSample(text: "\(prefix) \(ValueFormatting.fallback)", fraction: nil)
    }

    override func menuLines(localizedBy localization: LocalizationProviding) -> [String] {
        guard let usage else {
            return [localization.text(menuKey, ValueFormatting.fallback)]
        }
        guard let celsius = celsiusValue(from: usage) else {
            return [localization.text(menuKey, ValueFormatting.fallback)]
        }
        return [localization.text(menuKey, ValueFormatting.celsius(celsius))]
    }

    override func widestDisplayText() -> String {
        "\(prefix) \(ValueFormatting.widestCelsius)"
    }
}
