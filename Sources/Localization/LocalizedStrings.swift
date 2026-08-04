import Foundation

enum ResolvedLanguage {
    case zhHans
    case english
}

enum LocalizedStrings {
    private static let table: [LocalizationKey: (zhHans: String, english: String)] = [
        .tabPlaceholders: ("占位", "Placeholders"),
        .tabColorRules: ("变色规则", "Color Rules"),
        .tabGeneral: ("通用", "General"),
        .colorRulesEnabled: ("启用变色", "Enable Color Changes"),
        .colorRulesDisabledHint: ("关闭后，所有指标一律使用默认颜色。", "When off, all metrics use the default color."),
        .colorRulesMatchHint: (
            "规则自上而下匹配，数值达到阈值的第一条规则生效，可拖动箭头调整顺序。",
            "Rules are matched top to bottom; the first rule whose value reaches the threshold applies. Drag the arrows to reorder."
        ),
        .colorRulesEmpty: ("无规则，始终显示默认颜色", "No rules — always uses the default color"),
        .threshold: ("阈值", "Threshold"),
        .color: ("颜色", "Color"),
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
        .metricTemperatureName: ("温度", "Temperature"),
        .cpuOverall: ("总体 CPU：%@", "Overall CPU: %@"),
        .cpuCore: ("核心 %d：%@", "Core %d: %@"),
        .memoryUsed: ("已用：%@", "Used: %@"),
        .memoryTotal: ("总量：%@", "Total: %@"),
        .memoryPressure: ("压力等级：%@", "Pressure: %@"),
        .memoryPressureNormal: ("正常", "Normal"),
        .memoryPressureWarning: ("警告", "Warning"),
        .memoryPressureCritical: ("严重", "Critical"),
        .gpuUtilization: ("GPU 利用率：%@", "GPU utilization: %@"),
        .temperatureCPU: ("CPU：%@", "CPU: %@"),
        .temperatureGPU: ("GPU：%@", "GPU: %@")
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
