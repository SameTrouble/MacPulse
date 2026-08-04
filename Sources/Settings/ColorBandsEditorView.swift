import SwiftUI

struct ColorBandsEditorView: View {
    private static let sliderStep: Double = 0.05
    private static let defaultNewBandColor: PaletteColor = .yellow

    @Bindable var model: ConfigurationModel
    let registry: MetricRegistry
    let localization: LocalizationProviding

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(localization.text(.colorBandsEnabled), isOn: $model.draft.colorBandsEnabled)
            Text(localization.text(.colorBandsDisabledHint))
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(localization.text(.colorBandsMatchHint))
                .font(.caption)
                .foregroundStyle(.secondary)
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(registry.metrics, id: \.id) { metric in
                        metricBandEditor(metric)
                    }
                }
            }
        }
        .padding(10)
    }

    private func metricBandEditor(_ metric: Metric) -> some View {
        let bands = sortedBands(for: metric.id)
        return VStack(alignment: .leading, spacing: 8) {
            Text(localization.text(metric.displayNameKey))
                .font(.headline)
            if bands.isEmpty {
                Text(localization.text(.colorBandsEmpty))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ForEach(Array(bands.enumerated()), id: \.element.id) { index, band in
                bandRow(band: band, index: index, bands: bands, metricID: metric.id)
            }
            Button {
                addBand(for: metric.id)
            } label: {
                Image(systemName: "plus")
            }
            .disabled(!canAddBand(for: metric.id))
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }

    private func bandRow(
        band: ColorBand,
        index: Int,
        bands: [ColorBand],
        metricID: String
    ) -> some View {
        let isLast = index == bands.count - 1
        let lowerBound = index == 0 ? 0.0 : bands[index - 1].upperBound
        let scale = ColorBandDisplayScale.forMetricID(metricID)
        return HStack(spacing: 12) {
            Text(scale.rangeLabel(lower: lowerBound, upper: band.upperBound))
                .monospacedDigit()
                .frame(width: 80, alignment: .leading)
            if isLast {
                Text(scale.fullScaleLabel)
                    .monospacedDigit()
                    .frame(width: 180, alignment: .leading)
                    .foregroundStyle(.secondary)
            } else {
                Slider(
                    value: upperBoundBinding(id: band.id, for: metricID),
                    in: sliderRange(index: index, bands: bands),
                    step: Self.sliderStep
                ) {
                    Text(localization.text(.upperBound))
                }
                .frame(width: 180)
            }
            Picker(localization.text(.color), selection: colorBinding(id: band.id, for: metricID)) {
                ForEach(PaletteColor.allCases, id: \.self) { color in
                    Text(colorLabel(color)).tag(color)
                }
            }
            .labelsHidden()
            .frame(width: 90)
            Button {
                removeBand(id: band.id, for: metricID)
            } label: {
                Image(systemName: "minus")
            }
        }
    }

    private func sortedBands(for metricID: String) -> [ColorBand] {
        (model.draft.colorBands[metricID] ?? []).sorted { $0.upperBound < $1.upperBound }
    }

    private func sliderRange(index: Int, bands: [ColorBand]) -> ClosedRange<Double> {
        let step = Self.sliderStep
        let previous = index == 0 ? 0.0 : bands[index - 1].upperBound
        let next = bands[index + 1].upperBound
        let lower = previous + step
        let upper = next - step
        if lower <= upper {
            return lower...upper
        }
        let midpoint = (previous + next) / 2
        return midpoint...midpoint
    }

    private func upperBoundBinding(id: UUID, for metricID: String) -> Binding<Double> {
        Binding(
            get: {
                model.draft.colorBands[metricID]?.first { $0.id == id }?.upperBound ?? 0
            },
            set: { newValue in
                guard let index = model.draft.colorBands[metricID]?.firstIndex(where: { $0.id == id }) else {
                    return
                }
                model.draft.colorBands[metricID]?[index].upperBound = newValue
            }
        )
    }

    private func colorBinding(id: UUID, for metricID: String) -> Binding<PaletteColor> {
        Binding(
            get: {
                model.draft.colorBands[metricID]?.first { $0.id == id }?.color ?? .yellow
            },
            set: { newValue in
                guard let index = model.draft.colorBands[metricID]?.firstIndex(where: { $0.id == id }) else {
                    return
                }
                model.draft.colorBands[metricID]?[index].color = newValue
            }
        )
    }

    private func canAddBand(for metricID: String) -> Bool {
        let bands = sortedBands(for: metricID)
        if bands.isEmpty { return true }
        guard let last = bands.last else { return true }
        let previousUpper = bands.count >= 2 ? bands[bands.count - 2].upperBound : 0.0
        return previousUpper + Self.sliderStep <= last.upperBound - Self.sliderStep
    }

    private func addBand(for metricID: String) {
        var bands = sortedBands(for: metricID)
        if bands.isEmpty {
            guard let band = try? ColorBand(upperBound: 1.0, color: Self.defaultNewBandColor) else { return }
            model.draft.colorBands[metricID] = [band]
            return
        }
        guard canAddBand(for: metricID), let last = bands.last else { return }
        let previousUpper = bands.count >= 2 ? bands[bands.count - 2].upperBound : 0.0
        let step = Self.sliderStep
        let midpoint = ((previousUpper + last.upperBound) / 2 / step).rounded() * step
        let clampedMidpoint = min(max(midpoint, previousUpper + step), last.upperBound - step)
        guard clampedMidpoint > previousUpper, clampedMidpoint < last.upperBound else { return }
        guard let newBand = try? ColorBand(upperBound: clampedMidpoint, color: Self.defaultNewBandColor) else {
            return
        }
        bands.insert(newBand, at: bands.count - 1)
        model.draft.colorBands[metricID] = bands
    }

    private func removeBand(id: UUID, for metricID: String) {
        var bands = sortedBands(for: metricID)
        guard let index = bands.firstIndex(where: { $0.id == id }) else { return }
        let wasLast = index == bands.count - 1
        bands.remove(at: index)
        if wasLast, let newLastIndex = bands.indices.last {
            bands[newLastIndex].upperBound = 1.0
        }
        model.draft.colorBands[metricID] = bands
    }

    private func colorLabel(_ color: PaletteColor) -> String {
        switch color {
        case .white:
            localization.text(.colorWhite)
        case .red:
            localization.text(.colorRed)
        case .orange:
            localization.text(.colorOrange)
        case .yellow:
            localization.text(.colorYellow)
        case .green:
            localization.text(.colorGreen)
        case .blue:
            localization.text(.colorBlue)
        case .purple:
            localization.text(.colorPurple)
        case .gray:
            localization.text(.colorGray)
        }
    }
}
