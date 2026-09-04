import Foundation
import XCTest
@testable import StowPaste

final class CurrentBuildTests: XCTestCase {
    func testDefaultHotkeyIsDoubleCommand() {
        let hotkey = HotkeySettings()

        XCTAssertEqual(hotkey.keyCode, 0x37)
        XCTAssertFalse(hotkey.command)
        XCTAssertTrue(hotkey.doubleTap)
        XCTAssertEqual(hotkey.displayText, "⌘ ⌘")
    }

    func testCommandVRecordingProducesChord() {
        var state = HotkeyRecordingState()

        let hotkey = state.consume(
            eventType: .keyDown,
            keyCode: 0x09,
            modifierFlags: [.command],
            isRepeat: false,
            timestamp: 1
        )

        XCTAssertEqual(
            hotkey,
            HotkeySettings(
                keyCode: 0x09,
                command: true,
                option: false,
                control: false,
                shift: false,
                doubleTap: false
            )
        )
        XCTAssertEqual(hotkey?.displayText, "⌘V")
    }

    func testCommandStateFromFlagsChangedIsMergedIntoNextKeyDown() {
        var state = HotkeyRecordingState()

        XCTAssertNil(state.consume(
            eventType: .flagsChanged,
            keyCode: 0x37,
            modifierFlags: [.command],
            isRepeat: false,
            timestamp: 1
        ))
        let hotkey = state.consume(
            eventType: .keyDown,
            keyCode: 0x09,
            modifierFlags: [],
            isRepeat: false,
            timestamp: 1.1
        )

        XCTAssertEqual(hotkey?.keyCode, 0x09)
        XCTAssertEqual(hotkey?.command, true)
        XCTAssertEqual(hotkey?.doubleTap, false)
        XCTAssertEqual(hotkey?.displayText, "⌘V")
    }

    func testKeyRepeatCannotBecomeDoubleTapShortcut() {
        var state = HotkeyRecordingState()

        XCTAssertNil(state.consume(
            eventType: .keyDown,
            keyCode: 0x09,
            modifierFlags: [],
            isRepeat: false,
            timestamp: 1
        ))
        XCTAssertNil(state.consume(
            eventType: .keyDown,
            keyCode: 0x09,
            modifierFlags: [],
            isRepeat: true,
            timestamp: 1.1
        ))
        XCTAssertNil(state.consume(
            eventType: .keyDown,
            keyCode: 0x09,
            modifierFlags: [],
            isRepeat: false,
            timestamp: 1.2
        ))
    }

    func testDoubleCommandRecordingRequiresReleaseBetweenPresses() {
        var state = HotkeyRecordingState()

        XCTAssertNil(state.consume(
            eventType: .flagsChanged,
            keyCode: 0x37,
            modifierFlags: [.command],
            isRepeat: false,
            timestamp: 1
        ))
        XCTAssertNil(state.consume(
            eventType: .flagsChanged,
            keyCode: 0x37,
            modifierFlags: [.command],
            isRepeat: false,
            timestamp: 1.1
        ))
        XCTAssertNil(state.consume(
            eventType: .flagsChanged,
            keyCode: 0x37,
            modifierFlags: [],
            isRepeat: false,
            timestamp: 1.2
        ))
        let hotkey = state.consume(
            eventType: .flagsChanged,
            keyCode: 0x37,
            modifierFlags: [.command],
            isRepeat: false,
            timestamp: 1.3
        )

        XCTAssertEqual(hotkey, .doubleTap(keyCode: 0x37))
        XCTAssertEqual(hotkey?.displayText, "⌘ ⌘")
    }

    func testLegacyRecommendationSettingsAreDropped() throws {
        let data = Data(#"{"smartRecommendationsEnabled":true,"keepImportantInformation":true}"#.utf8)
        let settings = try JSONDecoder().decode(AppSettings.self, from: data)
        let rewritten = try String(decoding: JSONEncoder().encode(settings), as: UTF8.self)

        XCTAssertFalse(rewritten.contains("smartRecommendationsEnabled"))
        XCTAssertFalse(rewritten.contains("keepImportantInformation"))
    }

    @MainActor
    func testCurrentStateDropsRemovedFeaturePayloads() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("StowPasteCurrentBuildTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let stateURL = directory.appendingPathComponent("state.json")
        let legacyState = #"{"settings":{"smartRecommendationsEnabled":true,"keepImportantInformation":true},"history":[],"activeTab":"all","selectedID":null,"lastSignature":"","translationCache":[{"invalid":"payload"}],"smartItems":[{"invalid":"payload"}],"smartDataSchemaVersion":8}"#
        try Data(legacyState.utf8).write(to: stateURL)

        let model = AppModel(storeURL: stateURL, startPolling: false)
        XCTAssertTrue(model.history.isEmpty)
        XCTAssertEqual(model.settings.historyRetentionPeriod, .unlimited)

        let rewritten = try String(contentsOf: stateURL, encoding: .utf8)
        XCTAssertFalse(rewritten.contains("translationCache"))
        XCTAssertFalse(rewritten.contains("smartItems"))
        XCTAssertFalse(rewritten.contains("smartDataSchemaVersion"))
        XCTAssertFalse(rewritten.contains("smartRecommendationsEnabled"))
        XCTAssertFalse(rewritten.contains("keepImportantInformation"))
    }
}
