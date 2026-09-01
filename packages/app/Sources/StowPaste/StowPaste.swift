import AppKit
import Darwin
import Foundation
import ServiceManagement
import SwiftUI
import UniformTypeIdentifiers

enum ClipKind: String, Codable, CaseIterable, Identifiable {
    case text
    case image
    case file

    var id: String { rawValue }

    var label: String {
        switch self {
        case .text: return L10n.text
        case .image: return L10n.image
        case .file: return L10n.file
        }
    }

    var symbol: String {
        switch self {
        case .text: return "text.alignleft"
        case .image: return "photo"
        case .file: return "doc"
        }
    }
}

enum ClipTab: String, Codable, CaseIterable, Identifiable {
    case all
    case text
    case image
    case file
    case favorites

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return L10n.all
        case .text: return L10n.text
        case .image: return L10n.image
        case .file: return L10n.file
        case .favorites: return L10n.favorites
        }
    }

    var symbol: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .text: return "text.alignleft"
        case .image: return "photo"
        case .file: return "doc"
        case .favorites: return "star"
        }
    }
}

struct CustomGroup: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var symbol: String
    var itemIDs: [UUID]
}

enum HistoryRetentionPeriod: String, Codable, CaseIterable, Identifiable {
    case week
    case month
    case quarter
    case halfYear
    case year
    case threeYears
    case unlimited

    var id: String { rawValue }

    var label: String {
        switch self {
        case .week: return L10n.historyRetentionWeek
        case .month: return L10n.historyRetentionMonth
        case .quarter: return L10n.historyRetentionQuarter
        case .halfYear: return L10n.historyRetentionHalfYear
        case .year: return L10n.historyRetentionYear
        case .threeYears: return L10n.historyRetentionThreeYears
        case .unlimited: return L10n.historyRetentionUnlimited
        }
    }

    func cutoffDate(from now: Date = Date()) -> Date? {
        switch self {
        case .week:
            return Calendar.current.date(byAdding: .day, value: -7, to: now)
        case .month:
            return Calendar.current.date(byAdding: .month, value: -1, to: now)
        case .quarter:
            return Calendar.current.date(byAdding: .month, value: -3, to: now)
        case .halfYear:
            return Calendar.current.date(byAdding: .month, value: -6, to: now)
        case .year:
            return Calendar.current.date(byAdding: .year, value: -1, to: now)
        case .threeYears:
            return Calendar.current.date(byAdding: .year, value: -3, to: now)
        case .unlimited:
            return nil
        }
    }

    func isShorter(than other: HistoryRetentionPeriod) -> Bool {
        retentionRank < other.retentionRank
    }

    private var retentionRank: Int {
        switch self {
        case .week: return 1
        case .month: return 2
        case .quarter: return 3
        case .halfYear: return 4
        case .year: return 5
        case .threeYears: return 6
        case .unlimited: return 7
        }
    }
}

enum L10n {
    private static var isChinese: Bool {
        Locale.preferredLanguages.first?.lowercased().hasPrefix("zh") == true
    }

    static func text(_ zh: String, _ en: String) -> String {
        isChinese ? zh : en
    }

    static var all: String { text("全部", "All") }
    static var text: String { text("文本", "Text") }
    static var image: String { text("图片", "Image") }
    static var imageItem: String { text("图片剪切板", "Image Clipboard") }
    static var file: String { text("文件", "File") }
    static var files: String { text("文件", "Files") }
    static var favorites: String { text("收藏", "Favorites") }
    static var copy: String { text("复制", "Copy") }
    static var paste: String { text("粘贴", "Paste") }
    static var settings: String { text("设置", "Settings") }
    static var openClipboard: String { text("打开剪切板", "Open Clipboard") }
    static var showMainPanel: String { text("显示主面板", "Show Main Panel") }
    static var grantAccessibility: String { text("授权辅助功能", "Grant Accessibility") }
    static var refreshClipboard: String { text("刷新剪切板", "Refresh Clipboard") }
    static var clearHistory: String { text("清空历史", "Clear History") }
    static var empty: String { text("无内容", "No items") }
    static var pin: String { text("置顶", "Pin") }
    static var unpin: String { text("取消置顶", "Unpin") }
    static var pinToScreen: String { text("钉在屏幕", "Pin to screen") }
    static var unpinFromScreen: String { text("取消钉在屏幕", "Unpin from screen") }
    static var favorite: String { text("收藏", "Favorite") }
    static var unfavorite: String { text("取消收藏", "Unfavorite") }
    static var delete: String { text("删除", "Delete") }
    static var close: String { text("关闭", "Close") }
    static var accessibilityNeeded: String { text("需要辅助功能权限才能在粘贴时唤起面板", "Accessibility permission is required to show the panel when pasting") }
    static var authorize: String { text("授权", "Authorize") }
    static var done: String { text("完成", "Done") }
    static var add: String { text("添加", "Add") }
    static var cancel: String { text("取消", "Cancel") }
    static var edit: String { text("编辑", "Edit") }
    static var groupList: String { text("分组列表", "Groups") }
    static var back: String { text("返回", "Back") }
    static var permissions: String { text("权限", "Permissions") }
    static var accessibilityGranted: String { text("辅助功能已授权", "Accessibility granted") }
    static var accessibilityRequired: String { text("需要辅助功能权限", "Accessibility required") }
    static var openAuthorization: String { text("打开授权", "Open Authorization") }
    static var basics: String { text("基础", "Basics") }
    static var historyLimit: String { text("历史上限", "History limit") }
    static var historyRetentionWeek: String { text("一周内", "Within one week") }
    static var historyRetentionMonth: String { text("一个月内", "Within one month") }
    static var historyRetentionQuarter: String { text("一个季度内", "Within one quarter") }
    static var historyRetentionHalfYear: String { text("半年内", "Within half a year") }
    static var historyRetentionYear: String { text("一年内", "Within one year") }
    static var historyRetentionThreeYears: String { text("三年内", "Within three years") }
    static var historyRetentionUnlimited: String { text("无限制", "Unlimited") }
    static var historyRetentionConfirmTitle: String { text("缩小历史范围？", "Narrow history range?") }
    static var historyRetentionConfirmMessage: String { text("此操作会移除超出新时间范围的普通历史数据，收藏、置顶和自定义分组中的内容不会受影响。", "This will remove ordinary history outside the new time range. Favorites, pinned items, and custom group items will not be affected.") }
    static var continueAction: String { text("继续", "Continue") }
    static var theme: String { text("主题", "Theme") }
    static var launchAtLogin: String { text("开机自动启动", "Launch at login") }
    static var customTheme: String { text("自定义主题", "Custom theme") }
    static var generateTheme: String { text("生成主题", "Generate theme") }
    static var deleteTheme: String { text("删除主题", "Delete theme") }
    static var themeAnalyzingPrompt: String { text("正在分析你的主题偏好...", "Analyzing your theme direction...") }
    static var themeGeneratingOptions: String { text("正在生成多套配色方案...", "Generating color options...") }
    static var themePreparingPreview: String { text("正在整理主题预览...", "Preparing theme previews...") }
    static var themeGenerated: String { text("主题方案已生成", "Theme options generated") }
    static var apply: String { text("应用", "Apply") }
    static var save: String { text("保存", "Save") }
    static var hotkey: String { text("快捷键", "Hotkey") }
    static var recordHotkey: String { text("录制快捷键", "Record hotkey") }
    static var recordingHotkey: String { text("按下快捷键...", "Press shortcut...") }
    static var system: String { text("系统", "System") }
    static var light: String { text("浅色", "Light") }
    static var dark: String { text("深色", "Dark") }
    static var addGroup: String { text("添加分组", "Add Group") }
    static var manageGroups: String { text("管理分组", "Manage Groups") }
    static var groupName: String { text("分组名", "Group Name") }
    static var chooseIcon: String { text("选择图标", "Choose Icon") }
    static var addToGroup: String { text("添加至分组", "Add to Group") }
    static var noGroups: String { text("暂无分组", "No Groups") }
    static var reorder: String { text("拖拽排序", "Drag to reorder") }
    static func doublePasteTip(_ hotkey: String) -> String {
        text("再次按下 \(hotkey) 直接粘贴内容", "Press \(hotkey) again to paste directly")
    }
    static var neverShow: String { text("不再提示", "Don't show again") }
    static var copiedFromPrefix: String { text("复制自", "Copied from") }
    static func copiedFrom(_ appName: String) -> String { text("复制自 \(appName)", "Copied from \(appName)") }
    static var justNow: String { text("刚刚", "Just now") }
    static var yesterday: String { text("昨天", "Yesterday") }
    static var dayBeforeYesterday: String { text("前天", "The day before yesterday") }
    static var lastMonth: String { text("上个月", "Last month") }
    static func minutesAgo(_ count: Int) -> String {
        isChinese ? "\(count) 分钟前" : "\(count)m ago"
    }
    static func hoursAgo(_ count: Int) -> String {
        isChinese ? "\(count) 小时前" : "\(count)h ago"
    }
    static func daysAgo(_ count: Int) -> String {
        isChinese ? "\(count) 天前" : "\(count)d ago"
    }
    static func monthsAgo(_ count: Int) -> String {
        isChinese ? "\(count) 个月前" : "\(count)mo ago"
    }
    static func imageSummary(width: Int?, height: Int?) -> String {
        if let width, let height {
            return text("图片 \(width) x \(height)", "Image \(width) x \(height)")
        }
        return imageItem
    }
    static func fileCount(_ count: Int, first: String) -> String {
        isChinese ? "\(first) 等 \(count) 个文件" : "\(first) and \(count - 1) more files"
    }
    static func fileListSuffix(_ remaining: Int) -> String {
        isChinese ? "另有 \(remaining) 个文件" : "\(remaining) more files"
    }
}

enum RelativeTimeFormatter {
    static func relativeTime(from date: Date, now: Date = Date()) -> String {
        let seconds = max(0, Int(now.timeIntervalSince(date)))
        if seconds < 60 {
            return L10n.justNow
        }

        let minutes = seconds / 60
        if minutes < 60 {
            return L10n.minutesAgo(minutes)
        }

        let hours = minutes / 60
        if hours < 24 {
            return L10n.hoursAgo(hours)
        }

        let calendar = Calendar.current
        if calendar.isDateInYesterday(date) {
            return L10n.yesterday
        }
        if let dayBeforeYesterday = calendar.date(byAdding: .day, value: -2, to: calendar.startOfDay(for: now)),
           calendar.isDate(date, inSameDayAs: dayBeforeYesterday) {
            return L10n.dayBeforeYesterday
        }

        let days = max(1, calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: now)).day ?? 1)
        if days < 30 {
            return L10n.daysAgo(days)
        }

        let monthDifference = max(1, calendar.dateComponents([.month], from: date, to: now).month ?? 1)
        if monthDifference == 1 {
            return L10n.lastMonth
        }
        return L10n.monthsAgo(monthDifference)
    }
}

struct CustomThemeSettings: Codable, Equatable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var lightBackground: String
    var darkBackground: String
    var panelTint: String
    var accent: String
    var subtleFill: String
    var primary: String
    var secondary: String
    var textPrimary: String
    var textSecondary: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case lightBackground
        case darkBackground
        case panelTint
        case accent
        case subtleFill
        case primary
        case secondary
        case textPrimary
        case textSecondary
    }

    init(
        id: String = UUID().uuidString,
        name: String,
        lightBackground: String,
        darkBackground: String,
        panelTint: String,
        accent: String,
        subtleFill: String,
        primary: String? = nil,
        secondary: String? = nil,
        textPrimary: String? = nil,
        textSecondary: String? = nil
    ) {
        self.id = id
        self.name = name
        self.lightBackground = lightBackground
        self.darkBackground = darkBackground
        self.panelTint = panelTint
        self.accent = accent
        self.subtleFill = subtleFill
        self.primary = primary ?? accent
        self.secondary = secondary ?? subtleFill
        self.textPrimary = textPrimary ?? "#1F2328"
        self.textSecondary = textSecondary ?? "#6B7280"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        name = try container.decode(String.self, forKey: .name)
        lightBackground = try container.decode(String.self, forKey: .lightBackground)
        darkBackground = try container.decode(String.self, forKey: .darkBackground)
        panelTint = try container.decode(String.self, forKey: .panelTint)
        accent = try container.decode(String.self, forKey: .accent)
        subtleFill = try container.decode(String.self, forKey: .subtleFill)
        primary = try container.decodeIfPresent(String.self, forKey: .primary) ?? accent
        secondary = try container.decodeIfPresent(String.self, forKey: .secondary) ?? subtleFill
        textPrimary = try container.decodeIfPresent(String.self, forKey: .textPrimary) ?? "#1F2328"
        textSecondary = try container.decodeIfPresent(String.self, forKey: .textSecondary) ?? "#6B7280"
    }
}

extension CustomThemeSettings {
    static let fallback = CustomThemeSettings(
        name: L10n.customTheme,
        lightBackground: "#F8F8F6",
        darkBackground: "#171A1F",
        panelTint: "#FFFFFF",
        accent: "#2F6F9F",
        subtleFill: "#EDEBE6",
        primary: "#2F6F9F",
        secondary: "#8A9A5B",
        textPrimary: "#1F2328",
        textSecondary: "#6B7280"
    )
}

struct AppSettings: Codable, Equatable {
    var maxHistoryItems = 1000
    var historyRetentionPeriod: HistoryRetentionPeriod = .quarter
    var theme = "system"
    var customThemes: [CustomThemeSettings] = []
    var hideDoublePasteHint = false
    var usedDoublePaste = false
    var pastePanelHotkey = HotkeySettings()

    enum CodingKeys: String, CodingKey {
        case maxHistoryItems
        case historyRetentionPeriod
        case theme
        case customThemes
        case hideDoublePasteHint
        case usedDoublePaste
        case pastePanelHotkey
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        maxHistoryItems = try container.decodeIfPresent(Int.self, forKey: .maxHistoryItems) ?? 1000
        historyRetentionPeriod = try container.decodeIfPresent(HistoryRetentionPeriod.self, forKey: .historyRetentionPeriod) ?? .quarter
        theme = try container.decodeIfPresent(String.self, forKey: .theme) ?? "system"
        customThemes = try container.decodeIfPresent([CustomThemeSettings].self, forKey: .customThemes) ?? []
        hideDoublePasteHint = try container.decodeIfPresent(Bool.self, forKey: .hideDoublePasteHint) ?? false
        usedDoublePaste = try container.decodeIfPresent(Bool.self, forKey: .usedDoublePaste) ?? false
        pastePanelHotkey = try container.decodeIfPresent(HotkeySettings.self, forKey: .pastePanelHotkey) ?? HotkeySettings()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(maxHistoryItems, forKey: .maxHistoryItems)
        try container.encode(historyRetentionPeriod, forKey: .historyRetentionPeriod)
        try container.encode(theme, forKey: .theme)
        try container.encode(customThemes, forKey: .customThemes)
        try container.encode(hideDoublePasteHint, forKey: .hideDoublePasteHint)
        try container.encode(usedDoublePaste, forKey: .usedDoublePaste)
        try container.encode(pastePanelHotkey, forKey: .pastePanelHotkey)
    }

    var colorScheme: ColorScheme? {
        switch theme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var selectedCustomTheme: CustomThemeSettings? {
        guard theme.hasPrefix("custom:") else { return nil }
        let id = String(theme.dropFirst("custom:".count))
        return customThemes.first { $0.id == id }
    }
}

@MainActor
final class SystemAppearance: ObservableObject {
    @Published private(set) var colorScheme: ColorScheme
    private var observer: NSKeyValueObservation?
    private weak var application: NSApplication?

    init(application: NSApplication? = nil) {
        let resolvedApplication = application ?? .shared
        self.application = resolvedApplication
        colorScheme = Self.currentColorScheme(application: resolvedApplication)
        observer = resolvedApplication.observe(\.effectiveAppearance, options: [.new]) { [weak self] _, _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }

    func refresh() {
        colorScheme = Self.currentColorScheme(application: application ?? .shared)
    }

    private static func currentColorScheme(application: NSApplication) -> ColorScheme {
        application.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? .dark : .light
    }
}

struct HotkeySettings: Codable, Equatable {
    var keyCode: Int64 = 0x37
    var command = false
    var option = false
    var control = false
    var shift = false
    var doubleTap = true

    enum CodingKeys: String, CodingKey {
        case keyCode
        case command
        case option
        case control
        case shift
        case doubleTap
    }

    init(
        keyCode: Int64 = 0x37,
        command: Bool = false,
        option: Bool = false,
        control: Bool = false,
        shift: Bool = false,
        doubleTap: Bool = true
    ) {
        self.keyCode = keyCode
        self.command = command
        self.option = option
        self.control = control
        self.shift = shift
        self.doubleTap = doubleTap
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Keep legacy fallback values for partially populated persisted settings.
        // A missing whole hotkey object still uses the new double-Command default.
        keyCode = try container.decodeIfPresent(Int64.self, forKey: .keyCode) ?? 0x09
        command = try container.decodeIfPresent(Bool.self, forKey: .command) ?? true
        option = try container.decodeIfPresent(Bool.self, forKey: .option) ?? false
        control = try container.decodeIfPresent(Bool.self, forKey: .control) ?? false
        shift = try container.decodeIfPresent(Bool.self, forKey: .shift) ?? false
        doubleTap = try container.decodeIfPresent(Bool.self, forKey: .doubleTap) ?? false
    }

    var displayText: String {
        if doubleTap {
            let key = Self.keyName(for: keyCode)
            return "\(key) \(key)"
        }
        var parts: [String] = []
        if control { parts.append("⌃") }
        if option { parts.append("⌥") }
        if shift { parts.append("⇧") }
        if command { parts.append("⌘") }
        parts.append(Self.keyName(for: keyCode))
        return parts.joined()
    }

    static func from(event: NSEvent) -> HotkeySettings? {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let hasModifier = flags.contains(.command) || flags.contains(.option) || flags.contains(.control) || flags.contains(.shift)
        guard hasModifier else { return nil }
        return HotkeySettings(
            keyCode: Int64(event.keyCode),
            command: flags.contains(.command),
            option: flags.contains(.option),
            control: flags.contains(.control),
            shift: flags.contains(.shift)
        )
    }

    static func doubleTap(keyCode: UInt16) -> HotkeySettings {
        HotkeySettings(
            keyCode: Int64(keyCode),
            command: false,
            option: false,
            control: false,
            shift: false,
            doubleTap: true
        )
    }

    static func keyName(for keyCode: Int64) -> String {
        switch keyCode {
        case 0x00: return "A"
        case 0x01: return "S"
        case 0x02: return "D"
        case 0x03: return "F"
        case 0x04: return "H"
        case 0x05: return "G"
        case 0x06: return "Z"
        case 0x07: return "X"
        case 0x08: return "C"
        case 0x09: return "V"
        case 0x0B: return "B"
        case 0x0C: return "Q"
        case 0x0D: return "W"
        case 0x0E: return "E"
        case 0x0F: return "R"
        case 0x10: return "Y"
        case 0x11: return "T"
        case 0x1F: return "O"
        case 0x20: return "U"
        case 0x22: return "I"
        case 0x23: return "P"
        case 0x25: return "L"
        case 0x26: return "J"
        case 0x28: return "K"
        case 0x2D: return "N"
        case 0x2E: return "M"
        case 0x12: return "1"
        case 0x13: return "2"
        case 0x14: return "3"
        case 0x15: return "4"
        case 0x17: return "5"
        case 0x16: return "6"
        case 0x1A: return "7"
        case 0x1C: return "8"
        case 0x19: return "9"
        case 0x1D: return "0"
        case 0x31: return "Space"
        case 0x24: return "Return"
        case 0x35: return "Esc"
        case 0x36, 0x37: return "⌘"
        case 0x38, 0x3C: return "⇧"
        case 0x3A, 0x3D: return "⌥"
        case 0x3B, 0x3E: return "⌃"
        default: return "#\(keyCode)"
        }
    }
}

private struct HotkeySnapshot: Equatable {
    var keyCode: Int64
    var command: Bool
    var option: Bool
    var control: Bool
    var shift: Bool
    var doubleTap: Bool

    init(settings: HotkeySettings) {
        keyCode = settings.keyCode
        command = settings.command
        option = settings.option
        control = settings.control
        shift = settings.shift
        doubleTap = settings.doubleTap
    }
}

enum BrandStorage {
    static let currentDirectoryName = "StowPaste"
    private static let legacyDirectoryNames = [
        "Stow" + "lark",
        "Clip" + "let",
        "Cilplet",
        "ClipboardDock",
    ]
    private static let migratableItems = ["state.json", "Images"]

    static func prepareApplicationSupport(in supportRoot: URL? = nil) -> URL {
        let root = supportRoot
            ?? ProcessInfo.processInfo.environment["STOWPASTE_APPLICATION_SUPPORT_DIR"]
                .flatMap { path in
                    path.hasPrefix("/") ? URL(fileURLWithPath: path, isDirectory: true) : nil
                }
            ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let destination = root.appendingPathComponent(currentDirectoryName, isDirectory: true)
        let fileManager = FileManager.default
        try? fileManager.createDirectory(at: destination, withIntermediateDirectories: true)

        for directoryName in legacyDirectoryNames {
            let legacyDirectory = root.appendingPathComponent(directoryName, isDirectory: true)
            guard fileManager.fileExists(atPath: legacyDirectory.path) else { continue }

            for itemName in migratableItems {
                let source = legacyDirectory.appendingPathComponent(itemName)
                let target = destination.appendingPathComponent(itemName)
                guard fileManager.fileExists(atPath: source.path),
                      !fileManager.fileExists(atPath: target.path) else { continue }
                try? fileManager.copyItem(at: source, to: target)
            }
        }

        return destination
    }
}

struct AIThemeOption: Codable, Equatable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var rationale: String
    var theme: CustomThemeSettings

    enum CodingKeys: String, CodingKey {
        case name
        case rationale
        case theme
    }
}

struct ClipboardSource: Codable, Equatable {
    var appName: String
    var bundleIdentifier: String
    var pageTitle: String? = nil
    var pageURL: String? = nil

    static func currentCopySource() -> ClipboardSource? {
        guard let app = NSWorkspace.shared.frontmostApplication,
              app.processIdentifier != NSRunningApplication.current.processIdentifier else { return nil }
        let name = (app.localizedName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let bundle = (app.bundleIdentifier ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty || !bundle.isEmpty else { return nil }
        return ClipboardSource(appName: name, bundleIdentifier: bundle)
    }
}

struct ClipboardEntry: Identifiable, Codable, Equatable {
    var id: UUID
    var kind: ClipKind
    var title: String
    var preview: String
    var signature: String
    var createdAt: Date
    var updatedAt: Date
    var pinnedTabs: Set<ClipTab>
    var text: String?
    var fileURLs: [URL]
    var imagePNG: Data?
    var imageFileName: String? = nil
    var imageThumbnailPNG: Data? = nil
    var imageWidth: Int?
    var imageHeight: Int?
    var source: ClipboardSource? = nil
    var isTransient: Bool?

    var isText: Bool { kind == .text && text?.isEmpty == false }
    var hasDefaultTitle: Bool {
        title == defaultTitle
    }

    var defaultTitle: String {
        switch kind {
        case .text:
            return L10n.text
        case .image:
            return L10n.image
        case .file:
            let names = fileURLs.map(\.lastPathComponent).filter { !$0.isEmpty }
            let first = names.first ?? L10n.file
            return fileURLs.count == 1 ? first : L10n.fileCount(fileURLs.count, first: first)
        }
    }
}

struct FavoriteOrderItem: Codable, Equatable {
    var id: UUID
    var rank: Int
}

struct PersistedState: Codable {
    var settings: AppSettings
    var history: [ClipboardEntry]
    var activeTab: ClipTab
    var selectedID: UUID?
    var lastSignature: String
    var favoriteOrder: [FavoriteOrderItem]?
    var customGroups: [CustomGroup]?
    var containedRemovedFeatureState = false

    enum CodingKeys: String, CodingKey {
        case settings
        case history
        case activeTab
        case selectedID
        case lastSignature
        case favoriteOrder
        case customGroups
        case translationCache
        case smartItems
        case smartDataSchemaVersion
    }

    init(
        settings: AppSettings,
        history: [ClipboardEntry],
        activeTab: ClipTab,
        selectedID: UUID?,
        lastSignature: String,
        favoriteOrder: [FavoriteOrderItem]?,
        customGroups: [CustomGroup]?
    ) {
        self.settings = settings
        self.history = history
        self.activeTab = activeTab
        self.selectedID = selectedID
        self.lastSignature = lastSignature
        self.favoriteOrder = favoriteOrder
        self.customGroups = customGroups
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        settings = try container.decode(AppSettings.self, forKey: .settings)
        history = try container.decode([ClipboardEntry].self, forKey: .history)
        activeTab = try container.decode(ClipTab.self, forKey: .activeTab)
        selectedID = try container.decodeIfPresent(UUID.self, forKey: .selectedID)
        lastSignature = try container.decodeIfPresent(String.self, forKey: .lastSignature) ?? ""
        favoriteOrder = try container.decodeIfPresent([FavoriteOrderItem].self, forKey: .favoriteOrder)
        customGroups = try container.decodeIfPresent([CustomGroup].self, forKey: .customGroups)
        // Current builds never decode retired payloads. This avoids loading historical
        // smart indexes that may duplicate large clipboard entries hundreds of times.
        containedRemovedFeatureState = container.contains(.translationCache)
            || container.contains(.smartItems)
            || container.contains(.smartDataSchemaVersion)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(settings, forKey: .settings)
        try container.encode(history, forKey: .history)
        try container.encode(activeTab, forKey: .activeTab)
        try container.encodeIfPresent(selectedID, forKey: .selectedID)
        try container.encode(lastSignature, forKey: .lastSignature)
        try container.encodeIfPresent(favoriteOrder, forKey: .favoriteOrder)
        try container.encodeIfPresent(customGroups, forKey: .customGroups)
    }
}

@MainActor
final class AppModel: ObservableObject {
    static let internalEntryDragType = UTType(exportedAs: "store.aiware.stowpaste.entry-drag")
    static let entryDropTypes: [UTType] = [internalEntryDragType, .text, .fileURL, .image]
    private static let legacyDefaultImageGroupID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    @Published var settings = AppSettings()
    @Published var history: [ClipboardEntry] = []
    @Published var activeTab: ClipTab = .all
    @Published var selectedID: UUID?
    @Published var favoriteOrder: [UUID] = []
    @Published var customGroups: [CustomGroup] = []
    @Published var activeGroupID: UUID?
    @Published var toastMessage: String?
    @Published var overlayVisible = false
    @Published var panelPinned = false
    @Published var panelContentSize = PanelMetrics.defaultContentSize()
    @Published var accessibilityTrusted = AXIsProcessTrusted()
    @Published var titleEditing = false
    @Published var themeOptions: [AIThemeOption] = []
    @Published var themeGenerationStatus = ""
    @Published var themeGenerationError: String?
    @Published var themeGenerationLoading = false
    @Published var currentClipboardSignature: String?
    let systemAppearance = SystemAppearance()

    private let pasteboard = NSPasteboard.general
    private var changeCount = NSPasteboard.general.changeCount
    private var pendingSignature: String?
    private var pollTimer: Timer?
    private let storeURL: URL
    private let imageStoreDirectory: URL

    init(
        storeURL overrideStoreURL: URL? = nil,
        startPolling shouldStartPolling: Bool = true
    ) {
        if let overrideStoreURL {
            storeURL = overrideStoreURL
            imageStoreDirectory = overrideStoreURL
                .deletingLastPathComponent()
                .appendingPathComponent("Images", isDirectory: true)
        } else {
            let support = BrandStorage.prepareApplicationSupport()
            storeURL = support.appendingPathComponent("state.json")
            imageStoreDirectory = support.appendingPathComponent("Images", isDirectory: true)
        }
        try? FileManager.default.createDirectory(at: imageStoreDirectory, withIntermediateDirectories: true)
        load()
        if shouldStartPolling {
            startPolling()
        }
    }

    var visibleHistory: [ClipboardEntry] {
        history
            .filter { entry in
                if let activeGroupID {
                    return customGroups.first { $0.id == activeGroupID }?.itemIDs.contains(entry.id) == true
                }
                switch activeTab {
                case .all: return true
                case .favorites: return favoriteOrder.contains(entry.id)
                case .text: return entry.kind == .text
                case .image: return entry.kind == .image || isImageFileEntry(entry)
                case .file: return entry.kind == .file && !isImageFileEntry(entry)
                }
            }
            .sorted { left, right in
                if let activeGroupID {
                    return groupItemRank(left.id, in: activeGroupID) < groupItemRank(right.id, in: activeGroupID)
                }
                if activeTab == .favorites {
                    return favoriteRank(left.id) < favoriteRank(right.id)
                }
                let leftPinned = left.pinnedTabs.contains(activeTab)
                let rightPinned = right.pinnedTabs.contains(activeTab)
                if leftPinned != rightPinned {
                    return leftPinned
                }
                return left.updatedAt > right.updatedAt
            }
    }

    var selectedEntry: ClipboardEntry? {
        guard let selectedID else { return visibleHistory.first }
        return visibleHistory.first { $0.id == selectedID } ?? visibleHistory.first
    }

    var latestTextEntry: ClipboardEntry? {
        history.first { $0.isText }
    }

    private func favoriteRank(_ id: UUID) -> Int {
        favoriteOrder.firstIndex(of: id) ?? Int.max
    }

    private func groupItemRank(_ id: UUID, in groupID: UUID) -> Int {
        customGroups.first { $0.id == groupID }?.itemIDs.firstIndex(of: id) ?? Int.max
    }

    func isFavorite(_ entry: ClipboardEntry) -> Bool {
        favoriteOrder.contains(entry.id)
    }

    func count(for tab: ClipTab) -> Int {
        switch tab {
        case .all: return history.count
        case .favorites: return history.filter { favoriteOrder.contains($0.id) }.count
        case .text: return history.filter { $0.kind == .text }.count
        case .image: return history.filter { $0.kind == .image || isImageFileEntry($0) }.count
        case .file: return history.filter { $0.kind == .file && !isImageFileEntry($0) }.count
        }
    }

    func canPin(to tab: ClipTab) -> Bool {
        return tab != .image && tab != .file
    }

    private func isImageFileEntry(_ entry: ClipboardEntry) -> Bool {
        guard entry.kind == .file, !entry.fileURLs.isEmpty else { return false }
        return entry.fileURLs.allSatisfy { url in
            if let type = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType {
                return type.conforms(to: .image)
            }
            return UTType(filenameExtension: url.pathExtension)?.conforms(to: .image) == true
        }
    }

    func showOverlay() {
        activeTab = .all
        activeGroupID = nil
        captureCurrentPasteboard()
        accessibilityTrusted = AXIsProcessTrusted()
        panelContentSize = PanelMetrics.clampedContentSize(panelContentSize)
        titleEditing = false
        overlayVisible = true
        if selectedID == nil || !visibleHistory.contains(where: { $0.id == selectedID }) {
            selectedID = visibleHistory.first?.id
        }
    }

    func hideOverlay() {
        titleEditing = false
        overlayVisible = false
    }

    func moveSelection(delta: Int) {
        let items = visibleHistory
        guard !items.isEmpty else { return }
        let current = selectedID.flatMap { id in items.firstIndex { $0.id == id } } ?? 0
        let next = min(max(current + delta, 0), items.count - 1)
        selectedID = items[next].id
    }

    func pasteVisibleItem(at index: Int, using controller: AppController?) {
        let items = visibleHistory
        guard items.indices.contains(index) else { return }
        selectedID = items[index].id
        paste(items[index], using: controller)
    }

    func select(_ entry: ClipboardEntry) {
        selectedID = entry.id
        recordClick(on: entry)
    }

    func paste(_ entry: ClipboardEntry, using controller: AppController?) {
        recordClick(on: entry)
        write(entry)
        controller?.sendPasteShortcutIgnoringNext()
    }

    func pasteText(_ text: String, using controller: AppController?) {
        let normalized = normalize(text).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return }
        pasteboard.clearContents()
        pasteboard.setString(normalized, forType: .string)
        pendingSignature = "text:\(normalized)"
        changeCount = pasteboard.changeCount
        controller?.sendPasteShortcutIgnoringNext()
    }

    func dragProvider(for entry: ClipboardEntry) -> NSItemProvider {
        let provider: NSItemProvider
        switch entry.kind {
        case .text:
            let text = entry.text ?? entry.preview
            provider = NSItemProvider(object: text as NSString)
        case .file:
            if let url = entry.fileURLs.first,
               let provider = NSItemProvider(contentsOf: url) {
                self.registerInternalEntryDrag(entry.id, on: provider)
                return provider
            }
            provider = NSItemProvider(object: entry.preview as NSString)
        case .image:
            if let imagePNG = loadImageData(for: entry),
               let image = NSImage(data: imagePNG) {
                provider = NSItemProvider(object: image as NSImage)
                provider.registerDataRepresentation(forTypeIdentifier: UTType.png.identifier, visibility: .all) { completion in
                    completion(imagePNG, nil)
                    return nil
                }
            } else {
                provider = NSItemProvider(object: entry.preview as NSString)
            }
        }
        registerInternalEntryDrag(entry.id, on: provider)
        return provider
    }

    private func registerInternalEntryDrag(_ id: UUID, on provider: NSItemProvider) {
        provider.registerDataRepresentation(forTypeIdentifier: Self.internalEntryDragType.identifier, visibility: .ownProcess) { completion in
            completion(id.uuidString.data(using: .utf8), nil)
            return nil
        }
    }

    func togglePin(_ entry: ClipboardEntry) {
        if !canPin(to: activeTab) || activeTab == .favorites {
            return
        }
        mutate(entry) { item in
            if item.pinnedTabs.contains(activeTab) {
                item.pinnedTabs.remove(activeTab)
            } else {
                item.pinnedTabs.insert(activeTab)
            }
            item.updatedAt = Date()
        }
    }

    func toggleFavorite(_ entry: ClipboardEntry) {
        if entry.isTransient == true {
            saveTransient(entry, then: toggleFavorite)
            return
        }
        mutate(entry) { item in
            if favoriteOrder.contains(item.id) {
                favoriteOrder.removeAll { $0 == item.id }
            } else {
                favoriteOrder.append(item.id)
            }
        }
    }

    func togglePin(_ entry: ClipboardEntry, tab: ClipTab) {
        guard canPin(to: tab) else { return }
        if tab == .favorites {
            toggleFavorite(entry)
            return
        }
        if entry.isTransient == true {
            saveTransient(entry) { saved in self.togglePin(saved, tab: tab) }
            return
        }
        mutate(entry) { item in
            if item.pinnedTabs.contains(tab) {
                item.pinnedTabs.remove(tab)
            } else {
                item.pinnedTabs.insert(tab)
            }
            item.updatedAt = Date()
        }
    }

    func addEntry(_ entryID: UUID, to tab: ClipTab) {
        guard let entry = history.first(where: { $0.id == entryID }) else { return }
        pinEntry(entry, to: tab)
    }

    private func pinEntry(_ entry: ClipboardEntry, to tab: ClipTab) {
        guard canPin(to: tab) else { return }
        if tab == .favorites {
            addFavorite(entry)
            return
        }
        mutate(entry) { item in
            guard !item.pinnedTabs.contains(tab) else { return }
            item.pinnedTabs.insert(tab)
            item.updatedAt = Date()
        }
    }

    private func addFavorite(_ entry: ClipboardEntry) {
        if entry.isTransient == true {
            saveTransient(entry, then: addFavorite)
            return
        }
        mutate(entry) { item in
            guard !favoriteOrder.contains(item.id) else { return }
            favoriteOrder.append(item.id)
        }
    }

    func moveFavorite(from source: UUID, to destination: UUID) {
        guard source != destination else { return }
        var ordered = favoriteOrder.filter { id in
            history.contains { $0.id == id }
        }
        guard let sourceIndex = ordered.firstIndex(of: source),
              let destinationIndex = ordered.firstIndex(of: destination) else { return }
        let moved = ordered.remove(at: sourceIndex)
        ordered.insert(moved, at: destinationIndex)
        favoriteOrder = ordered
        save()
    }

    func moveGroupItem(from source: UUID, to destination: UUID, in groupID: UUID) {
        guard source != destination,
              let groupIndex = customGroups.firstIndex(where: { $0.id == groupID }) else { return }
        var ordered = customGroups[groupIndex].itemIDs.filter { id in
            history.contains { $0.id == id }
        }
        guard let sourceIndex = ordered.firstIndex(of: source),
              let destinationIndex = ordered.firstIndex(of: destination) else { return }
        let moved = ordered.remove(at: sourceIndex)
        ordered.insert(moved, at: destinationIndex)
        customGroups[groupIndex].itemIDs = ordered
        save()
    }

    func delete(_ entry: ClipboardEntry) {
        history.removeAll { $0.id == entry.id }
        for index in customGroups.indices {
            customGroups[index].itemIDs.removeAll { $0 == entry.id }
        }
        if selectedID == entry.id {
            selectedID = visibleHistory.first?.id
        }
        pruneImageStore()
        save()
    }

    func addGroup(name: String, symbol: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        customGroups.append(CustomGroup(id: UUID(), name: trimmed, symbol: symbol, itemIDs: []))
        save()
    }

    func deleteGroup(_ group: CustomGroup) {
        customGroups.removeAll { $0.id == group.id }
        if activeGroupID == group.id {
            activeGroupID = nil
            activeTab = .all
        }
        save()
    }

    func updateGroup(_ group: CustomGroup, name: String, symbol: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let index = customGroups.firstIndex(where: { $0.id == group.id }) else { return }
        customGroups[index].name = trimmed
        customGroups[index].symbol = symbol
        save()
    }

    func moveGroup(from source: UUID, to destination: UUID) {
        guard source != destination,
              let sourceIndex = customGroups.firstIndex(where: { $0.id == source }),
              let destinationIndex = customGroups.firstIndex(where: { $0.id == destination }) else { return }
        let moved = customGroups.remove(at: sourceIndex)
        customGroups.insert(moved, at: destinationIndex)
        save()
    }

    func add(_ entry: ClipboardEntry, to group: CustomGroup) {
        if entry.isTransient == true {
            saveTransient(entry) { saved in self.add(saved, to: group) }
            return
        }
        guard let index = customGroups.firstIndex(where: { $0.id == group.id }) else { return }
        if !customGroups[index].itemIDs.contains(entry.id) {
            customGroups[index].itemIDs.append(entry.id)
            save()
        }
    }

    func addEntry(_ entryID: UUID, to group: CustomGroup) {
        guard let entry = history.first(where: { $0.id == entryID }) else { return }
        add(entry, to: group)
    }

    func rename(_ entry: ClipboardEntry, title: String) {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTitle.isEmpty else { return }
        mutate(entry) { item in
            item.title = normalizedTitle
            item.updatedAt = Date()
        }
    }

    func clearHistory() {
        history = []
        selectedID = nil
        pruneImageStore()
        save()
    }

    func refreshClipboard() {
        syncCurrentPasteboard()
    }

    func captureCurrentPasteboard() {
        guard let entry = readCurrentEntry() else { return }
        currentClipboardSignature = entry.signature
        if let existing = history.first(where: { $0.signature == entry.signature }) {
            selectedID = existing.id
        } else {
            upsert(entry)
        }
        changeCount = pasteboard.changeCount
    }

    func updateSettings(_ next: AppSettings) {
        settings = next
        trimHistory()
        save()
    }

    func generateThemeOptions(prompt: String) async {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        themeOptions = []
        themeGenerationError = nil
        themeGenerationLoading = true
        themeGenerationStatus = L10n.themeAnalyzingPrompt

        do {
            try await Task.sleep(for: .milliseconds(260))
            themeGenerationStatus = L10n.themeGeneratingOptions
            let response = LocalThemeGenerator.generateThemeOptions(prompt: trimmed)
            themeGenerationStatus = L10n.themePreparingPreview
            try await Task.sleep(for: .milliseconds(180))
            themeOptions = response
            themeGenerationStatus = L10n.themeGenerated
        } catch {
            themeGenerationError = error.localizedDescription
            themeGenerationStatus = ""
        }
        themeGenerationLoading = false
    }

    func applyCustomTheme(_ theme: CustomThemeSettings) {
        var next = settings
        var savedTheme = theme
        savedTheme.id = UUID().uuidString
        next.customThemes.append(savedTheme)
        next.theme = "custom:\(savedTheme.id)"
        updateSettings(next)
    }

    func saveCustomTheme(_ theme: CustomThemeSettings) {
        var next = settings
        var savedTheme = theme
        savedTheme.id = UUID().uuidString
        next.customThemes.append(savedTheme)
        updateSettings(next)
    }

    func deleteCustomTheme(id: String) {
        var next = settings
        next.customThemes.removeAll { $0.id == id }
        if next.theme == "custom:\(id)" {
            next.theme = "system"
        }
        updateSettings(next)
    }

    func dismissDoublePasteHint() {
        settings.hideDoublePasteHint = true
        save()
    }

    func markDoublePasteUsed() {
        settings.usedDoublePaste = true
        save()
    }

    var shouldShowDoublePasteHint: Bool {
        !settings.hideDoublePasteHint && !settings.usedDoublePaste
    }

    func toast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            if self?.toastMessage == message {
                self?.toastMessage = nil
            }
        }
    }

    private func mutate(_ entry: ClipboardEntry, update: (inout ClipboardEntry) -> Void) {
        guard let index = history.firstIndex(where: { $0.id == entry.id }) else { return }
        update(&history[index])
        save()
    }

    private func recordClick(on entry: ClipboardEntry) {
        guard let index = history.firstIndex(where: { $0.id == entry.id }) else { return }

        history[index].updatedAt = Date()
        save()
    }

    private func saveTransient(_ entry: ClipboardEntry, then action: (ClipboardEntry) -> Void) {
        guard entry.isTransient == true else {
            action(entry)
            return
        }
        var saved = entry
        saved.id = UUID()
        saved.isTransient = false
        saved.createdAt = Date()
        saved.updatedAt = Date()
        saved.signature = "text:\(entry.text ?? entry.preview)"
        history.insert(saved, at: 0)
        selectedID = saved.id
        save()
        action(saved)
    }

    private func startPolling() {
        pollTimer?.invalidate()
        pollTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.syncCurrentPasteboard()
            }
        }
    }

    private func syncCurrentPasteboard() {
        guard pasteboard.changeCount != changeCount else { return }
        changeCount = pasteboard.changeCount
        guard let entry = readCurrentEntry() else { return }
        currentClipboardSignature = entry.signature
        if entry.signature == pendingSignature {
            pendingSignature = nil
            return
        }
        upsert(entry)
    }

    private func upsert(_ entry: ClipboardEntry) {
        var savedEntry = entry
        if let existingIndex = history.firstIndex(where: { $0.signature == entry.signature }) {
            var merged = savedEntry
            merged.pinnedTabs = history[existingIndex].pinnedTabs
            merged.createdAt = history[existingIndex].createdAt
            merged.id = history[existingIndex].id
            if merged.source?.pageURL == nil,
               history[existingIndex].source?.pageURL != nil {
                merged.source = history[existingIndex].source
            }
            history.remove(at: existingIndex)
            history.insert(merged, at: 0)
            selectedID = merged.id
            savedEntry = merged
        } else {
            history.insert(savedEntry, at: 0)
            selectedID = savedEntry.id
        }
        trimHistory()
        save()
    }

    private func protectedHistoryIDs() -> Set<UUID> {
        var protected = Set(favoriteOrder)
        protected.formUnion(customGroups.flatMap(\.itemIDs))
        protected.formUnion(history.filter { !$0.pinnedTabs.isEmpty }.map(\.id))
        return protected
    }

    @discardableResult
    private func trimHistory() -> Bool {
        guard let cutoff = settings.historyRetentionPeriod.cutoffDate() else {
            pruneImageStore()
            return false
        }
        let protected = protectedHistoryIDs()
        let originalCount = history.count
        history.removeAll { entry in
            entry.updatedAt < cutoff
                && !protected.contains(entry.id)
        }
        var changed = history.count != originalCount
        if selectedID.map({ id in !history.contains { $0.id == id } }) == true {
            let nextSelectedID = visibleHistory.first?.id
            if selectedID != nextSelectedID {
                selectedID = nextSelectedID
                changed = true
            }
        }
        pruneImageStore()
        return changed
    }

    private func imageFileExists(_ fileName: String?) -> Bool {
        guard let fileName, !fileName.isEmpty else { return false }
        return FileManager.default.fileExists(atPath: imageStoreDirectory.appendingPathComponent(fileName).path)
    }

    private func persistImageData(_ data: Data, preferredName: String? = nil) -> String? {
        let fileName = preferredName?.isEmpty == false ? preferredName! : "\(UUID().uuidString).png"
        let url = imageStoreDirectory.appendingPathComponent(fileName)
        do {
            try FileManager.default.createDirectory(at: imageStoreDirectory, withIntermediateDirectories: true)
            try data.write(to: url, options: .atomic)
            return fileName
        } catch {
            NSLog("StowPaste: failed to persist clipboard image: \(error.localizedDescription)")
            return nil
        }
    }

    private func loadImageData(for entry: ClipboardEntry) -> Data? {
        if let imagePNG = entry.imagePNG {
            return imagePNG
        }
        guard let imageFileName = entry.imageFileName else { return nil }
        return try? Data(contentsOf: imageStoreDirectory.appendingPathComponent(imageFileName))
    }

    private func imageThumbnailData(from image: NSImage) -> Data? {
        image.resized(maxPixelSize: 180)?.pngData
    }

    private func migrateImagePayloadsToDisk() -> Bool {
        var changed = false
        for index in history.indices where history[index].kind == .image {
            if let imagePNG = history[index].imagePNG,
               !imageFileExists(history[index].imageFileName),
               let fileName = persistImageData(imagePNG, preferredName: history[index].imageFileName) {
                history[index].imageFileName = fileName
                changed = true
            }
            if history[index].imageThumbnailPNG == nil,
               let imagePNG = history[index].imagePNG,
               let image = NSImage(data: imagePNG) {
                history[index].imageThumbnailPNG = imageThumbnailData(from: image)
                changed = true
            }
            if history[index].imagePNG != nil {
                history[index].imagePNG = nil
                changed = true
            }
        }
        if changed {
            pruneImageStore()
        }
        return changed
    }

    private func entryForSaving(_ entry: ClipboardEntry) -> ClipboardEntry {
        var copy = entry
        if copy.kind == .image {
            copy.imagePNG = nil
        }
        return copy
    }

    private func pruneImageStore() {
        let used = Set(history.compactMap(\.imageFileName))
        guard let files = try? FileManager.default.contentsOfDirectory(at: imageStoreDirectory, includingPropertiesForKeys: nil) else {
            return
        }
        for file in files where !used.contains(file.lastPathComponent) {
            try? FileManager.default.removeItem(at: file)
        }
    }

    private func readCurrentEntry() -> ClipboardEntry? {
        let source = ClipboardSource.currentCopySource()
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], !urls.isEmpty {
            let signature = "file:\(urls.map(\.path).joined(separator: "|"))"
            let names = urls.map(\.lastPathComponent).filter { !$0.isEmpty }
            let first = names.first ?? L10n.file
            let shownNames = Array(names.prefix(3))
            let extraCount = max(0, urls.count - shownNames.count)
            let preview = (shownNames + (extraCount > 0 ? [L10n.fileListSuffix(extraCount)] : [])).joined(separator: "\n")
            return ClipboardEntry(
                id: UUID(),
                kind: .file,
                title: urls.count == 1 ? first : L10n.fileCount(urls.count, first: first),
                preview: preview.isEmpty ? first : preview,
                signature: signature,
                createdAt: Date(),
                updatedAt: Date(),
                pinnedTabs: [],
                text: nil,
                fileURLs: urls,
                imagePNG: nil,
                imageWidth: nil,
                imageHeight: nil,
                source: source
            )
        }

        if let image = NSImage(pasteboard: pasteboard),
           let png = image.pngData {
            let size = image.representations.first.map { NSSize(width: $0.pixelsWide, height: $0.pixelsHigh) } ?? image.size
            let width = Int(size.width)
            let height = Int(size.height)
            let fileName = persistImageData(png)
            return ClipboardEntry(
                id: UUID(),
                kind: .image,
                title: L10n.image,
                preview: L10n.imageSummary(width: width, height: height),
                signature: "image:\(png.hashValue):\(width)x\(height)",
                createdAt: Date(),
                updatedAt: Date(),
                pinnedTabs: [],
                text: nil,
                fileURLs: [],
                imagePNG: nil,
                imageFileName: fileName,
                imageThumbnailPNG: imageThumbnailData(from: image),
                imageWidth: width,
                imageHeight: height,
                source: source
            )
        }

        guard let raw = pasteboard.string(forType: .string) else { return nil }
        let text = normalize(raw)
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return ClipboardEntry(
            id: UUID(),
            kind: .text,
            title: L10n.text,
            preview: Self.preview(trimmed, preservingLineBreaks: true),
            signature: "text:\(trimmed)",
            createdAt: Date(),
            updatedAt: Date(),
            pinnedTabs: [],
            text: text,
            fileURLs: [],
            imagePNG: nil,
            imageWidth: nil,
            imageHeight: nil,
            source: source
        )
    }

    private func write(_ entry: ClipboardEntry) {
        pasteboard.clearContents()
        switch entry.kind {
        case .text:
            if let text = entry.text {
                pasteboard.setString(text, forType: .string)
            }
        case .file:
            pasteboard.writeObjects(entry.fileURLs as [NSURL])
        case .image:
            if let imagePNG = loadImageData(for: entry),
               let image = NSImage(data: imagePNG) {
                pasteboard.writeObjects([image])
            }
        }
        pendingSignature = entry.signature
        currentClipboardSignature = entry.signature
        changeCount = pasteboard.changeCount
    }

    private func normalize(_ text: String) -> String {
        text.replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\0", with: "")
    }

    static func preview(_ text: String, limit: Int = 120, preservingLineBreaks: Bool = false) -> String {
        let source = preservingLineBreaks
            ? text.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
            : text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        if source.count <= limit {
            return source
        }
        return String(source.prefix(limit - 1)) + "…"
    }

    private func load() {
        guard let data = try? Data(contentsOf: storeURL),
              let state = try? JSONDecoder().decode(PersistedState.self, from: data) else {
            return
        }
        settings = state.settings
        if state.containedRemovedFeatureState {
            // The full build could exempt classified "important" entries from retention.
            // The current app no longer classifies history, so preserve every migrated entry and let
            // the user opt into a shorter retention period later.
            settings.historyRetentionPeriod = .unlimited
        }
        history = state.history
        activeTab = state.activeTab
        selectedID = state.selectedID
        favoriteOrder = (state.favoriteOrder ?? [])
            .sorted { $0.rank < $1.rank }
            .map(\.id)
        migrateFavoritePins()
        if let persistedCustomGroups = state.customGroups {
            customGroups = persistedCustomGroups.filter { $0.id != Self.legacyDefaultImageGroupID }
        } else {
            customGroups = []
        }
        let trimmedHistory = trimHistory()
        let migratedImages = migrateImagePayloadsToDisk()
        if trimmedHistory || migratedImages || state.containedRemovedFeatureState {
            save()
        }
        pendingSignature = nil
    }

    private func migrateFavoritePins() {
        let pinnedFavoriteIDs = history
            .filter { $0.pinnedTabs.contains(.favorites) }
            .map(\.id)
        for id in pinnedFavoriteIDs where !favoriteOrder.contains(id) {
            favoriteOrder.append(id)
        }
        for index in history.indices {
            history[index].pinnedTabs.remove(.favorites)
        }
        favoriteOrder = favoriteOrder.filter { id in
            history.contains { $0.id == id }
        }
    }

    private func save() {
        migrateFavoritePins()
        let state = PersistedState(
            settings: settings,
            history: history.map(entryForSaving),
            activeTab: activeTab,
            selectedID: selectedID,
            lastSignature: pendingSignature ?? "",
            favoriteOrder: favoriteOrder.enumerated().map { FavoriteOrderItem(id: $0.element, rank: $0.offset) },
            customGroups: customGroups
        )
        if let data = try? JSONEncoder.pretty.encode(state) {
            try? data.write(to: storeURL, options: .atomic)
        }
    }
}

enum LocalThemeGenerator {
    static func generateThemeOptions(prompt: String) -> [AIThemeOption] {
        let seeds = themeSeeds(for: prompt)
        return seeds.enumerated().map { index, seed in
            let theme = CustomThemeSettings(
                name: seed.name,
                lightBackground: seed.lightBackground,
                darkBackground: seed.darkBackground,
                panelTint: seed.panelTint,
                accent: seed.accent,
                subtleFill: seed.subtleFill,
                primary: seed.primary,
                secondary: seed.secondary,
                textPrimary: seed.textPrimary,
                textSecondary: seed.textSecondary
            )
            return AIThemeOption(
                name: seed.name,
                rationale: seed.rationale,
                theme: sanitizedTheme(theme, fallbackName: "\(L10n.customTheme) \(index + 1)")
            )
        }
    }

    private static func sanitizedTheme(_ theme: CustomThemeSettings, fallbackName: String) -> CustomThemeSettings {
        CustomThemeSettings(
            id: theme.id,
            name: theme.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? fallbackName : theme.name,
            lightBackground: normalizedHex(theme.lightBackground, fallback: CustomThemeSettings.fallback.lightBackground),
            darkBackground: normalizedHex(theme.darkBackground, fallback: CustomThemeSettings.fallback.darkBackground),
            panelTint: normalizedHex(theme.panelTint, fallback: CustomThemeSettings.fallback.panelTint),
            accent: normalizedHex(theme.accent, fallback: CustomThemeSettings.fallback.accent),
            subtleFill: normalizedHex(theme.subtleFill, fallback: CustomThemeSettings.fallback.subtleFill),
            primary: normalizedHex(theme.primary, fallback: CustomThemeSettings.fallback.primary),
            secondary: normalizedHex(theme.secondary, fallback: CustomThemeSettings.fallback.secondary),
            textPrimary: normalizedHex(theme.textPrimary, fallback: CustomThemeSettings.fallback.textPrimary),
            textSecondary: normalizedHex(theme.textSecondary, fallback: CustomThemeSettings.fallback.textSecondary)
        )
    }

    private struct ThemeSeed {
        var name: String
        var rationale: String
        var lightBackground: String
        var darkBackground: String
        var panelTint: String
        var accent: String
        var subtleFill: String
        var primary: String
        var secondary: String
        var textPrimary: String
        var textSecondary: String
    }

    private static func themeSeeds(for prompt: String) -> [ThemeSeed] {
        let text = prompt.lowercased()
        let seed = promptSeed(text)
        let rotation = promptHueRotation(seed)
        let rawPalette = basePalette(for: text)
        let palette = (
            background: rotatedHex(rawPalette.background, degrees: rotation * 0.35),
            accent: rotatedHex(rawPalette.accent, degrees: rotation),
            primary: rotatedHex(rawPalette.primary, degrees: rotation + seededVariantAmount(seed: seed, index: 1, range: 24)),
            secondary: rotatedHex(rawPalette.secondary, degrees: rotation - seededVariantAmount(seed: seed, index: 2, range: 32))
        )
        let softMix = seededVariantAmount(seed: seed, index: 3, range: 0.10)
        let darkMix = seededVariantAmount(seed: seed, index: 4, range: 0.08)
        let balancedMix = seededVariantAmount(seed: seed, index: 5, range: 0.12)
        let displayName = prompt
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(whereSeparator: \.isWhitespace)
            .prefix(3)
            .joined(separator: " ")
        let baseName = displayName.isEmpty ? L10n.customTheme : displayName
        return [
            ThemeSeed(
                name: L10n.text("\(baseName) 轻盈", "\(baseName) Airy"),
                rationale: L10n.text("清爽的浅色工作配色，适合高频浏览剪切板。", "A clean light working palette for frequent clipboard scanning."),
                lightBackground: mixHex(palette.background, "#FFFFFF", amount: 0.80 + softMix),
                darkBackground: mixHex(palette.background, "#090B10", amount: 0.18 + darkMix),
                panelTint: mixHex(palette.accent, "#FFFFFF", amount: 0.82 + softMix),
                accent: palette.accent,
                subtleFill: mixHex(palette.secondary, "#FFFFFF", amount: 0.76 + softMix),
                primary: palette.primary,
                secondary: palette.secondary,
                textPrimary: "#1F2328",
                textSecondary: "#5F6672"
            ),
            ThemeSeed(
                name: L10n.text("\(baseName) 深色", "\(baseName) Dark"),
                rationale: L10n.text("低亮度背景搭配清晰强调色，适合深色系统。", "A low-light background with crisp accents for dark appearance."),
                lightBackground: mixHex(palette.background, "#FFFFFF", amount: 0.72 + softMix),
                darkBackground: mixHex(palette.primary, "#05070B", amount: 0.16 + darkMix),
                panelTint: mixHex(palette.primary, "#0E1118", amount: 0.42 + darkMix),
                accent: palette.accent,
                subtleFill: mixHex(palette.secondary, "#111827", amount: 0.48 + darkMix),
                primary: mixHex(palette.accent, "#FFFFFF", amount: 0.12),
                secondary: mixHex(palette.secondary, "#FFFFFF", amount: 0.10),
                textPrimary: "#F5F7FA",
                textSecondary: "#B9C0CC"
            ),
            ThemeSeed(
                name: L10n.text("\(baseName) 平衡", "\(baseName) Balanced"),
                rationale: L10n.text("更柔和的背景和双色重点，避免单一色调。", "Softer surfaces with two accents to avoid a one-note palette."),
                lightBackground: mixHex(palette.background, "#FFFFFF", amount: 0.76 + balancedMix),
                darkBackground: mixHex(palette.secondary, "#0B0F14", amount: 0.20 + darkMix),
                panelTint: mixHex(palette.background, "#FFFFFF", amount: 0.62 + balancedMix),
                accent: mixHex(palette.accent, palette.secondary, amount: 0.14 + balancedMix),
                subtleFill: mixHex(palette.background, palette.secondary, amount: 0.16 + balancedMix),
                primary: palette.primary,
                secondary: mixHex(palette.secondary, palette.accent, amount: 0.18 + balancedMix),
                textPrimary: "#20242B",
                textSecondary: "#646B77"
            )
        ]
    }

    private static func basePalette(for text: String) -> (background: String, accent: String, primary: String, secondary: String) {
        if text.contains("dark") || text.contains("深") || text.contains("夜") || text.contains("黑") {
            return ("#18202A", "#66D9EF", "#7DD3FC", "#A78BFA")
        }
        if text.contains("green") || text.contains("自然") || text.contains("绿色") || text.contains("森林") {
            return ("#E8F3EC", "#2E8B57", "#247A53", "#76A65B")
        }
        if text.contains("warm") || text.contains("温暖") || text.contains("日落") || text.contains("橙") {
            return ("#F7EFE5", "#D97745", "#B85C38", "#4F8C8A")
        }
        if text.contains("pink") || text.contains("粉") || text.contains("可爱") {
            return ("#F7EBF1", "#D75B8A", "#B84778", "#4E8FA8")
        }
        if text.contains("blue") || text.contains("科技") || text.contains("智能") || text.contains("蓝") {
            return ("#EAF2FA", "#3B82F6", "#2563EB", "#14B8A6")
        }
        return ("#EEF4F8", "#4F8EF7", "#2F6F9F", "#4BAE9D")
    }

    private static func normalizedHex(_ value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard trimmed.count == 7,
              trimmed.first == "#",
              trimmed.dropFirst().allSatisfy({ $0.isHexDigit }) else {
            return fallback
        }
        return trimmed
    }

    private static func promptSeed(_ text: String) -> UInt64 {
        var hash: UInt64 = 0xcbf29ce484222325
        for scalar in text.unicodeScalars {
            hash ^= UInt64(scalar.value)
            hash &*= 0x100000001b3
        }
        return hash
    }

    private static func promptHueRotation(_ seed: UInt64) -> Double {
        Double(seed % 360)
    }

    private static func seededVariantAmount(seed: UInt64, index: Int, range: Double) -> Double {
        let shifted = seed >> UInt64((index * 11) % 48)
        let unit = Double(shifted & 0xFFFF) / Double(UInt16.max)
        return unit * range
    }

    private static func rotatedHex(_ hex: String, degrees: Double) -> String {
        guard let rgb = rgbComponents(from: hex) else { return hex }
        let hsv = hsvComponents(red: rgb.red, green: rgb.green, blue: rgb.blue)
        let nextHue = hsv.hue + degrees / 360.0
        return hexFromHSV(hue: nextHue - floor(nextHue), saturation: hsv.saturation, value: hsv.value)
    }

    private static func mixHex(_ left: String, _ right: String, amount: Double) -> String {
        let l = rgbComponents(from: left) ?? (red: 0.5, green: 0.5, blue: 0.5)
        let r = rgbComponents(from: right) ?? (red: 1.0, green: 1.0, blue: 1.0)
        let clamped = min(1, max(0, amount))
        let red = l.red + (r.red - l.red) * clamped
        let green = l.green + (r.green - l.green) * clamped
        let blue = l.blue + (r.blue - l.blue) * clamped
        return String(
            format: "#%02X%02X%02X",
            Int(min(255, max(0, round(red * 255)))),
            Int(min(255, max(0, round(green * 255)))),
            Int(min(255, max(0, round(blue * 255))))
        )
    }

    private static func hsvComponents(red: Double, green: Double, blue: Double) -> (hue: Double, saturation: Double, value: Double) {
        let maxValue = max(red, green, blue)
        let minValue = min(red, green, blue)
        let delta = maxValue - minValue
        let hue: Double
        if delta == 0 {
            hue = 0
        } else if maxValue == red {
            hue = ((green - blue) / delta).truncatingRemainder(dividingBy: 6) / 6
        } else if maxValue == green {
            hue = (((blue - red) / delta) + 2) / 6
        } else {
            hue = (((red - green) / delta) + 4) / 6
        }
        let saturation = maxValue == 0 ? 0 : delta / maxValue
        return (hue < 0 ? hue + 1 : hue, saturation, maxValue)
    }

    private static func hexFromHSV(hue: Double, saturation: Double, value: Double) -> String {
        let c = value * saturation
        let x = c * (1 - abs((hue * 6).truncatingRemainder(dividingBy: 2) - 1))
        let m = value - c
        let rgb: (Double, Double, Double)
        switch hue * 6 {
        case 0..<1: rgb = (c, x, 0)
        case 1..<2: rgb = (x, c, 0)
        case 2..<3: rgb = (0, c, x)
        case 3..<4: rgb = (0, x, c)
        case 4..<5: rgb = (x, 0, c)
        default: rgb = (c, 0, x)
        }
        return String(
            format: "#%02X%02X%02X",
            Int(min(255, max(0, round((rgb.0 + m) * 255)))),
            Int(min(255, max(0, round((rgb.1 + m) * 255)))),
            Int(min(255, max(0, round((rgb.2 + m) * 255))))
        )
    }
}

extension JSONEncoder {
    static var pretty: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}

extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffRepresentation) else {
            return nil
        }
        return bitmap.representation(using: .png, properties: [:])
    }

    func resized(maxPixelSize: CGFloat) -> NSImage? {
        let width = max(size.width, 1)
        let height = max(size.height, 1)
        let scale = min(1, maxPixelSize / max(width, height))
        let targetSize = NSSize(width: width * scale, height: height * scale)
        let image = NSImage(size: targetSize)
        image.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        draw(in: NSRect(origin: .zero, size: targetSize), from: .zero, operation: .copy, fraction: 1)
        image.unlockFocus()
        return image
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")).trimmingCharacters(in: .whitespacesAndNewlines)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let red = Double((value & 0xFF0000) >> 16) / 255
        let green = Double((value & 0x00FF00) >> 8) / 255
        let blue = Double(value & 0x0000FF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}

private func secondarySurfaceBackground(theme: CustomThemeSettings?, colorScheme: ColorScheme) -> Color {
    let baseHex = theme.map { colorScheme == .dark ? $0.darkBackground : $0.lightBackground } ?? (colorScheme == .dark ? "#171A1F" : "#F8F8F6")
    return mixedSurfaceColor(
        baseHex: baseHex,
        colorScheme: colorScheme,
        mixAmount: colorScheme == .dark ? 0.10 : 0.03,
        opacity: 0.95
    )
}

private func mixedSurfaceColor(baseHex: String, colorScheme: ColorScheme, mixAmount: Double, opacity: Double) -> Color {
    let base = rgbComponents(from: baseHex) ?? (red: 0.10, green: 0.11, blue: 0.13)
    let target = colorScheme == .dark ? (red: 1.0, green: 1.0, blue: 1.0) : (red: 0.0, green: 0.0, blue: 0.0)
    return Color(
        red: base.red + (target.red - base.red) * mixAmount,
        green: base.green + (target.green - base.green) * mixAmount,
        blue: base.blue + (target.blue - base.blue) * mixAmount
    )
    .opacity(opacity)
}

private func neutralPalette(for theme: CustomThemeSettings, colorScheme: ColorScheme) -> (title: Color, secondary: Color, tertiaryFill: Color) {
    let backgroundHex = colorScheme == .dark ? theme.darkBackground : theme.lightBackground
    if backgroundIsLight(hex: backgroundHex) {
        return (
            title: Color(hex: "#333333"),
            secondary: Color(hex: "#666666"),
            tertiaryFill: Color(hex: "#E9EAEC")
        )
    }
    return (
        title: Color.white,
        secondary: Color.white.opacity(0.78),
        tertiaryFill: Color.white.opacity(0.14)
    )
}

private func backgroundIsLight(hex: String) -> Bool {
    guard let rgb = rgbComponents(from: hex) else { return false }
    let luminance = 0.2126 * rgb.red + 0.7152 * rgb.green + 0.0722 * rgb.blue
    return luminance >= 0.62
}

private func rgbComponents(from hex: String) -> (red: Double, green: Double, blue: Double)? {
    let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")).trimmingCharacters(in: .whitespacesAndNewlines)
    guard cleaned.count == 6 else { return nil }
    var value: UInt64 = 0
    guard Scanner(string: cleaned).scanHexInt64(&value) else { return nil }
    return (
        red: Double((value & 0xFF0000) >> 16) / 255,
        green: Double((value & 0x00FF00) >> 8) / 255,
        blue: Double(value & 0x0000FF) / 255
    )
}

struct PanelThemeColors {
    var primary: Color?
    var secondary: Color?
    var textPrimary: Color?
    var textSecondary: Color?
    var itemTitle: Color?
    var itemSecondary: Color?
    var tertiaryFill: Color?
    var fill: Color?
}

extension PanelThemeColors {
    var primaryOrAccent: Color {
        primary ?? Color.accentColor
    }

    var primaryText: Color {
        textPrimary ?? Color.primary
    }

    var secondaryText: Color {
        itemSecondary ?? textSecondary ?? Color.secondary
    }
}

private struct PanelThemeColorsKey: EnvironmentKey {
    static let defaultValue = PanelThemeColors()
}

extension EnvironmentValues {
    var panelThemeColors: PanelThemeColors {
        get { self[PanelThemeColorsKey.self] }
        set { self[PanelThemeColorsKey.self] = newValue }
    }
}

enum PanelResizeEdge {
    case left
    case right
    case top
    case bottom
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight

    var resizesFromLeft: Bool {
        self == .left || self == .topLeft || self == .bottomLeft
    }

    var resizesFromRight: Bool {
        self == .right || self == .topRight || self == .bottomRight
    }

    var resizesFromTop: Bool {
        self == .top || self == .topLeft || self == .topRight
    }

    var resizesFromBottom: Bool {
        self == .bottom || self == .bottomLeft || self == .bottomRight
    }
}

enum PanelWindowInteraction {
    case drag
    case resize(PanelResizeEdge)
}

enum PanelPresentationPositioning {
    case insertionPoint
    case mouse
}

enum PanelKeyboardActionPolicy {
    static func shouldPasteOnEnter(titleEditing: Bool) -> Bool {
        !titleEditing
    }
}

final class ClipboardPanel: NSPanel {
    weak var controller: AppController?
    private static let resizeHandleThickness: CGFloat = 14
    private static let resizeCornerSize: CGFloat = 28
    private static let dragHandleHeight: CGFloat = PanelMetrics.headerDragHeight
    private var activeResizeCursorEdge: PanelResizeEdge?

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    override var acceptsMouseMovedEvents: Bool {
        get { true }
        set { super.acceptsMouseMovedEvents = newValue }
    }

    override func sendEvent(_ event: NSEvent) {
        if event.type == .leftMouseDown, routePanelInteraction(with: event) {
            return
        }
        super.sendEvent(event)
    }

    override func mouseDown(with event: NSEvent) {
        if routePanelInteraction(with: event) {
            return
        }
        super.mouseDown(with: event)
    }

    override func mouseMoved(with event: NSEvent) {
        updateResizeCursor(at: event.locationInWindow)
        super.mouseMoved(with: event)
    }

    override func mouseExited(with event: NSEvent) {
        activeResizeCursorEdge = nil
        NSCursor.arrow.set()
        super.mouseExited(with: event)
    }

    @discardableResult
    private func routePanelInteraction(with event: NSEvent) -> Bool {
        guard let interaction = panelInteraction(at: event.locationInWindow) else { return false }
        switch interaction {
        case .drag:
            controller?.dragPanel(with: event)
        case .resize(let edge):
            controller?.resizePanel(edge: edge, with: event)
        }
        return true
    }

    private func updateResizeCursor(at location: NSPoint) {
        if case .resize(let edge) = panelInteraction(at: location) {
            activeResizeCursorEdge = edge
            cursor(for: edge).set()
            return
        }
        guard activeResizeCursorEdge != nil else { return }
        activeResizeCursorEdge = nil
        NSCursor.arrow.set()
    }

    private func cursor(for edge: PanelResizeEdge) -> NSCursor {
        switch edge {
        case .left, .right, .topLeft, .bottomRight:
            return .resizeLeftRight
        case .top, .bottom, .topRight, .bottomLeft:
            return .resizeUpDown
        }
    }

    private func panelInteraction(at location: NSPoint) -> PanelWindowInteraction? {
        let bounds = contentView?.bounds ?? NSRect(origin: .zero, size: frame.size)
        guard bounds.contains(location) else { return nil }
        let visualRect = panelVisualRect(in: bounds)

        let nearLeft = abs(location.x - visualRect.minX) <= Self.resizeHandleThickness
        let nearRight = abs(location.x - visualRect.maxX) <= Self.resizeHandleThickness
        let nearBottom = abs(location.y - visualRect.minY) <= Self.resizeHandleThickness
        let nearTop = abs(location.y - visualRect.maxY) <= Self.resizeHandleThickness
        let inLeftCorner = location.x <= visualRect.minX + Self.resizeCornerSize
        let inRightCorner = location.x >= visualRect.maxX - Self.resizeCornerSize
        let inBottomCorner = location.y <= visualRect.minY + Self.resizeCornerSize
        let inTopCorner = location.y >= visualRect.maxY - Self.resizeCornerSize

        if inLeftCorner && inTopCorner { return .resize(.topLeft) }
        if inRightCorner && inTopCorner { return .resize(.topRight) }
        if inLeftCorner && inBottomCorner { return .resize(.bottomLeft) }
        if inRightCorner && inBottomCorner { return .resize(.bottomRight) }
        if nearLeft { return .resize(.left) }
        if nearRight { return .resize(.right) }
        if nearTop { return .resize(.top) }
        if nearBottom { return .resize(.bottom) }

        if isInDragHandle(location: location, visualRect: visualRect) {
            return .drag
        }

        return visualRect.contains(location) ? nil : .drag
    }

    private func isInDragHandle(location: NSPoint, visualRect: NSRect) -> Bool {
        let dragRect = NSRect(
            x: visualRect.minX,
            y: visualRect.maxY - Self.dragHandleHeight,
            width: visualRect.width,
            height: Self.dragHandleHeight
        )
        return dragRect.contains(location) && !isFunctionalHeaderHit(at: location)
    }

    private func isFunctionalHeaderHit(at location: NSPoint) -> Bool {
        let interactiveRects = controller?.headerInteractiveRects ?? []
        guard !interactiveRects.isEmpty else { return true }
        return interactiveRects.contains { $0.contains(location) }
    }

    private func panelVisualRect(in bounds: NSRect) -> NSRect {
        NSRect(
            x: bounds.minX + PanelMetrics.sideMargin,
            y: bounds.minY + PanelMetrics.bottomMargin,
            width: max(0, bounds.width - PanelMetrics.sideMargin * 2),
            height: max(0, bounds.height - PanelMetrics.topMargin - PanelMetrics.bottomMargin)
        )
    }
}

final class IconPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

enum PanelMetrics {
    static let compactWidth: CGFloat = 400
    static let visualHeight: CGFloat = 520
    static let minVisualWidth: CGFloat = 360
    static let maxVisualWidth: CGFloat = 920
    static let minVisualHeight: CGFloat = 360
    static let maxVisualHeight: CGFloat = 760
    static let sideMargin: CGFloat = 24
    static let topMargin: CGFloat = 34
    static let bottomMargin: CGFloat = 24
    static let headerDragHeight: CGFloat = 58

    static func defaultContentSize() -> NSSize {
        NSSize(
            width: compactWidth,
            height: visualHeight
        )
    }

    static func clampedContentSize(_ size: NSSize) -> NSSize {
        return NSSize(
            width: min(max(size.width, minVisualWidth), maxVisualWidth),
            height: min(max(size.height, minVisualHeight), maxVisualHeight)
        )
    }

    static func windowSize(contentSize: NSSize) -> NSSize {
        NSSize(
            width: contentSize.width + sideMargin * 2,
            height: contentSize.height + topMargin + bottomMargin
        )
    }

}

@MainActor
final class AppController: NSObject, NSApplicationDelegate {
    let model = AppModel()
    private var panel: ClipboardPanel?
    private var settingsWindow: NSWindow?
    private var groupWindow: NSPanel?
    private var statusItem: NSStatusItem!
    private var eventTap: CFMachPort?
    private var eventTapRunLoopSource: CFRunLoopSource?
    private var eventTapHealthTimer: Timer?
    private var outsideClickMonitor: Any?
    private var localClickMonitor: Any?
    private var workspaceObservers: [NSObjectProtocol] = []
    private var permissionRetryTimer: Timer?
    private var previousFrontmostApp: NSRunningApplication?
    private var ignoreNextPasteShortcut = false
    private var isResizingPanel = false
    private var lastPasteShortcutAt: Date?
    private var lastHotkeyTriggerAt: Date?
    private var lastDoubleTapHotkeyKeyCode: Int64?
    private var hotkeySnapshot = HotkeySnapshot(settings: HotkeySettings())
    private var panelPinnedSnapshot = false
    private var settingsWindowHasBeenShown = false
    private var headerInteractiveRectByID: [String: NSRect] = [:]
    private var historyRowRectByID: [UUID: CGRect] = [:]
    var headerInteractiveRects: [NSRect] {
        Array(headerInteractiveRectByID.values)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        if runPanelSmokeTestIfNeeded() {
            return
        }
        updateHotkeySnapshot()
        buildMainMenu()
        buildStatusItem()
        installWorkspaceObservers()
        requestAccessibilityPermissionIfNeeded()
    }

    func applicationWillTerminate(_ notification: Notification) {
        eventTapHealthTimer?.invalidate()
        invalidateEventTap()
        if let outsideClickMonitor {
            NSEvent.removeMonitor(outsideClickMonitor)
        }
        if let localClickMonitor {
            NSEvent.removeMonitor(localClickMonitor)
        }
        workspaceObservers.forEach { NSWorkspace.shared.notificationCenter.removeObserver($0) }
        permissionRetryTimer?.invalidate()
    }

    func showPanel(positioning: PanelPresentationPositioning = .insertionPoint) {
        let panel = ensurePanel()
        rememberPasteTarget(NSWorkspace.shared.frontmostApplication)
        model.showOverlay()
        updatePanelSize(animated: false, reposition: false)
        switch positioning {
        case .insertionPoint:
            positionPanel()
        case .mouse:
            positionPanelNearMouse()
        }
        installOutsideClickMonitor()
        panel.orderFrontRegardless()
    }

    func showPanelFromHotkey() {
        showPanel(positioning: .mouse)
    }

    func showPanelCentered() {
        let panel = ensurePanel()
        rememberPasteTarget(NSWorkspace.shared.frontmostApplication)
        model.showOverlay()
        updatePanelSize(animated: false, reposition: false)
        positionPanelAtScreenCenter()
        installOutsideClickMonitor()
        panel.orderFrontRegardless()
    }

    private func runPanelSmokeTestIfNeeded() -> Bool {
        guard ProcessInfo.processInfo.environment["STOWPASTE_PANEL_SMOKE_TEST"] == "1" else { return false }
        print("panel smoke test starting")
        DispatchQueue.main.async {
            self.showPanelCentered()
            self.verifyPanelSmokeTestVisibility(remainingAttempts: 10)
        }
        return true
    }

    private func verifyPanelSmokeTestVisibility(remainingAttempts: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            if self.panel?.isVisible == true {
                print("panel smoke test visible")
                if ProcessInfo.processInfo.environment["STOWPASTE_PANEL_FOCUS_SMOKE_TEST"] == "1" {
                    print("panel smoke test active=\(NSApp.isActive) key=\(self.panel?.isKeyWindow == true)")
                }
                exit(0)
            }
            guard remainingAttempts > 0 else {
                print("panel smoke test hidden")
                exit(1)
            }
            self.verifyPanelSmokeTestVisibility(remainingAttempts: remainingAttempts - 1)
        }
    }

    func updatePanelSize(animated: Bool = true, reposition: Bool = false) {
        let panel = ensurePanel()
        model.panelContentSize = PanelMetrics.clampedContentSize(model.panelContentSize)
        let size = PanelMetrics.windowSize(contentSize: model.panelContentSize)
        guard panel.frame.size != size else { return }
        var frame = panel.frame
        frame.size = size
        if animated {
            panel.animator().setFrame(frame, display: true)
        } else {
            panel.setFrame(frame, display: true)
        }
        if reposition {
            positionPanel()
        }
    }

    func hidePanel() {
        model.hideOverlay()
        panel?.orderOut(nil)
        removeOutsideClickMonitor()
        releasePanelIfIdle()
    }

    func hidePanelIfAllowed() {
        guard !model.panelPinned else { return }
        hidePanel()
    }

    func dragPanel(with event: NSEvent) {
        guard let panel else { return }
        panel.performDrag(with: event)
    }

    func resizePanel(edge: PanelResizeEdge, with event: NSEvent) {
        guard let panel else { return }
        isResizingPanel = true
        defer { isResizingPanel = false }
        let startFrame = panel.frame
        let startLocation = NSEvent.mouseLocation
        while let nextEvent = panel.nextEvent(matching: [.leftMouseDragged, .leftMouseUp]) {
            if nextEvent.type == .leftMouseUp {
                break
            }
            let currentLocation = NSEvent.mouseLocation
            resizePanel(
                from: startFrame,
                edge: edge,
                delta: NSPoint(
                    x: currentLocation.x - startLocation.x,
                    y: currentLocation.y - startLocation.y
                )
            )
        }
    }

    func showSettings() {
        let settingsWindow = settingsWindow ?? buildSettingsWindow()
        if !settingsWindowHasBeenShown {
            settingsWindow.center()
            settingsWindowHasBeenShown = true
        }
        model.accessibilityTrusted = AXIsProcessTrusted()
        settingsWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func showGroupManager() {
        let groupWindow = groupWindow ?? buildGroupWindow()
        groupWindow.center()
        groupWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func requestAccessibilityPermission() {
        updateHotkeySnapshot()
        let options: NSDictionary = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: true
        ]
        model.accessibilityTrusted = AXIsProcessTrustedWithOptions(options)
        if model.accessibilityTrusted, eventTap == nil {
            installEventTap()
        }
        if !model.accessibilityTrusted {
            startPermissionRetryTimer()
        }
    }

    func openAccessibilityAuthorization() {
        requestAccessibilityPermission()
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    func sendPasteShortcutIgnoringNext() {
        ignoreNextPasteShortcut = true
        refreshPasteTargetFromFrontmostApp()
        let targetApp = validPasteTarget(previousFrontmostApp)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if let app = targetApp, !app.isTerminated {
                app.activate(options: [])
            }
            self.postPasteWhenTargetIsReady(targetApp, attempt: 0)
        }
    }

    func pasteCurrentClipboardIgnoringNext() {
        sendPasteShortcutIgnoringNext()
    }

    func updateHotkeySnapshot() {
        hotkeySnapshot = HotkeySnapshot(settings: model.settings.pastePanelHotkey)
    }

    func updatePanelPinnedSnapshot() {
        panelPinnedSnapshot = model.panelPinned
    }

    func updateHeaderInteractiveRect(id: String, rect: CGRect) {
        let windowRect = NSRect(
            x: rect.minX + PanelMetrics.sideMargin,
            y: model.panelContentSize.height - rect.maxY + PanelMetrics.bottomMargin,
            width: rect.width,
            height: rect.height
        ).insetBy(dx: -4, dy: -4)
        headerInteractiveRectByID[id] = windowRect
    }

    func removeHeaderInteractiveRect(id: String) {
        headerInteractiveRectByID.removeValue(forKey: id)
    }

    func updateHistoryRowRect(id: UUID, rect: CGRect) {
        historyRowRectByID[id] = rect
    }

    func removeHistoryRowRect(id: UUID) {
        historyRowRectByID.removeValue(forKey: id)
    }

    private func postPasteWhenTargetIsReady(_ targetApp: NSRunningApplication?, attempt: Int) {
        let frontmostPID = NSWorkspace.shared.frontmostApplication?.processIdentifier
        let targetPID = targetApp?.processIdentifier
        let targetReady = targetPID == nil || frontmostPID == targetPID

        guard targetReady || attempt >= 12 else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.postPasteWhenTargetIsReady(targetApp, attempt: attempt + 1)
            }
            return
        }

        if !model.panelPinned {
            hidePanelIfAllowed()
        }
        postPasteShortcut()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.ignoreNextPasteShortcut = false
        }
    }

    private func postPasteShortcut() {
        let source = CGEventSource(stateID: .hidSystemState)
        let commandDown = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true)
        let vDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        let vUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        let commandUp = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false)
        vDown?.flags = .maskCommand
        vUp?.flags = .maskCommand
        commandDown?.post(tap: .cghidEventTap)
        vDown?.post(tap: .cghidEventTap)
        vUp?.post(tap: .cghidEventTap)
        commandUp?.post(tap: .cghidEventTap)
    }

    private func resizePanel(from startFrame: NSRect, edge: PanelResizeEdge, delta: NSPoint) {
        guard let panel else { return }
        let startContentSize = NSSize(
            width: startFrame.width - PanelMetrics.sideMargin * 2,
            height: startFrame.height - PanelMetrics.topMargin - PanelMetrics.bottomMargin
        )
        var contentSize = startContentSize

        if edge.resizesFromRight {
            contentSize.width = startContentSize.width + delta.x
        }
        if edge.resizesFromLeft {
            contentSize.width = startContentSize.width - delta.x
        }
        if edge.resizesFromTop {
            contentSize.height = startContentSize.height + delta.y
        }
        if edge.resizesFromBottom {
            contentSize.height = startContentSize.height - delta.y
        }

        contentSize = PanelMetrics.clampedContentSize(contentSize)
        let windowSize = PanelMetrics.windowSize(contentSize: contentSize)
        var nextFrame = NSRect(origin: startFrame.origin, size: windowSize)
        if edge.resizesFromLeft {
            nextFrame.origin.x = startFrame.maxX - windowSize.width
        }
        if edge.resizesFromBottom {
            nextFrame.origin.y = startFrame.maxY - windowSize.height
        }
        model.panelContentSize = contentSize
        panel.setFrame(nextFrame, display: true)
    }

    func refreshPasteTargetFromFrontmostApp() {
        rememberPasteTarget(NSWorkspace.shared.frontmostApplication)
    }

    private func rememberPasteTarget(_ app: NSRunningApplication?) {
        guard let app = validPasteTarget(app) else { return }
        enableManualAccessibilityIfSupported(for: app)
        previousFrontmostApp = app
    }

    private func enableManualAccessibilityIfSupported(for app: NSRunningApplication) {
        guard AXIsProcessTrusted() else { return }
        let application = AXUIElementCreateApplication(app.processIdentifier)
        _ = AXUIElementSetAttributeValue(application, "AXManualAccessibility" as CFString, kCFBooleanTrue)
    }

    private func validPasteTarget(_ app: NSRunningApplication?) -> NSRunningApplication? {
        guard let app,
              app.processIdentifier != NSRunningApplication.current.processIdentifier,
              !app.isTerminated else { return nil }
        return app
    }

    @discardableResult
    private func ensurePanel() -> ClipboardPanel {
        if let panel {
            return panel
        }
        return buildPanel()
    }

    @discardableResult
    private func buildPanel() -> ClipboardPanel {
        let panel = ClipboardPanel(
            contentRect: NSRect(origin: .zero, size: PanelMetrics.windowSize(contentSize: PanelMetrics.defaultContentSize())),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        panel.controller = self
        panel.acceptsMouseMovedEvents = true
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .transient, .fullScreenAuxiliary]
        let hostingView = NSHostingView(rootView: ClipboardOverlayView(model: model, controller: self)
            .environmentObject(model.systemAppearance))
        hostingView.wantsLayer = true
        hostingView.layer?.isOpaque = false
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor
        hostingView.layer?.masksToBounds = false
        panel.contentView = hostingView
        panel.contentView?.wantsLayer = true
        panel.contentView?.layer?.isOpaque = false
        panel.contentView?.layer?.backgroundColor = NSColor.clear.cgColor
        self.panel = panel
        return panel
    }

    private func releasePanelIfIdle() {
        guard !model.panelPinned,
              panel?.isVisible != true else {
            return
        }
        headerInteractiveRectByID.removeAll()
        panel?.contentView = nil
        panel?.controller = nil
        panel = nil
        relieveMemoryPressure()
    }

    private func relieveMemoryPressure() {
        malloc_zone_pressure_relief(nil, 0)
    }

    @discardableResult
    private func buildSettingsWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 560),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = L10n.settings
        window.isReleasedWhenClosed = false
        window.level = .normal
        window.collectionBehavior = [.managed, .fullScreenNone]
        window.setFrameAutosaveName("StowPasteSettings")
        window.contentView = NSHostingView(rootView: SettingsView(model: model, controller: self)
            .environmentObject(model.systemAppearance))
        settingsWindow = window
        return window
    }

    @discardableResult
    private func buildGroupWindow() -> NSPanel {
        let window = IconPanel(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 420),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = L10n.manageGroups
        window.isReleasedWhenClosed = false
        window.level = .normal
        window.contentView = NSHostingView(rootView: GroupManagerView(model: model)
            .environmentObject(model.systemAppearance))
        groupWindow = window
        return window
    }

    private func buildMainMenu() {
        let mainMenu = NSMenu()

        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(NSMenuItem(title: L10n.text("退出", "Quit"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        let editMenuItem = NSMenuItem()
        let editMenu = NSMenu(title: L10n.edit)
        editMenu.addItem(NSMenuItem(title: L10n.text("剪切", "Cut"), action: #selector(NSText.cut(_:)), keyEquivalent: "x"))
        editMenu.addItem(NSMenuItem(title: L10n.text("复制", "Copy"), action: #selector(NSText.copy(_:)), keyEquivalent: "c"))
        editMenu.addItem(NSMenuItem(title: L10n.paste, action: #selector(NSText.paste(_:)), keyEquivalent: "v"))
        editMenu.addItem(NSMenuItem(title: L10n.text("全选", "Select All"), action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)

        NSApp.mainMenu = mainMenu
    }

    private func buildStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let iconURL = Bundle.main.url(forResource: "AppIcon", withExtension: "icns"),
           let icon = NSImage(contentsOf: iconURL) {
            icon.size = NSSize(width: 18, height: 18)
            icon.isTemplate = true
            statusItem.button?.image = icon
        }
        statusItem.menu = makeStatusMenu()
    }

    private func makeStatusMenu() -> NSMenu {
        let menu = NSMenu()
        menu.delegate = self
        populateStatusMenu(menu)
        return menu
    }

    private func populateStatusMenu(_ menu: NSMenu) {
        menu.removeAllItems()
        if !model.accessibilityTrusted {
            menu.addItem(NSMenuItem(title: L10n.grantAccessibility, action: #selector(accessibilityFromMenu), keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
        }
        menu.addItem(NSMenuItem(title: L10n.showMainPanel, action: #selector(showMainPanelFromMenu), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: L10n.manageGroups, action: #selector(groupsFromMenu), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: L10n.settings, action: #selector(settingsFromMenu), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: L10n.text("退出", "Quit"), action: #selector(quit), keyEquivalent: "q"))
        menu.items.forEach { $0.target = self }
    }

    @objc private func openFromMenu() {
        showPanel()
    }

    @objc private func showMainPanelFromMenu() {
        showPanelCentered()
    }

    @objc private func settingsFromMenu() {
        showSettings()
    }

    @objc private func groupsFromMenu() {
        showGroupManager()
    }

    @objc private func accessibilityFromMenu() {
        openAccessibilityAuthorization()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    private func positionPanel() {
        let mouse = NSEvent.mouseLocation
        let anchor = focusedTextAnchor(fallback: mouse)
        positionPanel(near: anchor, preferredMouse: mouse)
    }

    private func positionPanelNearMouse() {
        let mouse = NSEvent.mouseLocation
        positionPanel(near: mouse, preferredMouse: mouse)
    }

    private func positionPanel(near anchor: NSPoint, preferredMouse mouse: NSPoint) {
        let panel = ensurePanel()
        let screen = NSScreen.screens.first { NSMouseInRect(anchor, $0.frame, false) }
            ?? NSScreen.screens.first { NSMouseInRect(mouse, $0.frame, false) }
            ?? NSScreen.main
        let visible = screen?.visibleFrame ?? NSScreen.main?.visibleFrame ?? .zero
        let size = model.panelContentSize
        let gap: CGFloat = 12
        let margin: CGFloat = 12
        let frame = mousePriorityPanelFrame(anchor: anchor, visible: visible, size: size, gap: gap, margin: margin)
        panel.setFrameOrigin(NSPoint(
            x: frame.origin.x - PanelMetrics.sideMargin,
            y: frame.origin.y - PanelMetrics.bottomMargin
        ))
    }

    private func mousePriorityPanelFrame(anchor: NSPoint, visible: NSRect, size: NSSize, gap: CGFloat, margin: CGFloat) -> NSRect {
        let candidates = [
            NSPoint(x: anchor.x + gap, y: anchor.y - size.height / 2),
            NSPoint(x: anchor.x + gap, y: anchor.y - size.height - gap),
            NSPoint(x: anchor.x + gap, y: anchor.y + gap),
            NSPoint(x: anchor.x - size.width - gap, y: anchor.y - size.height / 2),
            NSPoint(x: anchor.x - size.width - gap, y: anchor.y - size.height - gap),
            NSPoint(x: anchor.x - size.width - gap, y: anchor.y + gap)
        ]
        return candidates
            .map { NSRect(origin: $0, size: size) }
            .first { visible.insetBy(dx: margin, dy: margin).contains($0) }
            ?? NSRect(
                x: min(max(anchor.x + gap, visible.minX + margin), visible.maxX - size.width - margin),
                y: min(max(anchor.y - size.height / 2, visible.minY + margin), visible.maxY - size.height - margin),
                width: size.width,
                height: size.height
            )
    }

    private func positionPanelAtScreenCenter() {
        let panel = ensurePanel()
        let screen = NSScreen.screens.first { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) } ?? NSScreen.main
        let visible = screen?.visibleFrame ?? NSScreen.main?.visibleFrame ?? .zero
        let size = PanelMetrics.windowSize(contentSize: model.panelContentSize)
        panel.setFrameOrigin(NSPoint(
            x: visible.midX - size.width / 2,
            y: visible.midY - size.height / 2
        ))
    }

    private func stableAnchor(preferred: NSPoint?, fallback: NSPoint) -> NSPoint {
        guard let preferred else { return fallback }
        guard let mouseScreen = NSScreen.screens.first(where: { NSMouseInRect(fallback, $0.frame, false) }) else {
            return preferred
        }
        let expanded = mouseScreen.frame.insetBy(dx: -160, dy: -160)
        guard NSMouseInRect(preferred, expanded, false) else {
            return fallback
        }
        let maxDistance: CGFloat = 420
        if hypot(preferred.x - fallback.x, preferred.y - fallback.y) > maxDistance {
            return fallback
        }
        return preferred
    }

    private func focusedTextAnchor(fallback mouse: NSPoint) -> NSPoint {
        guard AXIsProcessTrusted(),
              let app = previousFrontmostApp ?? NSWorkspace.shared.frontmostApplication else {
            return mouse
        }
        guard let focusedElement = focusedElement(in: app) else { return mouse }
        var rangeValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(focusedElement, kAXSelectedTextRangeAttribute as CFString, &rangeValue) == .success,
              let rangeValue else {
            return mouse
        }
        var boundsValue: CFTypeRef?
        guard AXUIElementCopyParameterizedAttributeValue(
            focusedElement,
            kAXBoundsForRangeParameterizedAttribute as CFString,
            rangeValue,
            &boundsValue
        ) == .success,
              let boundsValue,
              CFGetTypeID(boundsValue) == AXValueGetTypeID() else {
            return mouse
        }
        let axValue = boundsValue as! AXValue
        var rect = CGRect.zero
        guard AXValueGetType(axValue) == .cgRect,
              AXValueGetValue(axValue, .cgRect, &rect) else {
            return mouse
        }
        let preferred = NSPoint(x: rect.maxX, y: rect.midY)
        return stableAnchor(preferred: preferred, fallback: mouse)
    }

    private func focusedElement(in app: NSRunningApplication) -> AXUIElement? {
        let application = AXUIElementCreateApplication(app.processIdentifier)
        if let focusedElement = copyFocusedElement(from: application) {
            return focusedElement
        }

        _ = AXUIElementSetAttributeValue(application, "AXManualAccessibility" as CFString, kCFBooleanTrue)
        for delay: useconds_t in [0, 10_000, 30_000] {
            if delay > 0 { usleep(delay) }
            if let focusedElement = copyFocusedElement(from: application) {
                return focusedElement
            }
        }
        return nil
    }

    private func copyFocusedElement(from application: AXUIElement) -> AXUIElement? {
        var focusedValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(application, kAXFocusedUIElementAttribute as CFString, &focusedValue) == .success,
              let focusedValue,
              CFGetTypeID(focusedValue) == AXUIElementGetTypeID() else {
            return nil
        }
        return (focusedValue as! AXUIElement)
    }

    private func focusedStringValue(from element: AXUIElement) -> String {
        var value: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXValueAttribute as CFString, &value) == .success {
            if let text = value as? String {
                return text
            }
            if let attributedText = value as? NSAttributedString {
                return attributedText.string
            }
        }

        var characterCountValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXNumberOfCharactersAttribute as CFString, &characterCountValue) == .success,
              let characterCount = characterCountValue as? NSNumber,
              characterCount.intValue > 0 else {
            return ""
        }
        var range = CFRange(location: 0, length: characterCount.intValue)
        guard let rangeValue = AXValueCreate(.cfRange, &range) else { return "" }
        var stringValue: CFTypeRef?
        if AXUIElementCopyParameterizedAttributeValue(
            element,
            kAXStringForRangeParameterizedAttribute as CFString,
            rangeValue,
            &stringValue
        ) == .success,
           let text = stringValue as? String {
            return text
        }
        return ""
    }

    private func focusedSelectionLocation(from element: AXUIElement) -> Int? {
        var rangeValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXSelectedTextRangeAttribute as CFString, &rangeValue) == .success,
              let rangeValue,
              CFGetTypeID(rangeValue) == AXValueGetTypeID() else {
            return nil
        }
        let axValue = rangeValue as! AXValue
        var range = CFRange(location: 0, length: 0)
        guard AXValueGetType(axValue) == .cfRange,
              AXValueGetValue(axValue, .cfRange, &range) else {
            return nil
        }
        return range.location
    }

    private func installEventTap() {
        updateHotkeySnapshot()
        guard AXIsProcessTrusted() else {
            NSLog("StowPaste: Accessibility permission is required for global paste interception.")
            model.accessibilityTrusted = false
            return
        }
        model.accessibilityTrusted = true
        let mask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: { proxy, type, event, refcon in
                guard let refcon else { return Unmanaged.passUnretained(event) }
                let controller = Unmanaged<AppController>.fromOpaque(refcon).takeUnretainedValue()
                return controller.handle(proxy: proxy, type: type, event: event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            NSLog("StowPaste: unable to install event tap. Accessibility permission is required.")
            model.accessibilityTrusted = false
            return
        }
        eventTap = tap
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        eventTapRunLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        startEventTapHealthTimer()
    }

    private func invalidateEventTap() {
        if let source = eventTapRunLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
            CFRunLoopSourceInvalidate(source)
            eventTapRunLoopSource = nil
        }
        if let eventTap {
            CFMachPortInvalidate(eventTap)
            self.eventTap = nil
        }
    }

    private func rebuildEventTap() {
        invalidateEventTap()
        installEventTap()
    }

    private func startEventTapHealthTimer() {
        eventTapHealthTimer?.invalidate()
        eventTapHealthTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.ensureEventTapHealthy()
            }
        }
        eventTapHealthTimer?.tolerance = 5
    }

    private func ensureEventTapHealthy() {
        updateHotkeySnapshot()
        let trusted = AXIsProcessTrusted()
        model.accessibilityTrusted = trusted
        guard trusted else {
            invalidateEventTap()
            startPermissionRetryTimer()
            return
        }
        guard let tap = eventTap else {
            installEventTap()
            return
        }
        guard CFMachPortIsValid(tap) else {
            rebuildEventTap()
            return
        }
        if !CGEvent.tapIsEnabled(tap: tap) {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
        if !CGEvent.tapIsEnabled(tap: tap) {
            rebuildEventTap()
        }
    }

    private func requestAccessibilityPermissionIfNeeded() {
        if AXIsProcessTrusted() {
            model.accessibilityTrusted = true
            installEventTap()
            return
        }
        requestAccessibilityPermission()
    }

    private func startPermissionRetryTimer() {
        permissionRetryTimer?.invalidate()
        permissionRetryTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                let trusted = AXIsProcessTrusted()
                self.model.accessibilityTrusted = trusted
                if trusted {
                    self.permissionRetryTimer?.invalidate()
                    self.permissionRetryTimer = nil
                    if self.eventTap == nil {
                        self.installEventTap()
                    }
                }
            }
        }
    }

    private func installOutsideClickMonitor() {
        removeOutsideClickMonitor()
        outsideClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]) { [weak self] event in
            DispatchQueue.main.async {
                guard let self else { return }
                guard !self.isResizingPanel else { return }
                if self.panel?.isVisible == true,
                   self.interactivePanelFrameContains(NSEvent.mouseLocation) {
                    return
                }
                self.refreshPasteTargetFromFrontmostApp()
                self.hidePanelIfAllowed()
            }
        }
        localClickMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown, .scrollWheel]) { [weak self] event in
            guard let self else { return event }
            guard !self.isResizingPanel else { return event }
            if self.panel?.isVisible == true,
               let window = event.window {
                if window === self.panel {
                } else if event.type != .scrollWheel {
                    self.hidePanelIfAllowed()
                }
            }
            return event
        }
    }

    private var visualPanelFrame: NSRect? {
        guard let panel else { return nil }
        let frame = panel.frame
        return NSRect(
            x: frame.minX + PanelMetrics.sideMargin,
            y: frame.minY + PanelMetrics.bottomMargin,
            width: model.panelContentSize.width,
            height: model.panelContentSize.height
        )
    }

    private func interactivePanelFrameContains(_ point: NSPoint) -> Bool {
        if visualPanelFrame?.contains(point) == true {
            return true
        }
        return false
    }

    private func installWorkspaceObservers() {
        let spaceObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.refreshPasteTargetFromFrontmostApp()
                self?.ensureEventTapHealthy()
                if self?.panel?.isVisible == true {
                    self?.hidePanelIfAllowed()
                }
            }
        }
        let activationObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                guard let self else { return }
                let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
                guard app?.processIdentifier != NSRunningApplication.current.processIdentifier else { return }
                self.refreshPasteTargetFromFrontmostApp()
                self.ensureEventTapHealthy()
            }
        }
        let wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.ensureEventTapHealthy()
            }
        }
        let sessionObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.sessionDidBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.ensureEventTapHealthy()
            }
        }
        workspaceObservers = [spaceObserver, activationObserver, wakeObserver, sessionObserver]
    }

    private func removeOutsideClickMonitor() {
        if let outsideClickMonitor {
            NSEvent.removeMonitor(outsideClickMonitor)
            self.outsideClickMonitor = nil
        }
        if let localClickMonitor {
            NSEvent.removeMonitor(localClickMonitor)
            self.localClickMonitor = nil
        }
    }

    private func handle(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap = eventTap {
                CGEvent.tapEnable(tap: tap, enable: true)
            }
            return Unmanaged.passUnretained(event)
        }
        guard type == .keyDown || type == .flagsChanged else { return Unmanaged.passUnretained(event) }
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

        if panel?.isVisible == true, panelPinnedSnapshot {
            return Unmanaged.passUnretained(event)
        }

        if matchesPastePanelHotkey(event) {
            if shouldPassThroughPanelHotkey() {
                return Unmanaged.passUnretained(event)
            }
            if ignoreNextPasteShortcut {
                return Unmanaged.passUnretained(event)
            }
            DispatchQueue.main.async { self.handlePanelHotkeyFromEventTap() }
            return nil
        }

        if panel?.isVisible == true, type == .keyDown {
            if !model.titleEditing,
               let index = matchesCommandNumberShortcut(event) {
                DispatchQueue.main.async { self.pasteVisibleItem(at: index) }
                return nil
            }
            switch keyCode {
            case 0x35:
                DispatchQueue.main.async { self.hidePanel() }
                return nil
            case 0x7D:
                DispatchQueue.main.async {
                    self.model.moveSelection(delta: 1)
                }
                return nil
            case 0x7E:
                DispatchQueue.main.async {
                    self.model.moveSelection(delta: -1)
                }
                return nil
            case 0x24, 0x4C:
                guard PanelKeyboardActionPolicy.shouldPasteOnEnter(
                    titleEditing: self.model.titleEditing
                ) else {
                    return Unmanaged.passUnretained(event)
                }
                DispatchQueue.main.async {
                    if let entry = self.model.selectedEntry {
                        self.model.paste(entry, using: self)
                    }
                }
                return nil
            default:
                break
            }
        }

        return Unmanaged.passUnretained(event)
    }

    private func pasteVisibleItem(at index: Int) {
        model.pasteVisibleItem(at: index, using: self)
    }

    private func handlePanelHotkeyFromEventTap() {
        guard !shouldPassThroughPanelHotkey(), !ignoreNextPasteShortcut else { return }
        if panel?.isVisible == true, let lastPasteShortcutAt, Date().timeIntervalSince(lastPasteShortcutAt) < 0.7 {
            self.lastPasteShortcutAt = nil
            model.markDoublePasteUsed()
            pasteCurrentClipboardIgnoringNext()
            return
        }
        lastPasteShortcutAt = Date()
        rememberPasteTarget(NSWorkspace.shared.frontmostApplication)
        showPanelFromHotkey()
    }

    private func matchesPastePanelHotkey(_ event: CGEvent) -> Bool {
        let hotkey = hotkeySnapshot
        if hotkey.doubleTap {
            return matchesDoubleTapHotkey(event)
        }
        guard event.type == .keyDown else { return false }
        guard event.getIntegerValueField(.keyboardEventKeycode) == hotkey.keyCode else { return false }
        let flags = event.flags
        return flags.contains(.maskCommand) == hotkey.command &&
            flags.contains(.maskAlternate) == hotkey.option &&
            flags.contains(.maskControl) == hotkey.control &&
            flags.contains(.maskShift) == hotkey.shift
    }

    private func matchesCommandNumberShortcut(_ event: CGEvent) -> Int? {
        guard event.type == .keyDown else { return nil }
        let flags = event.flags
        guard flags.contains(.maskCommand),
              !flags.contains(.maskAlternate),
              !flags.contains(.maskControl),
              !flags.contains(.maskShift) else { return nil }
        switch event.getIntegerValueField(.keyboardEventKeycode) {
        case 0x12: return 0
        case 0x13: return 1
        case 0x14: return 2
        case 0x15: return 3
        case 0x17: return 4
        default: return nil
        }
    }

    private func matchesDoubleTapHotkey(_ event: CGEvent) -> Bool {
        let hotkey = hotkeySnapshot
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        guard keyCode == hotkey.keyCode else {
            lastDoubleTapHotkeyKeyCode = nil
            lastHotkeyTriggerAt = nil
            return false
        }
        if event.type == .flagsChanged,
           let modifierFlag = Self.modifierFlag(for: keyCode),
           !event.flags.contains(modifierFlag) {
            return false
        }
        guard event.type == .keyDown || event.type == .flagsChanged else { return false }

        let now = Date()
        if lastDoubleTapHotkeyKeyCode == keyCode,
           let lastHotkeyTriggerAt,
           now.timeIntervalSince(lastHotkeyTriggerAt) < 0.55 {
            lastDoubleTapHotkeyKeyCode = nil
            self.lastHotkeyTriggerAt = nil
            return true
        } else {
            lastDoubleTapHotkeyKeyCode = keyCode
            lastHotkeyTriggerAt = now
            return false
        }
    }

    private static func modifierFlag(for keyCode: Int64) -> CGEventFlags? {
        switch keyCode {
        case 0x36, 0x37: return .maskCommand
        case 0x38, 0x3C: return .maskShift
        case 0x3A, 0x3D: return .maskAlternate
        case 0x3B, 0x3E: return .maskControl
        default: return nil
        }
    }

    private func shouldPassThroughPanelHotkey() -> Bool {
        if NSApp.isActive,
           panel?.isKeyWindow == false {
            return true
        }
        if NSApp.isActive,
           let keyWindow = NSApp.keyWindow,
           keyWindow === settingsWindow || keyWindow === groupWindow {
            return true
        }
        let frontmost = NSWorkspace.shared.frontmostApplication
        if frontmost?.processIdentifier == NSRunningApplication.current.processIdentifier,
           panel?.isVisible != true {
            return true
        }
        return false
    }
}

extension AppController: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        ensureEventTapHealthy()
        populateStatusMenu(menu)
    }
}

struct ClipboardOverlayView: View {
    static let internalGroupDragType = UTType(exportedAs: "store.aiware.stowpaste.group-drag")
    static let groupDropTypes: [UTType] = [internalGroupDragType, .text]

    @ObservedObject var model: AppModel
    let controller: AppController
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var systemAppearance: SystemAppearance
    @State private var editingTitleID: UUID?
    @State private var editingTitle = ""
    @State private var draggedEntryID: UUID?
    @State private var draggedFavoriteID: UUID?
    @State private var draggedGroupItemID: UUID?
    @State private var draggedGroupID: UUID?
    @State private var showingAddGroup = false
    @State private var showingGroupList = false
    @State private var groupName = ""
    @State private var groupSymbol = GroupIconPicker.symbols.first ?? "tray"
    @State private var editingGroupID: UUID?
    @State private var editingGroupName = ""
    @State private var editingGroupSymbol = GroupIconPicker.symbols.first ?? "tray"
    @State private var tooltip: TooltipState?
    @State private var tabsContentWidth: CGFloat = 0
    @State private var tabsViewportWidth: CGFloat = 0
    @State private var tabsScrollOffset: CGFloat = 0
    @State private var now = Date()
    private let relativeTimeTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private var items: [ClipboardEntry] { model.visibleHistory }
    private var panelWidth: CGFloat { model.panelContentSize.width }
    private var panelHeight: CGFloat { model.panelContentSize.height }
    private var tabsOverflowing: Bool { tabsContentWidth > tabsViewportWidth + 2 }
    private var maxTabsScrollOffset: CGFloat { max(0, tabsContentWidth - tabsViewportWidth) }
    private var tabsCanFadeLeading: Bool { tabsOverflowing && tabsScrollOffset > 1 }
    private var tabsCanFadeTrailing: Bool { tabsOverflowing && tabsScrollOffset < maxTabsScrollOffset - 1 }

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                if !model.accessibilityTrusted {
                    permissionBanner
                }
                toolbar
                Divider().opacity(0.2)
                if showingGroupList {
                    groupListPage
                        .transition(.opacity)
                } else {
                    historyList
                }
            }
            .frame(width: panelWidth, height: panelHeight)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(panelBackground)
            )
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(panelTint)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(panelTextBorderLayer)

            if model.shouldShowDoublePasteHint {
                doublePasteHint
                    .offset(y: -46)
            }
        }
        .frame(width: panelWidth, height: panelHeight)
        .coordinateSpace(name: "panel")
        .overlay(alignment: .top) {
            if let message = model.toastMessage {
                Text(message)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.orange.opacity(colorScheme == .dark ? 0.28 : 0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .offset(y: 8)
            }
        }
        .overlay(alignment: .topLeading) {
            if let tooltip {
                TooltipBubble(text: tooltip.text)
                    .position(
                        x: min(max(tooltip.x, 34), panelWidth - 34),
                        y: max(-PanelMetrics.topMargin + 14, tooltip.y - 18)
                    )
                    .zIndex(100)
            }
        }
        .overlay {
            if showingAddGroup {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { showingAddGroup = false }
                AddGroupView(
                    name: $groupName,
                    symbol: $groupSymbol,
                    submitTitle: L10n.add,
                    onCancel: { resetAddGroup() },
                    onSave: {
                        model.addGroup(name: groupName, symbol: groupSymbol)
                        resetAddGroup()
                    }
                )
                .frame(width: 320, height: 356)
                .background(.regularMaterial)
                .background(groupSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(20)
            }
        }
        .onChange(of: model.overlayVisible) { _, visible in
            if visible {
                resetPanelPresentation()
            }
        }
        .padding(.leading, PanelMetrics.sideMargin)
        .padding(.trailing, PanelMetrics.sideMargin)
        .padding(.top, PanelMetrics.topMargin)
        .padding(.bottom, PanelMetrics.bottomMargin)
        .tint(panelThemeColors.primary ?? Color.accentColor)
        .foregroundStyle(panelThemeColors.textPrimary ?? Color.primary)
        .environment(\.panelThemeColors, panelThemeColors)
        .preferredColorScheme(effectiveColorScheme)
        .onReceive(relativeTimeTimer) { value in
            now = value
        }
    }

    private var panelThemeColors: PanelThemeColors {
        guard let theme = model.settings.selectedCustomTheme else {
            return PanelThemeColors()
        }
        let neutralPalette = neutralPalette(for: theme, colorScheme: effectiveColorScheme)
        return PanelThemeColors(
            primary: Color(hex: theme.primary),
            secondary: Color(hex: theme.secondary),
            textPrimary: neutralPalette.title,
            textSecondary: neutralPalette.secondary,
            itemTitle: neutralPalette.title,
            itemSecondary: neutralPalette.secondary,
            tertiaryFill: neutralPalette.tertiaryFill,
            fill: Color(hex: theme.subtleFill)
        )
    }

    private var panelBackground: some ShapeStyle {
        if let theme = model.settings.selectedCustomTheme {
            return AnyShapeStyle(Color(hex: effectiveColorScheme == .dark ? theme.darkBackground : theme.lightBackground).opacity(0.96))
        }
        return effectiveColorScheme == .dark ? AnyShapeStyle(Color(red: 0.09, green: 0.10, blue: 0.12).opacity(0.96)) : AnyShapeStyle(Color(red: 0.98, green: 0.98, blue: 0.97).opacity(0.96))
    }

    private var panelTint: Color {
        if let theme = model.settings.selectedCustomTheme {
            return Color(hex: theme.panelTint).opacity(effectiveColorScheme == .dark ? 0.24 : 0.52)
        }
        return effectiveColorScheme == .dark ? Color(red: 0.07, green: 0.08, blue: 0.10).opacity(0.68) : Color.white.opacity(0.52)
    }

    private var effectiveColorScheme: ColorScheme {
        model.settings.colorScheme ?? systemAppearance.colorScheme
    }

    private var panelTextBorderColor: Color {
        return effectiveColorScheme == .dark ? (panelThemeColors.itemTitle ?? Color.white) : Color.black
    }

    private var panelTextBorderLayer: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .inset(by: 0.5)
            .stroke(panelTextBorderColor.opacity(0.3), lineWidth: 1)
    }

    private var rowHoverBackground: Color {
        if let theme = model.settings.selectedCustomTheme {
            return Color(hex: theme.secondary).opacity(effectiveColorScheme == .dark ? 0.20 : 0.20)
        }
        return effectiveColorScheme == .dark ? Color.white.opacity(0.055) : Color.black.opacity(0.035)
    }

    private var borderColor: Color {
        if let theme = model.settings.selectedCustomTheme {
            return Color(hex: theme.secondary).opacity(effectiveColorScheme == .dark ? 0.34 : 0.26)
        }
        return effectiveColorScheme == .dark ? Color.white.opacity(0.11) : Color.black.opacity(0.08)
    }

    private var groupBorderColor: Color {
        return (panelThemeColors.itemTitle ?? Color.primary).opacity(0.1)
    }

    private var groupSecondaryBackground: Color {
        secondarySurfaceBackground(theme: model.settings.selectedCustomTheme, colorScheme: effectiveColorScheme)
    }

    private var permissionBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "accessibility")
                .font(.system(size: 13, weight: .semibold))
            Text(L10n.accessibilityNeeded)
                .font(.system(size: 12))
            Spacer()
            Button(L10n.authorize) {
                controller.openAccessibilityAuthorization()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(effectiveColorScheme == .dark ? 0.18 : 0.12))
    }

    private var doublePasteHint: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "command")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(panelThemeColors.secondaryText)
                Text(L10n.doublePasteTip(model.settings.pastePanelHotkey.displayText))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(panelThemeColors.secondaryText)
                Spacer()
                Button(L10n.neverShow) {
                    model.dismissDoublePasteHint()
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundStyle(panelThemeColors.secondaryText)
                .cursor(.pointingHand)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(panelThemeColors.fill?.opacity(effectiveColorScheme == .dark ? 0.24 : 0.48) ?? (effectiveColorScheme == .dark ? Color.white.opacity(0.075) : Color.white.opacity(0.72)))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(borderColor, lineWidth: 1))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
    }

    private var toolbar: some View {
        HStack(spacing: 6) {
            toolbarTabsScroller
            toolbarActionButtons
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 6)
    }

    private var toolbarTabsScroller: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
                ForEach(ClipTab.allCases) { tab in
                    Button {
                        selectTab(tab)
                    } label: {
                        IconHitTarget(symbol: tab.symbol, active: model.activeTab == tab && model.activeGroupID == nil)
                    }
                    .buttonStyle(.plain)
                    .cursor(.pointingHand)
                    .tabButtonBackground(active: model.activeTab == tab && model.activeGroupID == nil)
                    .panelTooltip("\(tab.label) · \(model.count(for: tab))", tooltip: $tooltip)
                    .headerInteractiveArea(id: "tab-\(tab.id)", controller: controller)
                    .conditionalDrop(enabled: model.canPin(to: tab), delegate: TabDropDelegate(
                        tab: tab,
                        model: model,
                        draggedEntryID: $draggedEntryID
                    ))
                }

                ForEach(model.customGroups) { group in
                    Button {
                        selectGroup(group)
                    } label: {
                        IconHitTarget(symbol: group.symbol, active: model.activeGroupID == group.id)
                    }
                    .buttonStyle(.plain)
                    .cursor(.pointingHand)
                    .tabButtonBackground(active: model.activeGroupID == group.id)
                    .panelTooltip("\(group.name) · \(group.itemIDs.count)", tooltip: $tooltip)
                    .headerInteractiveArea(id: "group-\(group.id.uuidString)", controller: controller)
                    .onDrop(
                        of: AppModel.entryDropTypes,
                        delegate: TabDropDelegate(
                            group: group,
                            model: model,
                            draggedEntryID: $draggedEntryID
                        )
                    )
                    .contextMenu {
                        Button(L10n.delete, role: .destructive) { model.deleteGroup(group) }
                    }
                }
            }
            .padding(.bottom, 4)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { tabsContentWidth = proxy.size.width }
                        .onChange(of: proxy.size.width) { _, next in
                            tabsContentWidth = next
                        }
                }
            )
            .background(TabsScrollOffsetReader(offset: $tabsScrollOffset))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 38)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear { tabsViewportWidth = proxy.size.width }
                    .onChange(of: proxy.size.width) { _, next in
                        tabsViewportWidth = next
                    }
            }
        )
        .mask(toolbarTabsFadeMask)
        .clipped()
        .onChange(of: tabsContentWidth) { _, _ in
            tabsScrollOffset = min(tabsScrollOffset, maxTabsScrollOffset)
        }
        .onChange(of: tabsViewportWidth) { _, _ in
            tabsScrollOffset = min(tabsScrollOffset, maxTabsScrollOffset)
        }
    }

    private var toolbarTabsFadeMask: some View {
        HStack(spacing: 0) {
            if tabsCanFadeLeading {
                LinearGradient(colors: [.clear, .black], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 18)
            }
            Rectangle().fill(Color.black)
            if tabsCanFadeTrailing {
                LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 18)
            }
        }
    }

    private var toolbarActionButtons: some View {
        HStack(spacing: 2) {
            panelPinButton

            Button {
                showingAddGroup = true
                showingGroupList = false
            } label: {
                IconHitTarget(symbol: "plus", active: false)
            }
            .buttonStyle(.plain)
            .cursor(.pointingHand)
            .tabButtonBackground(active: false)
            .panelTooltip(L10n.addGroup, tooltip: $tooltip)
            .headerInteractiveArea(id: "toolbar-add-group", controller: controller)

            Button {
                showingGroupList.toggle()
                showingAddGroup = false
            } label: {
                IconHitTarget(symbol: showingGroupList ? "list.bullet.rectangle.fill" : "list.bullet.rectangle", active: showingGroupList)
            }
            .buttonStyle(.plain)
            .cursor(.pointingHand)
            .tabButtonBackground(active: showingGroupList)
            .panelTooltip(L10n.manageGroups, tooltip: $tooltip)
            .headerInteractiveArea(id: "toolbar-manage-groups", controller: controller)
        }
    }

    private var panelPinButton: some View {
        Button {
            model.panelPinned.toggle()
            controller.updatePanelPinnedSnapshot()
        } label: {
            IconHitTarget(symbol: model.panelPinned ? "pin.fill" : "pin", active: model.panelPinned)
        }
        .buttonStyle(.plain)
        .cursor(.pointingHand)
        .tabButtonBackground(active: model.panelPinned)
        .panelTooltip(model.panelPinned ? L10n.unpinFromScreen : L10n.pinToScreen, tooltip: $tooltip)
        .headerInteractiveArea(id: "toolbar-pin", controller: controller)
    }

    private func selectTab(_ tab: ClipTab) {
        showingGroupList = false
        showingAddGroup = false
        editingGroupID = nil
        tooltip = nil
        model.titleEditing = false
        model.activeTab = tab
        model.activeGroupID = nil
        model.selectedID = model.visibleHistory.first?.id
    }

    private func selectGroup(_ group: CustomGroup) {
        showingGroupList = false
        showingAddGroup = false
        editingGroupID = nil
        tooltip = nil
        model.titleEditing = false
        model.activeGroupID = group.id
        model.selectedID = model.visibleHistory.first?.id
    }

    private var groupListPage: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                if model.customGroups.isEmpty {
                    Text(L10n.noGroups)
                        .font(.system(size: 13))
                        .foregroundStyle(panelThemeColors.secondaryText)
                        .frame(maxWidth: .infinity, minHeight: 350)
                } else {
                    ForEach(model.customGroups) { group in
                        groupListRow(group)
                            .animation(.easeInOut(duration: 0.16), value: model.customGroups.map(\.id))
                            .onDrop(
                                of: Self.groupDropTypes,
                                delegate: GroupReorderDropDelegate(
                                    group: group,
                                    model: model,
                                    draggedGroupID: $draggedGroupID
                                )
                            )
                    }
                }
            }
            .padding(10)
        }
    }

    @ViewBuilder
    private func groupListRow(_ group: CustomGroup) -> some View {
        if editingGroupID == group.id {
            VStack(alignment: .leading, spacing: 10) {
                TextField(L10n.groupName, text: $editingGroupName)
                    .textFieldStyle(.plain)
                    .foregroundStyle(panelThemeColors.itemTitle ?? Color.primary)
                    .cursor(.iBeam)
                GroupIconGrid(symbol: $editingGroupSymbol, columns: 10, cell: 28)
                HStack {
                    Spacer()
                    Button(L10n.cancel) {
                        editingGroupID = nil
                    }
                    Button(L10n.done) {
                        model.updateGroup(group, name: editingGroupName, symbol: editingGroupSymbol)
                        editingGroupID = nil
                    }
                    .disabled(editingGroupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .font(.caption)
            }
            .padding(10)
            .background(groupSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(alignment: .bottom) {
                groupRowBottomBorder(color: groupBorderColor)
            }
        } else {
            HStack(spacing: 10) {
                groupReorderDragHandle(for: group)
                Image(systemName: group.symbol)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(panelThemeColors.itemSecondary ?? Color.secondary)
                    .frame(width: 28, height: 28)
                VStack(alignment: .leading, spacing: 3) {
                    Text(group.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(panelThemeColors.itemTitle ?? Color.primary)
                    Text("\(group.itemIDs.count)")
                        .font(.caption2)
                        .foregroundStyle(panelThemeColors.secondaryText)
                }
                Spacer()
                IconButton(symbol: "pencil", help: L10n.edit, compact: true, quiet: true, tooltip: $tooltip) {
                    editingGroupID = group.id
                    editingGroupName = group.name
                    editingGroupSymbol = group.symbol
                }
                IconButton(symbol: "trash", help: L10n.delete, compact: true, quiet: true, tooltip: $tooltip) {
                    model.deleteGroup(group)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(alignment: .bottom) {
                groupRowBottomBorder(color: groupBorderColor)
            }
        }
    }

    private func groupReorderDragHandle(for group: CustomGroup) -> some View {
        Image(systemName: "arrow.up.arrow.down")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(panelThemeColors.itemSecondary?.opacity(0.70) ?? Color.secondary.opacity(0.55))
            .frame(width: 16, height: 22)
            .contentShape(Rectangle())
            .onDrag {
                draggedGroupID = group.id
                return NSItemProvider(item: group.id.uuidString as NSString, typeIdentifier: Self.internalGroupDragType.identifier)
            }
            .cursor(.openHand)
    }

    private func resetAddGroup() {
        groupName = ""
        groupSymbol = GroupIconPicker.symbols.first ?? "tray"
        showingAddGroup = false
    }

    private func resetPanelPresentation() {
        showingAddGroup = false
        showingGroupList = false
        editingGroupID = nil
        tooltip = nil
        editingTitleID = nil
        model.titleEditing = false
    }

    private var historyList: some View {
        ScrollViewReader { proxy in
            let visibleItems = items
            let commandShortcutIndexes = commandShortcutIndexes(for: visibleItems)
            let canReorderItems = model.activeTab == .favorites || model.activeGroupID != nil
            let favoriteReorderEnabled = model.activeGroupID == nil && model.activeTab == .favorites
            ScrollView {
                LazyVStack(spacing: 4) {
                    if visibleItems.isEmpty {
                        Text(L10n.empty)
                            .font(.system(size: 13))
                            .foregroundStyle(panelThemeColors.secondaryText)
                            .frame(maxWidth: .infinity, minHeight: 350)
                    } else {
                        ForEach(visibleItems) { entry in
                            historyRowView(
                                entry,
                                canReorderItems: canReorderItems,
                                favoriteReorderEnabled: favoriteReorderEnabled,
                                commandShortcutIndex: model.panelPinned ? nil : commandShortcutIndexes[entry.id]
                            )
                            .id(entry.id)
                            .historyRowRect(id: entry.id, controller: controller)
                            .onDrop(
                                of: AppModel.entryDropTypes,
                                delegate: FavoriteDropDelegate(
                                    entry: entry,
                                    model: model,
                                    draggedFavoriteID: $draggedFavoriteID,
                                    draggedGroupItemID: $draggedGroupItemID,
                                    draggedEntryID: $draggedEntryID,
                                    groupID: model.activeGroupID,
                                    enabled: favoriteReorderEnabled
                                )
                            )
                            .contextMenu {
                                rowContextMenu(entry)
                            }
                        }
                    }
                }
                .padding(8)
            }
            .onChange(of: model.selectedID) { _, value in
                if let value {
                    withAnimation(.easeOut(duration: 0.15)) {
                        proxy.scrollTo(value, anchor: .center)
                    }
                }
            }
        }
    }

    private func commandShortcutIndexes(for visibleItems: [ClipboardEntry]) -> [UUID: Int] {
        Dictionary(uniqueKeysWithValues: visibleItems.prefix(5).enumerated().map { index, entry in
            (entry.id, index + 1)
        })
    }

    private func historyRowView(
        _ entry: ClipboardEntry,
        canReorderItems: Bool,
        favoriteReorderEnabled: Bool,
        commandShortcutIndex: Int?
    ) -> some View {
        HistoryRow(
            entry: entry,
            activeTab: model.activeTab,
            favorited: model.isFavorite(entry),
            draggable: canReorderItems,
            selected: entry.id == model.selectedEntry?.id,
            editing: editingTitleID == entry.id,
            isCurrentClipboardItem: entry.signature == model.currentClipboardSignature,
            commandShortcutIndex: commandShortcutIndex,
            now: now,
            editingTitle: $editingTitle,
            onBeginEdit: {
                beginEditingTitle(for: entry)
            },
            onCommitEdit: {
                commitEditingTitle(for: entry)
            },
            onSelect: {
                model.select(entry)
            },
            onPaste: {
                model.paste(entry, using: controller)
            },
            onDelete: {
                model.delete(entry)
            },
            onPin: {
                model.togglePin(entry)
            },
            onFavorite: {
                model.toggleFavorite(entry)
            },
            groups: model.customGroups,
            onAddToGroup: { group in
                model.add(entry, to: group)
            },
            onDrag: {
                prepareEntryDrag(entry)
            },
            sortDrag: {
                prepareSortDrag(entry, favoriteReorderEnabled: favoriteReorderEnabled)
            },
            tooltip: $tooltip
        )
    }

    private func beginEditingTitle(for entry: ClipboardEntry) {
        editingTitleID = entry.id
        editingTitle = entry.title
        model.titleEditing = true
    }

    private func commitEditingTitle(for entry: ClipboardEntry) {
        let next = editingTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if next.isEmpty {
            editingTitle = entry.title
        } else {
            model.rename(entry, title: next)
        }
        editingTitleID = nil
        model.titleEditing = false
    }

    private func prepareEntryDrag(_ entry: ClipboardEntry) -> NSItemProvider {
        draggedEntryID = entry.id
        draggedFavoriteID = nil
        draggedGroupItemID = nil
        return model.dragProvider(for: entry)
    }

    private func prepareSortDrag(_ entry: ClipboardEntry, favoriteReorderEnabled: Bool) -> NSItemProvider {
        draggedEntryID = entry.id
        draggedFavoriteID = nil
        draggedGroupItemID = nil
        if model.activeGroupID != nil {
            draggedGroupItemID = entry.id
        } else if favoriteReorderEnabled {
            draggedFavoriteID = entry.id
        }
        return model.dragProvider(for: entry)
    }

    @ViewBuilder
    private func rowContextMenu(_ entry: ClipboardEntry) -> some View {
        Button(L10n.paste) {
            model.paste(entry, using: controller)
        }
        if model.canPin(to: model.activeTab) {
            Button(entry.pinnedTabs.contains(model.activeTab) ? L10n.unpin : L10n.pin) {
                model.togglePin(entry)
            }
        }
        Button(model.isFavorite(entry) ? L10n.unfavorite : L10n.favorite) {
            model.toggleFavorite(entry)
        }
        Button(L10n.delete, role: .destructive) {
            model.delete(entry)
        }
    }

    private func groupMenu(for entry: ClipboardEntry) -> some View {
        TooltipMenu(title: L10n.addToGroup, tooltip: $tooltip) {
            if model.customGroups.isEmpty {
                Text(L10n.noGroups)
            } else {
                ForEach(model.customGroups) { group in
                    Button {
                        model.add(entry, to: group)
                    } label: {
                        Label(group.name, systemImage: group.symbol)
                    }
                }
            }
        } label: {
            CircleIcon(symbol: "plus.circle", active: false)
        }
    }
}

struct HistoryRow: View {
    let entry: ClipboardEntry
    let activeTab: ClipTab
    let favorited: Bool
    let draggable: Bool
    let selected: Bool
    let editing: Bool
    let isCurrentClipboardItem: Bool
    let commandShortcutIndex: Int?
    let now: Date
    @Binding var editingTitle: String
    let onBeginEdit: () -> Void
    let onCommitEdit: () -> Void
    let onSelect: () -> Void
    let onPaste: () -> Void
    let onDelete: () -> Void
    let onPin: () -> Void
    let onFavorite: () -> Void
    let groups: [CustomGroup]
    let onAddToGroup: (CustomGroup) -> Void
    let onDrag: () -> NSItemProvider
    let sortDrag: () -> NSItemProvider
    @Binding var tooltip: TooltipState?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.panelThemeColors) private var theme
    @FocusState private var titleFocused: Bool
    @State private var hovered = false
    @State private var thumbnailImage: NSImage?
    @State private var fileIcons: [String: NSImage] = [:]
    @State private var sourceAppIcon: NSImage?

    var body: some View {
        let canPin = activeTab != .favorites && activeTab != .image && activeTab != .file
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 7) {
                    HStack(spacing: 8) {
                        if draggable {
                            reorderDragHandle
                        }
                        itemIcon
                            .contentShape(Rectangle())
                            .onTapGesture(perform: onPaste)
                            .cursor(.pointingHand)
                        if editing {
                            TextField("", text: $editingTitle, onCommit: onCommitEdit)
                                .textFieldStyle(.plain)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(theme.itemTitle ?? Color.primary)
                                .focused($titleFocused)
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .fill(theme.primary ?? Color.accentColor)
                                        .frame(height: 1)
                                        .offset(y: 2)
                                }
                                .cursor(.iBeam)
                                .onAppear { titleFocused = true }
                                .onDisappear { titleFocused = false }
                        } else {
                            sourceTitle
                        }
                    }

                    summaryContent
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 7) {
                    HStack(spacing: 5) {
                        if let commandShortcutIndex {
                            CommandShortcutBadge(number: commandShortcutIndex)
                        }
                        Text(RelativeTimeFormatter.relativeTime(from: entry.updatedAt, now: now))
                            .font(.caption2)
                            .foregroundStyle(theme.itemSecondary ?? Color.secondary)
                            .contentShape(Rectangle())
                            .onTapGesture(perform: onPaste)
                            .cursor(.pointingHand)
                        if isCurrentClipboardItem {
                            deleteButtonPlaceholder
                        } else {
                            IconButton(symbol: "xmark", help: L10n.delete, compact: true, quiet: true, tooltip: $tooltip, action: onDelete)
                        }
                    }
                    HStack(spacing: 3) {
                        if canPin {
                            IconButton(
                                symbol: entry.pinnedTabs.contains(activeTab) ? "pin.fill" : "pin",
                                help: entry.pinnedTabs.contains(activeTab) ? L10n.unpin : L10n.pin,
                                compact: true,
                                active: entry.pinnedTabs.contains(activeTab),
                                tooltip: $tooltip,
                                action: onPin
                            )
                        }
                        IconButton(
                            symbol: favorited ? "star.fill" : "star",
                            help: favorited ? L10n.unfavorite : L10n.favorite,
                            compact: true,
                            active: favorited,
                            tooltip: $tooltip,
                            action: onFavorite
                        )
                        if !groups.isEmpty {
                            groupMenu
                        }
                    }
                }
                .frame(width: 110, alignment: .trailing)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(pasteHitArea)
        .background(hovered ? rowHoverBackground : Color.clear)
        .background(selected ? selectedBackground : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .onTapGesture(perform: onSelect)
        .onTapGesture(count: 2, perform: onPaste)
        .contentDragSource(enabled: true, entry: entry, provider: onDrag)
        .onHover { hovered = $0 }
        .onAppear(perform: prepareMedia)
        .onChange(of: entry.source) { _, _ in
            prepareSourceAppIcon()
        }
        .onChange(of: entry.imageThumbnailPNG) { _, _ in
            prepareThumbnail()
        }
        .onChange(of: entry.fileURLs) { _, _ in
            prepareFileIcons()
        }
    }

    private var pasteHitArea: some View {
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .onTapGesture(perform: onPaste)
            .cursor(.pointingHand)
    }

    private var deleteButtonPlaceholder: some View {
        Color.clear.frame(width: 22, height: 22)
    }

    private var reorderDragHandle: some View {
        Image(systemName: "arrow.up.arrow.down")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(theme.itemSecondary?.opacity(0.70) ?? Color.secondary.opacity(0.55))
            .frame(width: 16, height: 22)
            .contentShape(Rectangle())
            .onDrag { sortDrag() } preview: {
                DragPreview(entry: entry)
                    .opacity(1)
            }
            .cursor(.openHand)
    }

    private var sourceTitle: some View {
        HStack(spacing: 5) {
            if entry.hasDefaultTitle, let sourceAppName {
                Text(L10n.copiedFromPrefix)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(theme.itemTitle ?? Color.primary)
                    .lineLimit(1)
                sourceAppIconView
                Text(sourceAppName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(theme.itemTitle ?? Color.primary)
                    .lineLimit(1)
            } else {
                Text(displayTitle(for: entry))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(theme.itemTitle ?? Color.primary)
                    .lineLimit(1)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onBeginEdit)
        .cursor(.iBeam)
    }

    func displayTitle(for entry: ClipboardEntry) -> String {
        if entry.hasDefaultTitle, let sourceAppName {
            return L10n.copiedFrom(sourceAppName)
        }
        return entry.title
    }

    private var sourceAppName: String? {
        let name = entry.source?.appName.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return name.isEmpty ? nil : name
    }

    private var sourceAppIconView: some View {
        Group {
            if let sourceAppIcon {
                Image(nsImage: sourceAppIcon)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "app")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(theme.itemSecondary ?? Color.secondary)
            }
        }
        .frame(width: 16, height: 16)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }

    @ViewBuilder
    private var itemIcon: some View {
        switch entry.kind {
        case .image:
            symbolIcon("photo", prominent: true)
        case .file:
            if entry.fileURLs.count > 1 {
                stackedFileIcon
            } else {
                systemFileIcon
            }
        case .text:
            symbolIcon("text.alignleft", prominent: true)
        }
    }

    @ViewBuilder
    private var summaryContent: some View {
        if entry.kind == .image {
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.preview)
                    .font(.system(size: 12))
                    .foregroundStyle(theme.itemSecondary ?? Color.secondary)
                    .lineLimit(1)
                imageThumbnail
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture(perform: onPaste)
            .cursor(.pointingHand)
        } else {
            Text(entry.preview)
                .font(.system(size: 12))
                .foregroundStyle(theme.itemSecondary ?? Color.secondary)
                .lineLimit(entry.kind == .text && entry.preview.contains("\n") ? 3 : (entry.kind == .file ? 3 : 2))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture(perform: onPaste)
                .onTapGesture(count: 2, perform: onPaste)
                .cursor(.pointingHand)
        }
    }

    private var imageThumbnail: some View {
        Group {
            if let thumbnailImage {
                Image(nsImage: thumbnailImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(theme.itemSecondary ?? Color.secondary)
            }
        }
        .frame(width: 132, height: 82)
        .background(iconBackground)
        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
    }

    private var systemFileIcon: some View {
        Group {
            if let url = entry.fileURLs.first,
               let icon = fileIcons[url.path] {
                Image(nsImage: icon)
                    .resizable()
                    .scaledToFit()
                    .padding(3)
            } else {
                Image(systemName: "doc")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(theme.itemSecondary ?? Color.secondary)
            }
        }
        .frame(width: 22, height: 22)
        .background(iconBackground)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private var stackedFileIcon: some View {
        ZStack {
            ForEach(Array(entry.fileURLs.prefix(3).enumerated()), id: \.offset) { index, url in
                fileIconView(for: url, padding: 2)
                    .frame(width: 18, height: 18)
                    .background(iconBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .stroke(theme.secondary?.opacity(colorScheme == .dark ? 0.22 : 0.16) ?? Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.08), lineWidth: 0.6)
                    }
                    .offset(x: CGFloat(index) * 3, y: CGFloat(index) * -2)
            }
        }
        .frame(width: 22, height: 22, alignment: .center)
    }

    private func symbolIcon(_ symbol: String, prominent: Bool = false) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(prominent ? (theme.primary ?? theme.textPrimary ?? Color.accentColor) : (theme.itemSecondary ?? Color.secondary))
            .frame(width: 22, height: 22)
            .background(iconBackground)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private var iconBackground: Color {
        if let tertiaryFill = theme.tertiaryFill {
            return tertiaryFill
        }
        return colorScheme == .dark ? Color.white.opacity(0.07) : Color.black.opacity(0.055)
    }

    private var selectedBackground: Color {
        if let primary = theme.primary {
            return primary.opacity(colorScheme == .dark ? 0.26 : 0.16)
        }
        return colorScheme == .dark ? Color.accentColor.opacity(0.20) : Color.accentColor.opacity(0.13)
    }

    private var rowHoverBackground: Color {
        return selectedBackground.opacity(0.3)
    }

    private var groupMenu: some View {
        TooltipMenu(title: L10n.addToGroup, tooltip: $tooltip) {
            if groups.isEmpty {
                Text(L10n.noGroups)
            } else {
                ForEach(groups) { group in
                    Button {
                        onAddToGroup(group)
                    } label: {
                        Label(group.name, systemImage: group.symbol)
                    }
                }
            }
        } label: {
            CircleIcon(symbol: "plus.circle", active: false)
        }
    }

    @ViewBuilder
    private func fileIconView(for url: URL, padding: CGFloat) -> some View {
        if let icon = fileIcons[url.path] {
            Image(nsImage: icon)
                .resizable()
                .scaledToFit()
                .padding(padding)
        } else {
            Image(systemName: "doc")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(theme.itemSecondary ?? Color.secondary)
                .padding(padding)
        }
    }

    private func prepareMedia() {
        prepareThumbnail()
        prepareFileIcons()
        prepareSourceAppIcon()
    }

    private func prepareSourceAppIcon() {
        guard let bundleIdentifier = entry.source?.bundleIdentifier,
              let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
            sourceAppIcon = nil
            return
        }
        let bundleURL = appURL
        sourceAppIcon = NSWorkspace.shared.icon(forFile: bundleURL.path)
    }

    private func prepareThumbnail() {
        guard entry.kind == .image else {
            thumbnailImage = nil
            return
        }
        thumbnailImage = entry.imageThumbnailPNG.flatMap(NSImage.init(data:))
    }

    private func prepareFileIcons() {
        guard entry.kind == .file else {
            fileIcons = [:]
            return
        }
        fileIcons = Dictionary(uniqueKeysWithValues: entry.fileURLs.prefix(3).map { url in
            (url.path, NSWorkspace.shared.icon(forFile: url.path))
        })
    }
}

struct CommandShortcutBadge: View {
    let number: Int
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.panelThemeColors) private var theme

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "command")
                .font(.system(size: 8, weight: .semibold))
            Text("\(number)")
                .font(.system(size: 9, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(theme.itemSecondary ?? Color.secondary)
        .padding(.horizontal, 4)
        .frame(height: 17)
        .overlay(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .stroke(shortcutBorderColor, lineWidth: 0.8)
        )
    }

    private var shortcutBorderColor: Color {
        if let itemSecondary = theme.itemSecondary {
            return itemSecondary.opacity(colorScheme == .dark ? 0.42 : 0.32)
        }
        return colorScheme == .dark ? Color.white.opacity(0.22) : Color.black.opacity(0.16)
    }
}

struct DragPreview: View {
    let entry: ClipboardEntry
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.panelThemeColors) private var theme

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: entry.kind.symbol)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(theme.primary ?? Color.accentColor)
                .frame(width: 22, height: 22)
                .background(theme.tertiaryFill ?? (colorScheme == .dark ? Color.white.opacity(0.09) : Color.black.opacity(0.06)))
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(theme.itemTitle ?? Color.primary)
                    .lineLimit(1)
                Text(entry.preview)
                    .font(.system(size: 11))
                    .foregroundStyle(theme.itemSecondary ?? Color.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(colorScheme == .dark ? Color(red: 0.13, green: 0.14, blue: 0.16) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.35 : 0.18), radius: 10, x: 0, y: 4)
    }
}

struct FavoriteDropDelegate: DropDelegate {
    let entry: ClipboardEntry
    let model: AppModel
    @Binding var draggedFavoriteID: UUID?
    @Binding var draggedGroupItemID: UUID?
    @Binding var draggedEntryID: UUID?
    let groupID: UUID?
    let enabled: Bool

    func dropEntered(info: DropInfo) {
        if enabled,
           let draggedID = draggedFavoriteID,
           draggedID != entry.id {
            withAnimation(.spring(response: 0.24, dampingFraction: 0.86)) {
                model.moveFavorite(from: draggedID, to: entry.id)
            }
        } else if let groupID,
                  let draggedID = draggedGroupItemID,
                  draggedID != entry.id {
            withAnimation(.spring(response: 0.24, dampingFraction: 0.86)) {
                model.moveGroupItem(from: draggedID, to: entry.id, in: groupID)
            }
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        let handled = (enabled && draggedFavoriteID != nil) || (groupID != nil && draggedGroupItemID != nil)
        draggedFavoriteID = nil
        draggedGroupItemID = nil
        if handled {
            draggedEntryID = nil
        }
        guard handled else { return false }
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: (enabled || groupID != nil) ? .move : .cancel)
    }
}

struct GroupReorderDropDelegate: DropDelegate {
    let group: CustomGroup
    let model: AppModel
    @Binding var draggedGroupID: UUID?

    func dropEntered(info: DropInfo) {
        guard let draggedGroupID,
              draggedGroupID != group.id else { return }
        withAnimation(.spring(response: 0.24, dampingFraction: 0.86)) {
            model.moveGroup(from: draggedGroupID, to: group.id)
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        guard draggedGroupID != nil else { return false }
        draggedGroupID = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

struct TabDropDelegate: DropDelegate {
    let tab: ClipTab?
    let group: CustomGroup?
    let model: AppModel
    @Binding var draggedEntryID: UUID?

    init(tab: ClipTab, model: AppModel, draggedEntryID: Binding<UUID?>) {
        self.tab = tab
        self.group = nil
        self.model = model
        self._draggedEntryID = draggedEntryID
    }

    init(group: CustomGroup, model: AppModel, draggedEntryID: Binding<UUID?>) {
        self.tab = nil
        self.group = group
        self.model = model
        self._draggedEntryID = draggedEntryID
    }

    func performDrop(info: DropInfo) -> Bool {
        if let draggedEntryID {
            dropEntry(draggedEntryID)
            return true
        }

        return false
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .copy)
    }

    private func dropEntry(_ entryID: UUID) {
        if let tab {
            model.addEntry(entryID, to: tab)
        } else if let group {
            model.addEntry(entryID, to: group)
        }
        draggedEntryID = nil
    }
}

struct TooltipState: Equatable {
    let text: String
    let x: CGFloat
    let y: CGFloat
}

struct TabsScrollOffsetReader: NSViewRepresentable {
    @Binding var offset: CGFloat

    func makeCoordinator() -> TabsScrollOffsetCoordinator {
        TabsScrollOffsetCoordinator(offset: $offset)
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async {
            context.coordinator.attach(to: view.enclosingScrollView)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.attach(to: nsView.enclosingScrollView)
        }
    }
}

final class TabsScrollOffsetCoordinator: NSObject {
    @Binding private var offset: CGFloat
    private weak var scrollView: NSScrollView?
    private var observer: NSObjectProtocol?

    init(offset: Binding<CGFloat>) {
        self._offset = offset
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func attach(to scrollView: NSScrollView?) {
        guard self.scrollView !== scrollView else {
            updateOffset()
            return
        }
        if let observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
        self.scrollView = scrollView
        guard let scrollView else {
            offset = 0
            return
        }
        scrollView.contentView.postsBoundsChangedNotifications = true
        observer = NotificationCenter.default.addObserver(
            forName: NSView.boundsDidChangeNotification,
            object: scrollView.contentView,
            queue: .main
        ) { [weak self] _ in
            self?.updateOffset()
        }
        updateOffset()
    }

    private func updateOffset() {
        offset = scrollView?.contentView.bounds.origin.x ?? 0
    }
}

struct CircleIcon: View {
    let symbol: String
    let active: Bool
    @Environment(\.panelThemeColors) private var theme

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(active ? (theme.primary ?? Color.accentColor) : (theme.itemSecondary ?? Color.secondary))
            .frame(width: 22, height: 22)
            .background(theme.tertiaryFill.map { AnyShapeStyle($0) } ?? AnyShapeStyle(.ultraThinMaterial))
            .clipShape(Circle())
    }
}

struct TooltipMenu<MenuContent: View, LabelContent: View>: View {
    let title: String
    @Binding var tooltip: TooltipState?
    @ViewBuilder var menuContent: () -> MenuContent
    @ViewBuilder var label: () -> LabelContent

    var body: some View {
        Menu {
            menuContent()
        } label: {
            label()
                .contentShape(Rectangle())
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .onHoverTooltip(title, tooltip: $tooltip)
        .cursor(.pointingHand)
    }
}

struct IconButton: View {
    let symbol: String
    let help: String
    var compact = false
    var quiet = false
    var active = false
    @Binding var tooltip: TooltipState?
    let action: () -> Void
    @Environment(\.panelThemeColors) private var theme

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: compact ? 11 : 12, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: compact ? 22 : 26, height: compact ? 22 : 26)
                .background(iconBackground)
                .clipShape(Circle())
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHoverTooltip(help, tooltip: $tooltip)
        .cursor(.pointingHand)
    }

    private var iconColor: Color {
        if active {
            return theme.primary ?? Color.accentColor
        }
        return theme.itemSecondary ?? Color.secondary
    }

    private var iconBackground: AnyShapeStyle {
        if quiet {
            return AnyShapeStyle(Color.clear)
        }
        return theme.tertiaryFill.map { AnyShapeStyle($0) } ?? AnyShapeStyle(.ultraThinMaterial)
    }
}

struct TooltipBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2)
            .foregroundStyle(Color.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            .shadow(color: .black.opacity(0.22), radius: 8, y: 3)
            .fixedSize()
            .allowsHitTesting(false)
    }
}

private func groupRowBottomBorder(color: Color) -> some View {
    Rectangle()
        .fill(color)
        .frame(height: 1)
        .padding(.horizontal, 10)
}

struct IconHitTarget: View {
    let symbol: String
    let active: Bool
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.panelThemeColors) private var theme

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(iconColor)
        }
        .frame(width: 34, height: 30)
        .contentShape(Rectangle())
    }

    private var iconColor: Color {
        if active {
            return theme.primary ?? Color.accentColor
        }
        if let itemSecondary = theme.itemSecondary {
            return itemSecondary
        }
        if let itemTitle = theme.itemTitle {
            return itemTitle
        }
        return colorScheme == .dark ? Color.white : Color(hex: "#333333")
    }
}

struct HoverBackground: ViewModifier {
    @State private var hovering = false
    @Environment(\.panelThemeColors) private var theme
    func body(content: Content) -> some View {
        content
            .background(hovering ? (theme.tertiaryFill ?? Color.primary.opacity(0.06)) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .onHover { hovering = $0 }
    }
}

struct TabButtonBackground: ViewModifier {
    let active: Bool
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.panelThemeColors) private var theme
    @State private var hovering = false

    func body(content: Content) -> some View {
        content
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .onHover { hovering = $0 }
    }

    private var background: Color {
        if active {
            if let primary = theme.primary {
                return primary.opacity(colorScheme == .dark ? 0.30 : 0.18)
            }
            return Color.accentColor.opacity(colorScheme == .dark ? 0.28 : 0.16)
        }
        if hovering, let tertiaryFill = theme.tertiaryFill {
            return tertiaryFill
        }
        return hovering ? Color.primary.opacity(colorScheme == .dark ? 0.09 : 0.055) : Color.clear
    }
}

struct ButtonTooltipModifier: ViewModifier {
    let title: String
    @Binding var tooltip: TooltipState?
    @State private var frame: CGRect = .zero

    func body(content: Content) -> some View {
        content
            .onHover { hovering in
                if hovering {
                    tooltip = TooltipState(text: title, x: frame.midX, y: frame.minY)
                } else if tooltip?.text == title {
                    tooltip = nil
                }
            }
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            frame = proxy.frame(in: .named("panel"))
                        }
                        .onChange(of: proxy.frame(in: .named("panel"))) { _, next in
                            frame = next
                        }
                }
            )
    }
}

struct HoverTooltipModifier: ViewModifier {
    let title: String
    @Binding var tooltip: TooltipState?
    @State private var frame: CGRect = .zero

    func body(content: Content) -> some View {
        content
            .onHover { hovering in
                if hovering {
                    tooltip = TooltipState(text: title, x: frame.midX, y: frame.minY)
                } else if tooltip?.text == title {
                    tooltip = nil
                }
            }
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            frame = proxy.frame(in: .named("panel"))
                        }
                        .onChange(of: proxy.frame(in: .named("panel"))) { _, next in
                            frame = next
                        }
                }
            )
    }
}

struct CursorModifier: ViewModifier {
    let cursor: NSCursor
    @State private var cursorPushed = false

    func body(content: Content) -> some View {
        content.onHover { hovering in
            if hovering {
                guard !cursorPushed else { return }
                cursor.push()
                cursorPushed = true
            } else if cursorPushed {
                NSCursor.pop()
                cursorPushed = false
            }
        }
        .onDisappear {
            if cursorPushed {
                NSCursor.pop()
                cursorPushed = false
            }
        }
    }
}

struct ContentDragSourceModifier: ViewModifier {
    let enabled: Bool
    let entry: ClipboardEntry
    let provider: () -> NSItemProvider

    @ViewBuilder
    func body(content: Content) -> some View {
        if enabled {
            content.onDrag { provider() } preview: {
                DragPreview(entry: entry)
                    .opacity(1)
            }
        } else {
            content
        }
    }
}

struct HeaderInteractiveRectModifier: ViewModifier {
    let id: String
    let controller: AppController

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        controller.updateHeaderInteractiveRect(id: id, rect: proxy.frame(in: .named("panel")))
                    }
                    .onDisappear {
                        controller.removeHeaderInteractiveRect(id: id)
                    }
                    .onChange(of: proxy.frame(in: .named("panel"))) { _, next in
                        controller.updateHeaderInteractiveRect(id: id, rect: next)
                    }
            }
        )
    }
}

struct HistoryRowRectModifier: ViewModifier {
    let id: UUID
    let controller: AppController

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        controller.updateHistoryRowRect(id: id, rect: proxy.frame(in: .named("panel")))
                    }
                    .onDisappear {
                        controller.removeHistoryRowRect(id: id)
                    }
                    .onChange(of: proxy.frame(in: .named("panel"))) { _, next in
                        controller.updateHistoryRowRect(id: id, rect: next)
                    }
            }
        )
    }
}

extension View {
    func hoverBackground() -> some View {
        modifier(HoverBackground())
    }

    func tabButtonBackground(active: Bool) -> some View {
        modifier(TabButtonBackground(active: active))
    }

    @ViewBuilder
    func conditionalDrop<Delegate: DropDelegate>(enabled: Bool, delegate: Delegate) -> some View {
        if enabled {
            self.onDrop(of: AppModel.entryDropTypes, delegate: delegate)
        } else {
            self
        }
    }

    func panelTooltip(_ title: String, tooltip: Binding<TooltipState?>) -> some View {
        modifier(ButtonTooltipModifier(title: title, tooltip: tooltip))
    }

    func onHoverTooltip(_ title: String, tooltip: Binding<TooltipState?>) -> some View {
        modifier(HoverTooltipModifier(title: title, tooltip: tooltip))
    }

    func cursor(_ cursor: NSCursor) -> some View {
        modifier(CursorModifier(cursor: cursor))
    }

    func contentDragSource(enabled: Bool, entry: ClipboardEntry, provider: @escaping () -> NSItemProvider) -> some View {
        modifier(ContentDragSourceModifier(enabled: enabled, entry: entry, provider: provider))
    }

    func headerInteractiveArea(id: String, controller: AppController) -> some View {
        modifier(HeaderInteractiveRectModifier(id: id, controller: controller))
    }

    func historyRowRect(id: UUID, controller: AppController) -> some View {
        modifier(HistoryRowRectModifier(id: id, controller: controller))
    }
}

struct GroupIconPicker {
    static let symbols = [
        "tray", "folder", "tag", "sparkles", "brain.head.profile",
        "bolt", "book", "doc.text", "link", "number",
        "quote.bubble", "terminal", "hammer", "paintbrush", "briefcase",
        "cart", "heart", "flag", "paperclip", "archivebox"
    ]
}

struct AddGroupView: View {
    @Binding var name: String
    @Binding var symbol: String
    var submitTitle: String = L10n.add
    let onCancel: () -> Void
    let onSave: () -> Void
    @Environment(\.panelThemeColors) private var theme
    @FocusState private var nameFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L10n.addGroup)
                .font(.headline)
                .foregroundStyle(theme.itemTitle ?? Color.primary)
            TextField(L10n.groupName, text: $name)
                .textFieldStyle(.roundedBorder)
                .focused($nameFocused)
                .cursor(.iBeam)
            Text(L10n.chooseIcon)
                .font(.caption)
                .foregroundStyle(theme.itemTitle ?? Color.primary)
            GroupIconGrid(symbol: $symbol, columns: 5, cell: 32)
            Spacer()
            HStack(spacing: 10) {
                Spacer()
                Button(L10n.cancel, action: onCancel)
                Button(submitTitle, action: onSave)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(18)
        .tint(theme.primary ?? Color.accentColor)
        .foregroundStyle(theme.itemTitle ?? Color.primary)
        .onAppear {
            DispatchQueue.main.async {
                nameFocused = true
            }
        }
    }
}

struct GroupIconGrid: View {
    @Binding var symbol: String
    let columns: Int
    let cell: CGFloat
    @Environment(\.panelThemeColors) private var theme

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(cell)), count: columns), spacing: 8) {
            ForEach(GroupIconPicker.symbols, id: \.self) { item in
                Button {
                    symbol = item
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(symbol == item ? (theme.primary ?? Color.accentColor).opacity(0.18) : Color.clear)
                        Image(systemName: item)
                            .foregroundStyle(symbol == item ? (theme.primary ?? Color.accentColor) : theme.secondaryText)
                    }
                    .frame(width: cell, height: cell)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .cursor(.pointingHand)
            }
        }
    }
}

struct GroupManagerView: View {
    static let internalGroupDragType = UTType(exportedAs: "store.aiware.stowpaste.group-drag")
    static let groupDropTypes: [UTType] = [internalGroupDragType, .text]

    @ObservedObject var model: AppModel
    @State private var draggedGroupID: UUID?
    @State private var editingGroupID: UUID?
    @State private var draftName = ""
    @State private var draftSymbol = GroupIconPicker.symbols.first ?? "tray"
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.manageGroups)
                .font(.headline)
                .foregroundStyle(groupThemeColors.itemTitle ?? Color.primary)
                .padding(18)
            Divider()
            if model.customGroups.isEmpty {
                Text(L10n.noGroups)
                    .font(.system(size: 13))
                    .foregroundStyle(groupThemeColors.itemSecondary ?? Color.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(model.customGroups) { group in
                            groupRow(group)
                            .animation(.easeInOut(duration: 0.16), value: model.customGroups.map(\.id))
                            .onDrop(
                                of: Self.groupDropTypes,
                                delegate: GroupReorderDropDelegate(
                                    group: group,
                                    model: model,
                                    draggedGroupID: $draggedGroupID
                                )
                            )
                        }
                    }
                    .padding(12)
                }
            }
        }
        .frame(width: 360, height: 420)
        .background(groupBackground)
        .tint(groupThemeColors.primary ?? Color.accentColor)
        .foregroundStyle(groupThemeColors.itemTitle ?? Color.primary)
        .environment(\.panelThemeColors, groupThemeColors)
    }

    private var groupThemeColors: PanelThemeColors {
        guard let theme = model.settings.selectedCustomTheme else {
            return PanelThemeColors()
        }
        let neutralPalette = neutralPalette(for: theme, colorScheme: colorScheme)
        return PanelThemeColors(
            primary: Color(hex: theme.primary),
            secondary: Color(hex: theme.secondary),
            textPrimary: neutralPalette.title,
            textSecondary: neutralPalette.secondary,
            itemTitle: neutralPalette.title,
            itemSecondary: neutralPalette.secondary,
            tertiaryFill: neutralPalette.tertiaryFill,
            fill: Color(hex: theme.subtleFill)
        )
    }

    private var groupBackground: Color {
        if let theme = model.settings.selectedCustomTheme {
            return Color(hex: colorScheme == .dark ? theme.darkBackground : theme.lightBackground)
        }
        return colorScheme == .dark ? Color(red: 0.09, green: 0.10, blue: 0.12) : Color(red: 0.98, green: 0.98, blue: 0.97)
    }

    private var groupSecondaryBackground: Color {
        secondarySurfaceBackground(theme: model.settings.selectedCustomTheme, colorScheme: colorScheme)
    }

    private var groupBorderColor: Color {
        return (groupThemeColors.itemTitle ?? Color.primary).opacity(0.1)
    }

    @ViewBuilder
    private func groupRow(_ group: CustomGroup) -> some View {
        if editingGroupID == group.id {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    TextField(L10n.groupName, text: $draftName)
                        .textFieldStyle(.plain)
                        .foregroundStyle(groupThemeColors.itemTitle ?? Color.primary)
                    Button(L10n.done) {
                        model.updateGroup(group, name: draftName, symbol: draftSymbol)
                        editingGroupID = nil
                    }
                    .disabled(draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(28)), count: 8), spacing: 6) {
                    ForEach(GroupIconPicker.symbols, id: \.self) { item in
                        Button {
                            draftSymbol = item
                        } label: {
                            Image(systemName: item)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(draftSymbol == item ? (groupThemeColors.primary ?? Color.accentColor) : (groupThemeColors.itemSecondary ?? Color.secondary))
                                .frame(width: 26, height: 26)
                                .background(draftSymbol == item ? (groupThemeColors.primary ?? Color.accentColor).opacity(0.18) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .cursor(.pointingHand)
                    }
                }
            }
            .padding(10)
            .background(groupSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(alignment: .bottom) {
                groupRowBottomBorder(color: groupBorderColor)
            }
        } else {
            HStack(spacing: 10) {
                windowGroupReorderDragHandle(for: group)
                Image(systemName: group.symbol)
                    .foregroundStyle(groupThemeColors.itemSecondary ?? Color.secondary)
                    .frame(width: 28, height: 28)
                VStack(alignment: .leading, spacing: 3) {
                    Text(group.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(groupThemeColors.itemTitle ?? Color.primary)
                    Text("\(group.itemIDs.count)")
                        .font(.caption2)
                        .foregroundStyle(groupThemeColors.itemSecondary ?? Color.secondary)
                }
                Spacer()
                Button {
                    editingGroupID = group.id
                    draftName = group.name
                    draftSymbol = group.symbol
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(groupThemeColors.itemSecondary ?? Color.secondary)
                }
                .buttonStyle(.plain)
                .cursor(.pointingHand)
                Button(role: .destructive) {
                    model.deleteGroup(group)
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(groupThemeColors.itemSecondary ?? Color.secondary)
                }
                .buttonStyle(.plain)
                .cursor(.pointingHand)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(alignment: .bottom) {
                groupRowBottomBorder(color: groupBorderColor)
            }
        }
    }

    private func windowGroupReorderDragHandle(for group: CustomGroup) -> some View {
        Image(systemName: "arrow.up.arrow.down")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(groupThemeColors.itemSecondary?.opacity(0.70) ?? Color.secondary.opacity(0.55))
            .frame(width: 16, height: 22)
            .contentShape(Rectangle())
            .onDrag {
                draggedGroupID = group.id
                return NSItemProvider(item: group.id.uuidString as NSString, typeIdentifier: Self.internalGroupDragType.identifier)
            }
            .cursor(.openHand)
    }
}

struct SettingsView: View {
    @ObservedObject var model: AppModel
    let controller: AppController
    @State private var draft: AppSettings
    @State private var showingThemeProposalSheet = false
    @State private var pendingHistoryRetentionPeriod: HistoryRetentionPeriod?
    @State private var showingHistoryRetentionConfirmation = false
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var systemAppearance: SystemAppearance
    private let settingsLabelWidth: CGFloat = 120
    private let settingsControlWidth: CGFloat = 170
    private let settingsRowMinHeight: CGFloat = 28

    init(model: AppModel, controller: AppController) {
        self.model = model
        self.controller = controller
        _draft = State(initialValue: model.settings)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(L10n.settings)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(settingsThemeColors.itemTitle ?? Color.primary)
                Spacer()
                Button(L10n.done) {
                    model.updateSettings(draft)
                    NSApp.keyWindow?.close()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(20)

            Divider().opacity(0.18)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    settingsSection(L10n.permissions) {
                        HStack {
                        Label(
                            model.accessibilityTrusted ? L10n.accessibilityGranted : L10n.accessibilityRequired,
                            systemImage: model.accessibilityTrusted ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
                        )
                        .foregroundStyle(model.accessibilityTrusted ? .green : .orange)
                        Spacer()
                        Button(L10n.openAuthorization) {
                            controller.openAccessibilityAuthorization()
                        }
                    }
                    }

                    settingsSection(L10n.basics) {
                        settingsValueRow(L10n.historyLimit) {
                            Picker("", selection: historyRetentionSelection) {
                                ForEach(HistoryRetentionPeriod.allCases) { period in
                                    Text(period.label).tag(period)
                                }
                            }
                            .labelsHidden()
                        }
                        settingsValueRow(L10n.theme) {
                            HStack(spacing: 6) {
                                DeleteCustomThemeButton(themeID: selectedCustomThemeID, action: deleteSelectedCustomTheme)
                                Picker("", selection: themeSelection) {
                                    Text(L10n.system).tag("system")
                                    Text(L10n.light).tag("light")
                                    Text(L10n.dark).tag("dark")
                                    ForEach(draft.customThemes) { theme in
                                        Text(theme.name).tag("custom:\(theme.id)")
                                    }
                                    Divider()
                                    Text(L10n.customTheme).tag("__custom_theme__")
                                }
                                .labelsHidden()
                            }
                        }
                        settingsValueRow(L10n.hotkey) {
                            HotkeyRecorderView(hotkey: $draft.pastePanelHotkey)
                        }
                        settingsValueRow(L10n.launchAtLogin) {
                            SmallSwitchToggle(isOn: Binding(
                                get: { launchAtLogin },
                                set: { enabled in
                                    toggleLaunchAtLogin(enabled)
                                }
                            ))
                        }
                    }

                }
                .padding(18)
            }
        }
        .frame(width: 520, height: 560)
        .background(settingsBackground)
        .background(SettingsInitialFocusGuard())
        .tint(settingsThemeColors.primary ?? Color.accentColor)
        .foregroundStyle(settingsThemeColors.itemTitle ?? Color.primary)
        .environment(\.panelThemeColors, settingsThemeColors)
        .onChange(of: draft) { _, value in
            model.updateSettings(value)
            DispatchQueue.main.async { self.controller.updateHotkeySnapshot() }
        }
        .onAppear {
            model.accessibilityTrusted = AXIsProcessTrusted()
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
        .sheet(isPresented: $showingThemeProposalSheet) {
            ThemeProposalSheet(
                model: model,
                onCancel: {
                    showingThemeProposalSheet = false
                },
                onApply: { theme in
                    model.applyCustomTheme(theme)
                    draft = model.settings
                    showingThemeProposalSheet = false
                },
                onSave: { theme in
                    model.saveCustomTheme(theme)
                    draft = model.settings
                    showingThemeProposalSheet = false
                }
            )
        }
        .alert(L10n.historyRetentionConfirmTitle, isPresented: $showingHistoryRetentionConfirmation) {
            Button(L10n.cancel, role: .cancel) {
                pendingHistoryRetentionPeriod = nil
            }
            Button(L10n.continueAction, role: .destructive) {
                if let pendingHistoryRetentionPeriod {
                    confirmHistoryRetentionChange(to: pendingHistoryRetentionPeriod)
                }
            }
        } message: {
            Text(L10n.historyRetentionConfirmMessage)
        }
        .preferredColorScheme(preferredSettingsColorScheme)
    }

    private var historyRetentionSelection: Binding<HistoryRetentionPeriod> {
        Binding(
            get: { draft.historyRetentionPeriod },
            set: { next in
                if next.isShorter(than: draft.historyRetentionPeriod) {
                    pendingHistoryRetentionPeriod = next
                    showingHistoryRetentionConfirmation = true
                } else {
                    draft.historyRetentionPeriod = next
                }
            }
        )
    }

    private func confirmHistoryRetentionChange(to period: HistoryRetentionPeriod) {
        draft.historyRetentionPeriod = period
        pendingHistoryRetentionPeriod = nil
    }

    private var themeSelection: Binding<String> {
        Binding(
            get: { draft.theme },
            set: { next in
                if next == "__custom_theme__" {
                    showingThemeProposalSheet = true
                } else {
                    draft.theme = next
                }
            }
        )
    }

    private var selectedCustomThemeID: String? {
        guard draft.theme.hasPrefix("custom:") else { return nil }
        let id = String(draft.theme.dropFirst("custom:".count))
        return draft.customThemes.contains { $0.id == id } ? id : nil
    }

    private var effectiveColorScheme: ColorScheme {
        draft.colorScheme ?? preferredSettingsColorScheme ?? systemAppearance.colorScheme
    }

    private var preferredSettingsColorScheme: ColorScheme? {
        if let theme = draft.selectedCustomTheme {
            return backgroundIsLight(hex: theme.lightBackground) ? .light : .dark
        }
        return draft.colorScheme
    }

    private var settingsThemeColors: PanelThemeColors {
        if let theme = draft.selectedCustomTheme {
            let neutralPalette = neutralPalette(for: theme, colorScheme: effectiveColorScheme)
            return PanelThemeColors(
                primary: Color(hex: theme.primary),
                secondary: Color(hex: theme.secondary),
                textPrimary: neutralPalette.title,
                textSecondary: neutralPalette.secondary,
                itemTitle: neutralPalette.title,
                itemSecondary: neutralPalette.secondary,
                tertiaryFill: neutralPalette.tertiaryFill,
                fill: Color(hex: theme.subtleFill)
            )
        }
        let isDark = effectiveColorScheme == .dark
        return PanelThemeColors(
            primary: Color.accentColor,
            textPrimary: isDark ? Color.white : Color(hex: "#333333"),
            textSecondary: isDark ? Color.white.opacity(0.78) : Color(hex: "#666666"),
            itemTitle: isDark ? Color.white : Color(hex: "#333333"),
            itemSecondary: isDark ? Color.white.opacity(0.78) : Color(hex: "#666666"),
            tertiaryFill: isDark ? Color.white.opacity(0.055) : Color.black.opacity(0.035)
        )
    }

    private var settingsBackground: Color {
        if let theme = draft.selectedCustomTheme {
            return Color(hex: effectiveColorScheme == .dark ? theme.darkBackground : theme.lightBackground)
        }
        return effectiveColorScheme == .dark ? Color(red: 0.09, green: 0.10, blue: 0.12) : Color(red: 0.98, green: 0.98, blue: 0.97)
    }

    private var sectionBackground: Color {
        if let tertiaryFill = settingsThemeColors.tertiaryFill {
            return tertiaryFill
        }
        return effectiveColorScheme == .dark ? Color.white.opacity(0.055) : Color.black.opacity(0.035)
    }

    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(settingsThemeColors.itemSecondary ?? Color.secondary)
            settingsSection(content: content)
        }
    }

    private func settingsSection<Title: View, Content: View>(
        @ViewBuilder title: () -> Title,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            title()
            settingsSection(content: content)
        }
    }

    private func settingsSection<Content: View>(@ViewBuilder content: () -> Content) -> some View {
            VStack(alignment: .leading, spacing: 10) {
                content()
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(sectionBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func settingsValueRow<Content: View>(
        _ title: String,
        width: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(settingsThemeColors.itemTitle ?? Color.primary)
                .frame(width: settingsLabelWidth, alignment: .leading)
            Spacer(minLength: 12)
            content()
                .multilineTextAlignment(.trailing)
                .frame(width: width ?? settingsControlWidth, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, minHeight: settingsRowMinHeight, alignment: .center)
    }

    private func deleteSelectedCustomTheme() {
        guard let selectedCustomThemeID else { return }
        model.deleteCustomTheme(id: selectedCustomThemeID)
        draft = model.settings
    }

    private func toggleLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            launchAtLogin = SMAppService.mainApp.status == .enabled
        } catch {
            launchAtLogin = SMAppService.mainApp.status == .enabled
            model.toast(error.localizedDescription)
        }
    }
}

struct DeleteCustomThemeButton: View {
    let themeID: String?
    let action: () -> Void

    var body: some View {
        Button(role: .destructive, action: action) {
            Image(systemName: "trash")
        }
        .buttonStyle(.borderless)
        .help(L10n.deleteTheme)
        .disabled(themeID == nil)
        .opacity(themeID == nil ? 0 : 1)
        .accessibilityLabel(L10n.deleteTheme)
        .cursor(themeID == nil ? .arrow : .pointingHand)
    }
}

struct SmallSwitchToggle: View {
    @Binding var isOn: Bool
    @Environment(\.panelThemeColors) private var theme

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            Capsule()
                .fill(trackColor)
                .frame(width: 30, height: 18)
                .overlay(alignment: isOn ? .trailing : .leading) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 14, height: 14)
                        .shadow(color: .black.opacity(0.16), radius: 2, y: 1)
                        .padding(2)
                }
        }
        .buttonStyle(.plain)
        .contentShape(Capsule())
        .animation(.easeInOut(duration: 0.14), value: isOn)
        .accessibilityLabel(L10n.launchAtLogin)
        .accessibilityValue(isOn ? L10n.text("开启", "On") : L10n.text("关闭", "Off"))
        .cursor(.pointingHand)
    }

    private var trackColor: Color {
        if isOn {
            return theme.primary ?? Color.accentColor
        }
        return theme.tertiaryFill ?? Color.secondary.opacity(0.22)
    }
}

struct ThemeProposalSheet: View {
    @ObservedObject var model: AppModel
    let onCancel: () -> Void
    let onApply: (CustomThemeSettings) -> Void
    let onSave: (CustomThemeSettings) -> Void
    @State private var prompt = ""
    @State private var selectedOptionID: String?
    @FocusState private var promptFocused: Bool

    private var selectedTheme: CustomThemeSettings? {
        guard let selectedOptionID else { return model.themeOptions.first?.theme }
        return model.themeOptions.first { $0.id == selectedOptionID }?.theme
    }

    private var canGenerateTheme: Bool {
        !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !model.themeGenerationLoading
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L10n.customTheme)
                .font(.headline)

            ThemePromptEditor(
                text: $prompt,
                focused: $promptFocused,
                onSubmit: generateTheme
            )
                .frame(height: 86)
                .background(Color.primary.opacity(0.045))
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                )

            Button {
                generateTheme()
            } label: {
                if model.themeGenerationLoading {
                    ProgressView()
                        .controlSize(.small)
                    Text(model.themeGenerationStatus)
                } else {
                    Label(L10n.generateTheme, systemImage: "sparkles")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canGenerateTheme)

            if model.themeGenerationLoading || !model.themeGenerationStatus.isEmpty {
                Text(model.themeGenerationStatus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let error = model.themeGenerationError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            if !model.themeOptions.isEmpty {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(model.themeOptions) { option in
                            ThemeOptionRow(option: option, selected: option.id == (selectedOptionID ?? model.themeOptions.first?.id)) {
                                selectedOptionID = option.id
                            }
                        }
                    }
                }
                .frame(maxHeight: 220)
            }

            Spacer(minLength: 0)

            HStack {
                Button(L10n.cancel, action: onCancel)
                Spacer()
                Button(L10n.apply) {
                    if let selectedTheme {
                        onApply(selectedTheme)
                    }
                }
                .disabled(selectedTheme == nil)
                Button(L10n.save) {
                    if let selectedTheme {
                        onSave(selectedTheme)
                    }
                }
                .disabled(selectedTheme == nil)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(18)
        .frame(width: 460, height: 430)
        .onAppear {
            model.themeOptions = []
            model.themeGenerationError = nil
            model.themeGenerationStatus = ""
            DispatchQueue.main.async {
                promptFocused = true
            }
        }
    }

    private func generateTheme() {
        guard canGenerateTheme else { return }
        Task {
            await model.generateThemeOptions(prompt: prompt)
            selectedOptionID = model.themeOptions.first?.id
        }
    }
}

struct ThemePromptEditor: View {
    @Binding var text: String
    var focused: FocusState<Bool>.Binding
    let onSubmit: () -> Void
    @State private var monitor: Any?

    var body: some View {
        TextEditor(text: $text)
            .font(.system(size: 13))
            .scrollContentBackground(.hidden)
            .padding(6)
            .focused(focused)
            .cursor(.iBeam)
            .onAppear(perform: installMonitor)
            .onDisappear(perform: removeMonitor)
    }

    private func installMonitor() {
        removeMonitor()
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            guard focused.wrappedValue else { return event }
            if event.keyCode == 36, !event.modifierFlags.contains(.shift) {
                onSubmit()
                return nil
            }
            return event
        }
    }

    private func removeMonitor() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}

struct ThemeOptionRow: View {
    let option: AIThemeOption
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ThemeSwatches(theme: option.theme)
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.name)
                        .font(.system(size: 13, weight: .semibold))
                    Text(option.rationale)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(10)
            .background(selected ? Color.accentColor.opacity(0.13) : Color.primary.opacity(0.045))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .cursor(.pointingHand)
    }
}

struct ThemeSwatches: View {
    let theme: CustomThemeSettings

    var body: some View {
        HStack(spacing: 3) {
            swatch(theme.lightBackground)
            swatch(theme.darkBackground)
            swatch(theme.panelTint)
            swatch(theme.accent)
            swatch(theme.subtleFill)
            swatch(theme.primary)
            swatch(theme.secondary)
            swatch(theme.textPrimary)
            swatch(theme.textSecondary)
        }
        .frame(width: 118, alignment: .leading)
    }

    private func swatch(_ hex: String) -> some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(Color(hex: hex))
            .frame(width: 10, height: 28)
            .overlay(
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .stroke(Color.primary.opacity(0.12), lineWidth: 0.5)
            )
    }
}

struct SettingsInitialFocusGuard: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async {
            if let window = view.window {
                window.makeFirstResponder(nil)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

struct QuestionMarkHelpButton: View {
    let help: String
    @State private var hovering = false

    var body: some View {
        Image(systemName: "questionmark.circle")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
            .overlay(alignment: .trailing) {
                if hovering {
                    TooltipBubble(text: help)
                        .offset(x: 18)
                }
            }
            .onHover { hovering = $0 }
    }
}

struct InlineHelpText: View {
    let help: String

    var body: some View {
        SettingsInlineHelpText(help: help)
    }
}

struct SettingsInlineHelpText: View {
    let help: String
    @Environment(\.panelThemeColors) private var theme

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 12, weight: .semibold))
            Text(help)
                .font(.caption)
                .lineLimit(1)
        }
        .foregroundStyle(theme.itemSecondary ?? Color.secondary)
    }
}

struct HotkeyRecorderView: View {
    @Binding var hotkey: HotkeySettings
    @State private var recording = false
    @State private var monitor: Any?
    @State private var timeoutTask: Task<Void, Never>?
    @State private var previousHotkey = HotkeySettings()
    @State private var recordedHotkey = false
    @State private var pendingDoubleTapKeyCode: UInt16?
    @FocusState private var focused: Bool

    var body: some View {
        Button {
            startRecording()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: recording ? "record.circle" : "keyboard")
                    .font(.system(size: 12, weight: .semibold))
                Text(recording ? L10n.recordingHotkey : hotkey.displayText)
                    .font(.system(size: 13, weight: .medium))
                    .monospaced()
            }
            .frame(minWidth: 118, alignment: .center)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
        .focused($focused)
        .cursor(.pointingHand)
        .onChange(of: focused) { _, isFocused in
            if !isFocused {
                stopRecording(restoreIfEmpty: true)
            }
        }
        .onDisappear { stopRecording() }
    }

    private func startRecording() {
        stopRecording()
        previousHotkey = hotkey
        recordedHotkey = false
        pendingDoubleTapKeyCode = nil
        recording = true
        focused = true
        timeoutTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(5))
            } catch {
                return
            }
            stopRecording(restoreIfEmpty: true)
        }
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { event in
            if event.keyCode == 0x35 {
                stopRecording(restoreIfEmpty: true)
                return nil
            }
            if event.type == .keyDown, let next = HotkeySettings.from(event: event) {
                hotkey = next
                recordedHotkey = true
                stopRecording()
                return nil
            }
            guard isDoubleTapCandidate(event) else { return nil }
            if pendingDoubleTapKeyCode == event.keyCode {
                hotkey = HotkeySettings(
                    keyCode: Int64(event.keyCode),
                    command: false,
                    option: false,
                    control: false,
                    shift: false,
                    doubleTap: true
                )
                recordedHotkey = true
                stopRecording()
            } else {
                pendingDoubleTapKeyCode = event.keyCode
            }
            return nil
        }
    }

    private func stopRecording(restoreIfEmpty: Bool = false) {
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
        timeoutTask?.cancel()
        timeoutTask = nil
        if recording, restoreIfEmpty, !recordedHotkey {
            hotkey = previousHotkey
        }
        pendingDoubleTapKeyCode = nil
        recording = false
    }

    private func isDoubleTapCandidate(_ event: NSEvent) -> Bool {
        if event.type == .keyDown {
            return HotkeySettings.from(event: event) == nil
        }
        guard event.type == .flagsChanged,
              let modifier = modifierFlag(for: event.keyCode) else { return false }
        return event.modifierFlags.contains(modifier)
    }

    private func modifierFlag(for keyCode: UInt16) -> NSEvent.ModifierFlags? {
        switch keyCode {
        case 0x36, 0x37: return .command
        case 0x38, 0x3C: return .shift
        case 0x3A, 0x3D: return .option
        case 0x3B, 0x3E: return .control
        default: return nil
        }
    }
}

@main
struct StowPasteApp {
    static func main() {
        if ProcessInfo.processInfo.environment["STOWPASTE_CHECK_ACCESSIBILITY_ONLY"] == "1" {
            exit(AXIsProcessTrusted() ? 0 : 1)
        }
        if let statePath = ProcessInfo.processInfo.environment["STOWPASTE_STATE_MIGRATION_CHECK"] {
            _ = AppModel(storeURL: URL(fileURLWithPath: statePath), startPolling: false)
            exit(0)
        }
        let app = NSApplication.shared
        let delegate = AppController()
        app.delegate = delegate
        app.run()
    }
}
