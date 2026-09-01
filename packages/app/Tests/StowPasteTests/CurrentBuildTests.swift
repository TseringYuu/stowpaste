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
