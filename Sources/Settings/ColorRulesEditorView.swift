import SwiftUI

struct ColorRulesEditorView: View {
    @Bindable var model: ConfigurationModel
    let registry: MetricRegistry
    let localization: LocalizationProviding

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(localization.text(.colorRulesEnabled), isOn: $model.draft.colorRulesEnabled)
            Text(localization.text(.colorRulesDisabledHint))
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(localization.text(.colorRulesMatchHint))
                .font(.caption)
                .foregroundStyle(.secondary)
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(registry.metrics, id: \.id) { metric in
                        metricRuleEditor(metric)
                    }
                }
            }
        }
        .padding(10)
    }

    private func metricRuleEditor(_ metric: Metric) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localization.text(metric.displayNameKey))
                .font(.headline)
            if model.draft.colorRules[metric.id, default: []].isEmpty {
                Text(localization.text(.colorRulesEmpty))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ForEach(rulesBinding(for: metric.id)) { $rule in
                HStack(spacing: 12) {
                    Text("≥")
                    Slider(value: $rule.threshold, in: ColorRule.thresholdRange, step: 0.05) {
                        Text(localization.text(.threshold))
                    }
                    .frame(width: 180)
                    Text("\(Int(rule.threshold * 100))%")
                        .monospacedDigit()
                        .frame(width: 42, alignment: .trailing)
                    Picker(localization.text(.color), selection: $rule.color) {
                        ForEach(PaletteColor.allCases, id: \.self) { color in
                            Text(colorLabel(color)).tag(color)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 90)
                    Button {
                        moveRule(id: rule.id, for: metric.id, by: -1)
                    } label: {
                        Image(systemName: "chevron.up")
                    }
                    .disabled(!canMoveRule(id: rule.id, for: metric.id, by: -1))
                    Button {
                        moveRule(id: rule.id, for: metric.id, by: 1)
                    } label: {
                        Image(systemName: "chevron.down")
                    }
                    .disabled(!canMoveRule(id: rule.id, for: metric.id, by: 1))
                    Button {
                        removeRule(id: rule.id, for: metric.id)
                    } label: {
                        Image(systemName: "minus")
                    }
                }
            }
            Button {
                addRule(for: metric.id)
            } label: {
                Image(systemName: "plus")
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }

    private func rulesBinding(for metricID: String) -> Binding<[ColorRule]> {
        Binding(
            get: { model.draft.colorRules[metricID] ?? [] },
            set: { model.draft.colorRules[metricID] = $0 }
        )
    }

    private func addRule(for metricID: String) {
        guard let rule = try? ColorRule(threshold: 0.5, color: .yellow) else { return }
        model.draft.colorRules[metricID, default: []].append(rule)
    }

    private func removeRule(id: UUID, for metricID: String) {
        model.draft.colorRules[metricID]?.removeAll { $0.id == id }
    }

    private func canMoveRule(id: UUID, for metricID: String, by offset: Int) -> Bool {
        guard let rules = model.draft.colorRules[metricID],
              let index = rules.firstIndex(where: { $0.id == id }) else { return false }
        return rules.indices.contains(index + offset)
    }

    private func moveRule(id: UUID, for metricID: String, by offset: Int) {
        guard var rules = model.draft.colorRules[metricID],
              let index = rules.firstIndex(where: { $0.id == id }) else { return }
        let target = index + offset
        guard rules.indices.contains(target) else { return }
        rules.swapAt(index, target)
        model.draft.colorRules[metricID] = rules
    }

    private func colorLabel(_ color: PaletteColor) -> String {
        switch color {
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
