import Foundation

struct WeightEntry: Identifiable, Codable, Hashable {
    var id: UUID
    var date: Date
    var weight: Double
    var note: String?

    init(id: UUID = UUID(), date: Date = Date(), weight: Double, note: String? = nil) {
        self.id = id
        self.date = date
        self.weight = weight
        self.note = note
    }
}

extension Array where Element == WeightEntry {
    func sortedByDateDescending() -> [WeightEntry] {
        sorted { $0.date > $1.date }
    }

    func mostRecent(before date: Date) -> WeightEntry? {
        sortedByDateDescending().first { $0.date < date }
    }
}
