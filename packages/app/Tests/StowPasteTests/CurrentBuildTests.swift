import AppKit
import Foundation
import Testing
@testable import StowPaste

struct CurrentBuildTests {
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
