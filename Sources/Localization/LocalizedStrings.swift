import Foundation

enum ResolvedLanguage {
    case zhHans
    case english
}

enum LocalizedStrings {
    private static let table: [LocalizationKey: (zhHans: String, english: String)] = [
        .tabPlaceholders: ("占位", "Placeholders"),
        .tabColorBands: ("颜色分段", "Color Bands"),
        .tabGeneral: ("通用", "General"),
        .colorBandsEnabled: ("启用变色", "Enable Color Changes"),
        .colorBandsDisabledHint: ("关闭后，所有指标一律使用默认颜色。", "When off, all metrics use the default color."),
        .colorBandsMatchHint: (
            "数值落入哪个区间就显示该区间的颜色。分段按上界自动排列，拖动滑块调整边界。",
            "A value uses the color of the range it falls into. Bands are ordered by upper bound; drag sliders to adjust boundaries."
        ),
        .colorBandsEmpty: ("无分段，始终显示默认颜色", "No bands — always uses the default color"),
        .upperBound: ("上界", "Upper Bound"),
        .color: ("颜色", "Color"),
        .colorWhite: ("白", "White"),
        .colorRed: ("红", "Red"),
        .colorOrange: ("橙", "Orange"),
        .colorYellow: ("黄", "Yellow"),
        .colorGreen: ("绿", "Green"),
        .colorBlue: ("蓝", "Blue"),
        .colorPurple: ("紫", "Purple"),
        .colorGray: ("灰", "Gray"),
        .placeholderName: ("占位 %d", "Placeholder %d"),
        .selectPlaceholder: ("请选择一个占位", "Select a placeholder"),
        .items: ("条目", "Items"),
        .dragToReorder: ("拖拽条目可调整轮播顺序", "Drag items to reorder the carousel"),
        .menuMetrics: ("下拉菜单显示", "Menu Metrics"),
        .menuMetricsHint: (
            "勾选后，下拉菜单固定显示这些指标的详情；不勾选则只显示偏好设置和退出。",
            "Checked metrics show their details in the dropdown menu; when none are checked, only Preferences and Quit show."
        ),
        .samplingInterval: ("采样间隔", "Sampling Interval"),
        .seconds: ("%d 秒", "%d s"),
        .configurationError: ("配置存在错误，无法保存", "The configuration has errors and cannot be saved"),
        .cancel: ("取消", "Cancel"),
        .save: ("保存", "Save"),
        .metric: ("指标", "Metric"),
        .style: ("样式", "Style"),
        .styleIconAndText: ("图标 + 文本", "Icon + Text"),
        .styleText: ("仅文本", "Text Only"),
        .styleProgressBar: ("进度条", "Progress Bar"),
        .language: ("语言", "Language"),
        .languageSystem: ("跟随系统", "Follow System"),
        .languageChinese: ("中文", "中文"),
        .languageEnglish: ("English", "English"),
        .launchAtLogin: ("开机自启", "Launch at Login"),
        .launchAtLoginHint: (
            "开启后，重启电脑 MacPulse 会自动启动并仅驻留菜单栏。请将 MacPulse 放入“应用程序”文件夹后再开启。",
            "When enabled, MacPulse launches automatically on restart and lives only in the menu bar. "
                + "Move MacPulse into the Applications folder before enabling."
        ),
        .loginItemRegisterFailed: ("开启开机自启失败", "Failed to enable launch at login"),
        .loginItemUnregisterFailed: ("关闭开机自启失败", "Failed to disable launch at login"),
        .menuPreferences: ("偏好设置…", "Preferences…"),
        .menuQuit: ("退出 MacPulse", "Quit MacPulse"),
        .metricCPUName: ("CPU", "CPU"),
        .metricMemoryName: ("内存", "Memory"),
        .metricGPUName: ("GPU", "GPU"),
        .metricCPUTemperatureName: ("CPU 温度", "CPU Temperature"),
        .metricGPUTemperatureName: ("GPU 温度", "GPU Temperature"),
        .metricTemperatureName: ("温度", "Temperature"),
        .cpuOverall: ("总体 CPU：%@", "Overall CPU: %@"),
        .cpuCore: ("核心 %d：%@", "Core %d: %@"),
        .memoryUsed: ("已用：%@", "Used: %@"),
        .memoryTotal: ("总量：%@", "Total: %@"),
        .gpuUtilization: ("GPU 利用率：%@", "GPU utilization: %@"),
        .temperatureCPU: ("CPU %@", "CPU %@"),
        .temperatureGPU: ("GPU %@", "GPU %@")
    ]

    static func translation(for key: LocalizationKey, in language: ResolvedLanguage) -> String {
        guard let entry = table[key] else { return key.rawValue }
        switch language {
        case .zhHans:
            return entry.zhHans
        case .english:
            return entry.english
        }
    }
}
