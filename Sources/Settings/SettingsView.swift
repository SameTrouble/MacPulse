import SwiftUI

struct SettingsView: View {
    @Bindable var model: ConfigurationModel
    let registry: MetricRegistry
    @Bindable var localization: LocalizationService
    @Bindable var loginItem: LoginItemModel
    let onClose: () -> Void

    @State private var selectedPlaceholderID: UUID?
    @State private var selectedItems: Set<UUID> = []

    var body: some View {
        VStack(spacing: 0) {
            TabView {
                placeholdersTab
                    .tabItem { Label(localization.text(.tabPlaceholders), systemImage: "square.grid.2x2") }
                colorRulesTab
                    .tabItem { Label(localization.text(.tabColorRules), systemImage: "paintpalette") }
                generalTab
                    .tabItem { Label(localization.text(.tabGeneral), systemImage: "globe") }
            }
            Divider()
            bottomBar
        }
        .frame(minWidth: 700, minHeight: 560)
        .onAppear {
            model.revert()
            loginItem.refresh()
            selectedItems = []
            if selectedPlaceholderID == nil {
                selectedPlaceholderID = model.draft.placeholders.first?.id
            }
        }
    }

    private var generalTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text(localization.text(.language))
                Picker("", selection: $localization.language) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        Text(localization.text(language.displayNameKey)).tag(language)
                    }
                }
                .labelsHidden()
                .frame(width: 140)
            }
            Toggle(localization.text(.launchAtLogin), isOn: loginItemBinding)
            Text(localization.text(.launchAtLoginHint))
                .font(.caption)
                .foregroundStyle(.secondary)
            if let error = loginItem.error {
                Text(loginItemErrorMessage(error))
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            Divider()
            samplingIntervalSection
            Spacer()
        }
        .padding(10)
    }

    private var placeholdersTab: some View {
        HSplitView {
            placeholderList
                .frame(minWidth: 160, idealWidth: 180)
            detailPane
                .frame(minWidth: 520)
        }
    }

    private var colorRulesTab: some View {
        ColorRulesEditorView(model: model, registry: registry, localization: localization)
    }

    private var placeholderList: some View {
        VStack(spacing: 8) {
            List(selection: $selectedPlaceholderID) {
                ForEach(Array(model.draft.placeholders.enumerated()), id: \.element.id) { index, placeholder in
                    Text(localization.text(.placeholderName, index + 1))
                        .tag(placeholder.id)
                }
            }
            HStack {
                Button(action: addPlaceholder) {
                    Image(systemName: "plus")
                }
                Button(action: removeSelectedPlaceholder) {
                    Image(systemName: "minus")
                }
                .disabled(model.draft.placeholders.count <= 1)
                Spacer()
            }
        }
        .padding(8)
    }

    @ViewBuilder
    private var detailPane: some View {
        if let index = selectedPlaceholderIndex {
            VStack(alignment: .leading, spacing: 12) {
                itemList(for: index)
                Divider()
                menuSection(for: index)
            }
            .padding(8)
        } else {
            Text(localization.text(.selectPlaceholder))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func itemList(for index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localization.text(.items))
                .font(.headline)
            List(selection: $selectedItems) {
                ForEach($model.draft.placeholders[index].items) { $item in
                    ItemEditor(item: $item, registry: registry, localization: localization)
                        .tag(item.id)
                }
                .onMove { source, destination in
                    model.draft.placeholders[index].items.move(fromOffsets: source, toOffset: destination)
                }
            }
            HStack {
                Button(action: { addItem(to: index) }, label: { Image(systemName: "plus") })
                    .disabled(registry.metrics.isEmpty)
                Button(action: { removeSelectedItems(from: index) }, label: { Image(systemName: "minus") })
                    .disabled(selectedItems.isEmpty)
                Spacer()
                Text(localization.text(.dragToReorder))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func menuSection(for index: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(localization.text(.menuMetrics))
                .font(.headline)
            Text(localization.text(.menuMetricsHint))
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(registry.metrics, id: \.id) { metric in
                Toggle(isOn: menuMetricBinding(for: index, metric: metric)) {
                    Text(localization.text(metric.displayNameKey))
                }
            }
        }
    }

    private func menuMetricBinding(for placeholderIndex: Int, metric: Metric) -> Binding<Bool> {
        Binding(
            get: { model.draft.placeholders[placeholderIndex].menuMetricIDs.contains(metric.id) },
            set: { isOn in
                var ids = model.draft.placeholders[placeholderIndex].menuMetricIDs
                if isOn {
                    if !ids.contains(metric.id) {
                        ids.append(metric.id)
                    }
                } else {
                    ids.removeAll { $0 == metric.id }
                }
                model.draft.placeholders[placeholderIndex].menuMetricIDs = ids
            }
        )
    }

    private var samplingIntervalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localization.text(.samplingInterval))
                .font(.headline)
            ForEach(registry.metrics, id: \.id) { metric in
                HStack {
                    Text(localization.text(metric.displayNameKey))
                    Spacer()
                    Stepper(value: intervalBinding(for: metric), in: SamplingInterval.range, step: 1) {
                        Text(localization.text(.seconds, Int(model.draft.samplingInterval(for: metric))))
                            .monospacedDigit()
                    }
                }
            }
        }
    }

    private var bottomBar: some View {
        HStack {
            if !model.validationErrors.isEmpty {
                Text(localization.text(.configurationError))
                    .foregroundStyle(.red)
            }
            Spacer()
            Button(localization.text(.cancel)) {
                model.revert()
                onClose()
            }
            Button(localization.text(.save)) {
                if model.commit() {
                    onClose()
                }
            }
            .disabled(!model.isDirty || !model.validationErrors.isEmpty)
            .keyboardShortcut(.defaultAction)
        }
        .padding(10)
    }

    private var selectedPlaceholderIndex: Int? {
        guard let selectedPlaceholderID else { return nil }
        return model.draft.placeholders.firstIndex { $0.id == selectedPlaceholderID }
    }

    private func addPlaceholder() {
        let placeholder = Placeholder(id: UUID(), items: [])
        model.draft.placeholders.append(placeholder)
        selectedPlaceholderID = placeholder.id
    }

    private func removeSelectedPlaceholder() {
        guard let index = selectedPlaceholderIndex, model.draft.placeholders.count > 1 else { return }
        model.draft.placeholders.remove(at: index)
        selectedPlaceholderID = model.draft.placeholders.first?.id
    }

    private func addItem(to placeholderIndex: Int) {
        guard let metric = registry.metrics.first,
              let style = MetricStyle.allCases.first(where: metric.supportedStyles.contains) else { return }
        guard let item = try? CarouselItem(metricID: metric.id, style: style) else { return }
        model.draft.placeholders[placeholderIndex].items.append(item)
    }

    private func removeSelectedItems(from placeholderIndex: Int) {
        model.draft.placeholders[placeholderIndex].items.removeAll { selectedItems.contains($0.id) }
        selectedItems = []
    }

    private func intervalBinding(for metric: Metric) -> Binding<TimeInterval> {
        Binding(
            get: { model.draft.samplingInterval(for: metric) },
            set: { model.draft.samplingIntervals[metric.id] = $0 }
        )
    }

    private var loginItemBinding: Binding<Bool> {
        Binding(
            get: { loginItem.isEnabled },
            set: { _ = loginItem.setEnabled($0) }
        )
    }

    private func loginItemErrorMessage(_ error: LoginItemChangeError) -> String {
        switch error {
        case .registerFailed:
            localization.text(.loginItemRegisterFailed)
        case .unregisterFailed:
            localization.text(.loginItemUnregisterFailed)
        }
    }
}

private struct ItemEditor: View {
    @Binding var item: CarouselItem
    let registry: MetricRegistry
    let localization: LocalizationProviding

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Picker(localization.text(.metric), selection: $item.metricID) {
                    ForEach(registry.metrics, id: \.id) { metric in
                        Text(localization.text(metric.displayNameKey)).tag(metric.id)
                    }
                }
                .frame(width: 140)

                Spacer()

                Stepper(value: $item.duration, in: CarouselItem.durationRange, step: 1) {
                    Text(localization.text(.seconds, Int(item.duration)))
                        .monospacedDigit()
                }
            }

            HStack(spacing: 8) {
                ForEach(supportedStyles, id: \.self) { style in
                    StyleCard(
                        style: style,
                        isSelected: item.style == style,
                        localization: localization
                    ) {
                        item.style = style
                    }
                }
            }
        }
        .onChange(of: item.metricID) { _, newID in
            guard let metric = registry.metric(id: newID), !metric.supportedStyles.contains(item.style) else { return }
            if let fallback = MetricStyle.allCases.first(where: metric.supportedStyles.contains) {
                item.style = fallback
            }
        }
    }

    private var supportedStyles: [MetricStyle] {
        guard let metric = registry.metric(id: item.metricID) else { return [] }
        return MetricStyle.allCases.filter(metric.supportedStyles.contains)
    }
}

private struct StyleCard: View {
    let style: MetricStyle
    let isSelected: Bool
    let localization: LocalizationProviding
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 6) {
                Image(nsImage: StylePreview.image(for: style))
                    .frame(height: 22)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.accentColor.opacity(0.12) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(
                        isSelected ? Color.accentColor : Color.secondary.opacity(0.4),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.borderless)
    }

    private var label: String {
        switch style {
        case .iconAndText:
            localization.text(.styleIconAndText)
        case .text:
            localization.text(.styleText)
        case .progressBar:
            localization.text(.styleProgressBar)
        }
    }
}
