import SwiftUI

struct SettingsView: View {
    @Bindable var model: ConfigurationModel
    let registry: MetricRegistry

    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlaceholderID: UUID?
    @State private var selectedItems: Set<UUID> = []

    var body: some View {
        VStack(spacing: 0) {
            HSplitView {
                placeholderList
                    .frame(minWidth: 160, idealWidth: 180)
                detailPane
                    .frame(minWidth: 420)
            }
            Divider()
            bottomBar
        }
        .frame(width: 660, height: 460)
        .onAppear {
            model.revert()
            selectedItems = []
            if selectedPlaceholderID == nil {
                selectedPlaceholderID = model.draft.placeholders.first?.id
            }
        }
    }

    private var placeholderList: some View {
        VStack(spacing: 8) {
            List(selection: $selectedPlaceholderID) {
                ForEach(Array(model.draft.placeholders.enumerated()), id: \.element.id) { index, placeholder in
                    Text("占位 \(index + 1)")
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
                samplingIntervalSection
            }
            .padding(8)
        } else {
            Text("请选择一个占位")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func itemList(for index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("条目")
                .font(.headline)
            List(selection: $selectedItems) {
                ForEach($model.draft.placeholders[index].items) { $item in
                    ItemEditor(item: $item, registry: registry)
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
                Text("拖拽条目可调整轮播顺序")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var samplingIntervalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("采样间隔")
                .font(.headline)
            ForEach(registry.metrics, id: \.id) { metric in
                HStack {
                    Text(metric.displayName)
                    Spacer()
                    Stepper(value: intervalBinding(for: metric), in: SamplingInterval.range, step: 1) {
                        Text("\(Int(model.draft.samplingInterval(for: metric))) 秒")
                            .monospacedDigit()
                    }
                }
            }
        }
    }

    private var bottomBar: some View {
        HStack {
            if !model.validationErrors.isEmpty {
                Text("配置存在错误，无法保存")
                    .foregroundStyle(.red)
            }
            Spacer()
            Button("取消") {
                model.revert()
                dismiss()
            }
            Button("保存") {
                if model.commit() {
                    dismiss()
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
}

private struct ItemEditor: View {
    @Binding var item: CarouselItem
    let registry: MetricRegistry

    var body: some View {
        HStack(spacing: 12) {
            Picker("指标", selection: $item.metricID) {
                ForEach(registry.metrics, id: \.id) { metric in
                    Text(metric.displayName).tag(metric.id)
                }
            }
            .frame(width: 140)

            Picker("样式", selection: $item.style) {
                ForEach(supportedStyles, id: \.self) { style in
                    Text(Self.styleLabel(style)).tag(style)
                }
            }
            .frame(width: 140)

            Stepper(value: $item.duration, in: CarouselItem.durationRange, step: 1) {
                Text("\(Int(item.duration)) 秒")
                    .monospacedDigit()
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

    private static func styleLabel(_ style: MetricStyle) -> String {
        switch style {
        case .iconAndText:
            "图标 + 文本"
        case .text:
            "仅文本"
        case .progressBar:
            "进度条"
        }
    }
}
