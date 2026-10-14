import AppKit
import Combine
import Darwin
import Foundation
import SwiftUI
import Testing
@testable import StowPaste

struct CurrentBuildTests {
    @Test
    func testInjectedPasteEventsRemainRecognizableAfterDelayedDelivery() throws {
        let events = PasteShortcutEvents.make()
        #expect(events.count == 4)
        #expect(events.map { $0.getIntegerValueField(.keyboardEventKeycode) } == [0x37, 0x09, 0x09, 0x37])
        #expect(events.map(\.type) == [.flagsChanged, .keyDown, .keyUp, .flagsChanged])
        for event in events {
            let delivered = try #require(event.copy())
            delivered.timestamp += 5_000_000_000
            #expect(PasteShortcutEvents.isOwnEvent(delivered))
        }
        let physical = try #require(CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: true))
        physical.flags = .maskCommand
        #expect(!PasteShortcutEvents.isOwnEvent(physical))
        #expect(events[1].flags == .maskCommand)
        #expect(events[2].flags == .maskCommand)
    }

    @MainActor
    @Test
    func testLargeTextHistorySelectionAndPastePublishOnlyChangedRecords() throws {
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let pasteboard = NSPasteboard.withUniqueName()
        defer { pasteboard.releaseGlobally() }
        let stateURL = directory.appendingPathComponent("state.json")
        let model = AppModel(storeURL: stateURL, startPolling: false, pasteboard: pasteboard)
        model.history = (0..<2_000).map { entry(index: $0) }
        model.favoriteOrder = [model.history[1].id]
        let selected = model.history[1_000]
        var historyUpdates = 0
        var favoriteUpdates = 0
        let historyObserver = model.$history.dropFirst().sink { _ in historyUpdates += 1 }
        let favoriteObserver = model.$favoriteOrder.dropFirst().sink { _ in favoriteUpdates += 1 }
        defer {
            historyObserver.cancel()
            favoriteObserver.cancel()
        }

        model.select(selected)
        #expect(historyUpdates == 1)
        #expect(favoriteUpdates == 0)
        historyUpdates = 0
        model.paste(selected, using: nil)
        #expect(historyUpdates == 1)
        #expect(favoriteUpdates == 0)
        #expect(pasteboard.string(forType: .string) == selected.text)
        model.refreshClipboard()
        #expect(model.history.count == 2_000)
        #expect(historyUpdates == 1)
        let restored = AppModel(storeURL: stateURL, startPolling: false, pasteboard: pasteboard)
        #expect(restored.history.count == 2_000)
        #expect(restored.selectedID == selected.id)
        #expect(restored.favoriteOrder == [model.history[1].id])
    }

    @MainActor
    @Test
    func testLegacyFavoriteMigrationIsPersistedAndIdempotent() throws {
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let stateURL = directory.appendingPathComponent("state.json")
        var entries = (0..<400).map { entry(index: $0) }
        for index in entries.indices where index.isMultiple(of: 2) {
            entries[index].pinnedTabs = [.favorites, .all]
        }
        let state = PersistedState(settings: AppSettings(), history: entries, activeTab: .all, selectedID: entries[0].id, lastSignature: "", favoriteOrder: [FavoriteOrderItem(id: entries[2].id, rank: 0), FavoriteOrderItem(id: UUID(), rank: 1)], customGroups: [])
        try JSONEncoder().encode(state).write(to: stateURL)
        let model = AppModel(storeURL: stateURL, startPolling: false)
        let expectedOrder = [entries[2].id] + entries.enumerated().filter { $0.offset.isMultiple(of: 2) && $0.offset != 2 }.map { $0.element.id }
        #expect(model.favoriteOrder == expectedOrder)
        #expect(model.history.allSatisfy { !$0.pinnedTabs.contains(.favorites) })
        #expect(model.history[0].pinnedTabs == [.all])
        let restored = AppModel(storeURL: stateURL, startPolling: false)
        #expect(restored.history == model.history)
        #expect(restored.favoriteOrder == expectedOrder)
        let savedData = try Data(contentsOf: stateURL)
        _ = AppModel(storeURL: stateURL, startPolling: false)
        #expect(try Data(contentsOf: stateURL) == savedData)
    }

    @MainActor
    @Test(.enabled(if: ProcessInfo.processInfo.environment["STOWPASTE_PASTE_MEMORY_CHECK"] == "1"))
    func testMountedPanelRemainsBoundedAcrossRepeatedTextPastes() async throws {
        _ = NSApplication.shared
        let directory: URL
        if let workspace = ProcessInfo.processInfo.environment["STOWPASTE_PASTE_MEMORY_WORK_DIR"] {
            directory = URL(fileURLWithPath: workspace)
        } else {
            directory = try temporaryDirectory()
        }
        defer { try? FileManager.default.removeItem(at: directory) }
        let pasteboard = NSPasteboard.withUniqueName()
        defer { pasteboard.releaseGlobally() }
        let stateURL = directory.appendingPathComponent("state.json")
        let fixture = ProcessInfo.processInfo.environment["STOWPASTE_PASTE_MEMORY_FIXTURE"]
        if let fixture {
            let source = URL(fileURLWithPath: fixture)
            try FileManager.default.copyItem(at: source, to: stateURL)
            let images = source.deletingLastPathComponent().appendingPathComponent("Images")
            if FileManager.default.fileExists(atPath: images.path) {
                try FileManager.default.copyItem(at: images, to: directory.appendingPathComponent("Images"))
            }
        }
        let model = AppModel(storeURL: stateURL, startPolling: false, pasteboard: pasteboard)
        if fixture == nil {
            model.history = (0..<2_000).map { index in
                var item = entry(index: index)
                item.text = "Text \(index) " + String(repeating: "sample ", count: 100)
                item.signature = "text:\(item.text!)"
                return item
            }
        }
        let initialCount = model.history.count
        let textEntries = model.history.filter(\.isText)
        #expect(!textEntries.isEmpty)
        guard let first = textEntries.first else { return }
        model.activeTab = .all
        model.activeGroupID = nil
        model.selectedID = first.id
        let controller = AppController(model: model)
        let hostingView = NSHostingView(rootView: ClipboardOverlayView(model: model, controller: controller).environmentObject(model.systemAppearance))
        let window = NSWindow(contentRect: NSRect(x: -10_000, y: -10_000, width: 420, height: 580), styleMask: [.borderless], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = hostingView
        window.orderFrontRegardless()
        defer {
            window.contentView = nil
            window.close()
        }
        hostingView.layoutSubtreeIfNeeded()
        try await Task.sleep(for: .milliseconds(50))
        var historyUpdates = 0
        let observer = model.$history.dropFirst().sink { _ in historyUpdates += 1 }
        defer { observer.cancel() }
        for index in 0..<30 {
            let selected = textEntries[(index * 61) % textEntries.count]
            model.select(selected)
            model.paste(selected, using: nil)
            model.refreshClipboard()
            hostingView.layoutSubtreeIfNeeded()
            try await Task.sleep(for: .milliseconds(20))
            #expect(pasteboard.string(forType: .string) == selected.text)
        }
        #expect(historyUpdates == 60)
        #expect(model.history.count == initialCount)
        var usage = rusage()
        #expect(getrusage(RUSAGE_SELF, &usage) == 0)
        print("mounted panel: \(initialCount) records, 30 text pastes, peak RSS \(usage.ru_maxrss / 1_048_576) MiB")
        #expect(usage.ru_maxrss < 512 * 1_048_576)
    }

    @Test
    func testDefaultHotkeyIsDoubleCommand() {
        let hotkey = HotkeySettings()

        #expect(hotkey.keyCode == 0x37)
        #expect(!(hotkey.command))
        #expect(hotkey.doubleTap)
        #expect(hotkey.displayText == "⌘ ⌘")
    }

    @Test
    func testCommandVRecordingProducesChord() {
        var state = HotkeyRecordingState()

        let hotkey = state.consume(
            eventType: .keyDown,
            keyCode: 0x09,
            modifierFlags: [.command],
            isRepeat: false,
            timestamp: 1
        )

        #expect(hotkey == HotkeySettings(
                keyCode: 0x09,
                command: true,
                option: false,
                control: false,
                shift: false,
                doubleTap: false
            ))
        #expect(hotkey?.displayText == "⌘V")
    }

    @Test
    func testCommandStateFromFlagsChangedIsMergedIntoNextKeyDown() {
        var state = HotkeyRecordingState()

        #expect(state.consume(
            eventType: .flagsChanged,
            keyCode: 0x37,
            modifierFlags: [.command],
            isRepeat: false,
            timestamp: 1
        ) == nil)
        let hotkey = state.consume(
            eventType: .keyDown,
            keyCode: 0x09,
            modifierFlags: [],
            isRepeat: false,
            timestamp: 1.1
        )

        #expect(hotkey?.keyCode == 0x09)
        #expect(hotkey?.command == true)
        #expect(hotkey?.doubleTap == false)
        #expect(hotkey?.displayText == "⌘V")
    }

    @Test
    func testKeyRepeatCannotBecomeDoubleTapShortcut() {
        var state = HotkeyRecordingState()

        #expect(state.consume(
            eventType: .keyDown,
            keyCode: 0x09,
            modifierFlags: [],
            isRepeat: false,
            timestamp: 1
        ) == nil)
        #expect(state.consume(
            eventType: .keyDown,
            keyCode: 0x09,
            modifierFlags: [],
            isRepeat: true,
            timestamp: 1.1
        ) == nil)
        #expect(state.consume(
            eventType: .keyDown,
            keyCode: 0x09,
            modifierFlags: [],
            isRepeat: false,
            timestamp: 1.2
        ) == nil)
    }

    @Test
    func testDoubleCommandRecordingRequiresReleaseBetweenPresses() {
        var state = HotkeyRecordingState()

        #expect(state.consume(
            eventType: .flagsChanged,
            keyCode: 0x37,
            modifierFlags: [.command],
            isRepeat: false,
            timestamp: 1
        ) == nil)
        #expect(state.consume(
            eventType: .flagsChanged,
            keyCode: 0x37,
            modifierFlags: [.command],
            isRepeat: false,
            timestamp: 1.1
        ) == nil)
        #expect(state.consume(
            eventType: .flagsChanged,
            keyCode: 0x37,
            modifierFlags: [],
            isRepeat: false,
            timestamp: 1.2
        ) == nil)
        let hotkey = state.consume(
            eventType: .flagsChanged,
            keyCode: 0x37,
            modifierFlags: [.command],
            isRepeat: false,
            timestamp: 1.3
        )

        #expect(hotkey == .doubleTap(keyCode: 0x37))
        #expect(hotkey?.displayText == "⌘ ⌘")
    }

    @Test
    func testLegacyRecommendationSettingsAreDropped() throws {
        let data = Data(#"{"smartRecommendationsEnabled":true,"keepImportantInformation":true}"#.utf8)
        let settings = try JSONDecoder().decode(AppSettings.self, from: data)
        let rewritten = try String(decoding: JSONEncoder().encode(settings), as: UTF8.self)

        #expect(!(rewritten.contains("smartRecommendationsEnabled")))
        #expect(!(rewritten.contains("keepImportantInformation")))
    }

    @Test
    func testRemovedPasteHintSettingsAreDropped() throws {
        let settings = try JSONDecoder().decode(AppSettings.self, from: Data(#"{"hideDoublePasteHint":false,"usedDoublePaste":true}"#.utf8))
        let rewritten = String(decoding: try JSONEncoder().encode(settings), as: UTF8.self)
        #expect(!(rewritten.contains("hideDoublePasteHint")))
        #expect(!(rewritten.contains("usedDoublePaste")))
        #expect(settings.pastePanelHotkey == HotkeySettings())
    }

    @Test
    func testHistoryShortcutsRespectTextEditingModifiersAndPreview() {
        func action(_ key: UInt16, flags: NSEvent.ModifierFlags = [], editing: Bool = false, enabled: Bool = true, preview: Bool = false) -> PanelKeyboardActionPolicy.HistoryAction? {
            PanelKeyboardActionPolicy.historyAction(keyCode: key, modifierFlags: flags, editingText: editing, historyActionsEnabled: enabled, previewVisible: preview)
        }

        #expect(action(0x33) == .delete)
        #expect(action(0x75) == .delete)
        #expect(action(0x31) == .toggleImagePreview)
        for key: UInt16 in [0x33, 0x75, 0x31] {
            #expect(action(key, editing: true) == nil)
            #expect(action(key, enabled: false) == nil)
            for flags: NSEvent.ModifierFlags in [.command, .option, .control, .shift] {
                #expect(action(key, flags: flags) == nil)
            }
        }
        #expect(action(0x33, preview: true) == .ignore)
        #expect(action(0x24, preview: true) == .ignore)
        #expect(action(0x31, preview: true) == .closeImagePreview)
        #expect(action(0x35, preview: true) == .closeImagePreview)
        #expect(action(0x35) == nil)
    }

    @MainActor
    @Test
    func testDeletionKeepsAdjacentSelectionAndPersistsGroupCleanup() throws {
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let stateURL = directory.appendingPathComponent("state.json")
        let model = AppModel(storeURL: stateURL, startPolling: false)
        let entries = (0..<3).map { entry(index: $0) }
        model.history = entries
        model.favoriteOrder = entries.map(\.id)
        let group = CustomGroup(id: UUID(), name: "Test", symbol: "tray", itemIDs: entries.map(\.id))
        model.customGroups = [group]
        model.activeGroupID = group.id
        model.selectedID = entries[1].id
        model.delete(entries[1])
        #expect(model.selectedID == entries[2].id)
        #expect(model.visibleHistory.map(\.id) == [entries[0].id, entries[2].id])
        #expect(!(model.favoriteOrder.contains(entries[1].id)))
        #expect(model.customGroups[0].itemIDs == [entries[0].id, entries[2].id])

        let restored = AppModel(storeURL: stateURL, startPolling: false)
        #expect(restored.selectedID == entries[2].id)
        #expect(restored.customGroups[0].itemIDs == [entries[0].id, entries[2].id])
        model.delete(entries[2])
        #expect(model.selectedID == entries[0].id)
        model.delete(entries[0])
        #expect(model.selectedID == nil)
        #expect(model.visibleHistory.isEmpty)
    }

    @MainActor
    @Test
    func testPreviewLoadsOriginalFromDiskAndClearsOnDeletion() throws {
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 640, pixelsHigh: 320, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        let png = try #require(bitmap.representation(using: .png, properties: [:]))
        var imageEntry = entry(index: 0)
        imageEntry.kind = .image
        imageEntry.imagePNG = png
        imageEntry.imageWidth = 640
        imageEntry.imageHeight = 320
        let state = PersistedState(settings: AppSettings(), history: [imageEntry], activeTab: .image, selectedID: imageEntry.id, lastSignature: "", favoriteOrder: [], customGroups: [])
        let stateURL = directory.appendingPathComponent("state.json")
        try JSONEncoder().encode(state).write(to: stateURL)
        let model = AppModel(storeURL: stateURL, startPolling: false)
        #expect(model.history[0].imagePNG == nil)
        let originalURL = directory.appendingPathComponent("Images").appendingPathComponent(try #require(model.history[0].imageFileName))
        model.toggleImagePreview()
        let preview = try #require(model.imagePreview)
        #expect(preview.entryID == imageEntry.id)
        #expect(preview.image?.representations.first?.pixelsWide == 640)
        #expect(preview.image?.representations.first?.pixelsHigh == 320)
        model.toggleImagePreview()
        #expect(model.imagePreview == nil)
        model.toggleImagePreview()
        model.delete(model.history[0])
        #expect(model.imagePreview == nil)
        #expect(!(FileManager.default.fileExists(atPath: originalURL.path)))
    }

    @MainActor
    @Test
    func testImageFilePreviewAndMissingFileStateLeaveTextUntouched() throws {
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let model = AppModel(storeURL: directory.appendingPathComponent("state.json"), startPolling: false)
        var file = entry(index: 0)
        file.kind = .file
        let imageURL = directory.appendingPathComponent("image.png")
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 32, pixelsHigh: 16, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        try #require(bitmap.representation(using: .png, properties: [:])).write(to: imageURL)
        file.fileURLs = [imageURL]
        #expect(model.canPreviewImage(file))
        model.showImagePreview(for: file)
        #expect(model.imagePreview?.image != nil)
        try FileManager.default.removeItem(at: imageURL)
        model.showImagePreview(for: file)
        #expect(model.imagePreview?.entryID == file.id)
        #expect(model.imagePreview?.image == nil)
        model.hideOverlay()
        #expect(model.imagePreview == nil)
        let text = entry(index: 1)
        model.history = [text]
        model.selectedID = text.id
        model.toggleImagePreview()
        #expect(model.imagePreview == nil)
        #expect(model.selectedID == text.id)
    }

    private func temporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("StowPasteInteractionTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private func entry(index: Int) -> ClipboardEntry {
        ClipboardEntry(id: UUID(), kind: .text, title: "Entry \(index)", preview: "Text \(index)", signature: "text:\(index)", createdAt: Date(timeIntervalSince1970: Double(index)), updatedAt: Date(), pinnedTabs: [], text: "Text \(index)", fileURLs: [], imagePNG: nil, imageWidth: nil, imageHeight: nil)
    }

    @MainActor
    @Test
    func testCurrentStateDropsRemovedFeaturePayloads() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("StowPasteCurrentBuildTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let stateURL = directory.appendingPathComponent("state.json")
        let legacyState = #"{"settings":{"smartRecommendationsEnabled":true,"keepImportantInformation":true},"history":[],"activeTab":"all","selectedID":null,"lastSignature":"","translationCache":[{"invalid":"payload"}],"smartItems":[{"invalid":"payload"}],"smartDataSchemaVersion":8}"#
        try Data(legacyState.utf8).write(to: stateURL)

        let model = AppModel(storeURL: stateURL, startPolling: false)
        #expect(model.history.isEmpty)
        #expect(model.settings.historyRetentionPeriod == .unlimited)

        let rewritten = try String(contentsOf: stateURL, encoding: .utf8)
        #expect(!(rewritten.contains("translationCache")))
        #expect(!(rewritten.contains("smartItems")))
        #expect(!(rewritten.contains("smartDataSchemaVersion")))
        #expect(!(rewritten.contains("smartRecommendationsEnabled")))
        #expect(!(rewritten.contains("keepImportantInformation")))
    }
}
