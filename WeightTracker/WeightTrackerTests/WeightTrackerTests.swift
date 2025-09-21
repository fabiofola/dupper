import XCTest
@testable import WeightTracker

final class WeightTrackerTests: XCTestCase {
    @MainActor
    func testAddingEntryInsertsOrReplacesByDate() async throws {
        let store = WeightStore(preview: true)
        let date = Calendar.current.startOfDay(for: Date())
        store.replaceAll(with: [])

        store.addEntry(weight: 180, date: date, note: "Morning")
        XCTAssertEqual(store.allEntries().count, 1)
        XCTAssertEqual(store.allEntries().first?.weight, 180)

        store.addEntry(weight: 179.4, date: date, note: "Updated")
        XCTAssertEqual(store.allEntries().count, 1)
        XCTAssertEqual(store.allEntries().first?.weight, 179.4)
    }

    @MainActor
    func testStatisticsAreComputed() async throws {
        let store = WeightStore(preview: true)
        let entries = [
            WeightEntry(date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!, weight: 190),
            WeightEntry(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, weight: 187),
            WeightEntry(date: Date(), weight: 185)
        ]
        store.replaceAll(with: entries)

        XCTAssertEqual(store.allEntries().count, 3)
        XCTAssertNotNil(store.latestEntry)
        XCTAssertNotNil(store.weeklyChange)
        XCTAssertNotNil(store.monthlyAverage)
        XCTAssertGreaterThan(store.longestStreak, 0)
    }
}
