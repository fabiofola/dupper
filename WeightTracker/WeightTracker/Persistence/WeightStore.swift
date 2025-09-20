import Combine
import Foundation

@MainActor
final class WeightStore: ObservableObject {
    @Published private(set) var entries: [WeightEntry] = []

    private let saveURL: URL
    private var cancellables: Set<AnyCancellable> = []

    init(preview: Bool = false) {
        let fileName = preview ? "weights-preview.json" : "weights.json"
        saveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)

        if preview {
            entries = WeightStore.previewEntries
        } else {
            loadEntries()
        }

        $entries
            .dropFirst()
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { await self?.persistEntries() }
            }
            .store(in: &cancellables)
    }

    func allEntries() -> [WeightEntry] {
        entries.sortedByDateDescending()
    }

    func addEntry(weight: Double, date: Date, note: String?) {
        var newEntry = WeightEntry(date: date, weight: weight, note: note?.nilIfEmpty())
        if let existing = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            newEntry.id = existing.id
            updateEntry(newEntry)
        } else {
            entries.append(newEntry)
            entries.sort { $0.date > $1.date }
        }
    }

    func updateEntry(_ entry: WeightEntry) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else {
            entries.append(entry)
            entries.sort { $0.date > $1.date }
            return
        }

        entries[index] = entry
        entries.sort { $0.date > $1.date }
    }

    func removeEntries(at offsets: IndexSet) {
        let sorted = allEntries()
        let idsToRemove = offsets.map { sorted[$0].id }
        entries.removeAll { idsToRemove.contains($0.id) }
    }

    func remove(_ entry: WeightEntry) {
        entries.removeAll { $0.id == entry.id }
    }

    // MARK: - Statistics

    var latestEntry: WeightEntry? {
        entries.sortedByDateDescending().first
    }

    var weeklyChange: Double? {
        guard let latest = latestEntry else { return nil }
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: latest.date) ?? latest.date
        guard let reference = entries.mostRecent(before: weekAgo) else { return nil }
        return latest.weight - reference.weight
    }

    var monthlyAverage: Double? {
        guard let latest = latestEntry else { return nil }
        guard let monthAgo = Calendar.current.date(byAdding: .day, value: -30, to: latest.date) else { return nil }
        let range = entries.filter { $0.date >= monthAgo && $0.date <= latest.date }
        guard !range.isEmpty else { return nil }
        let total = range.reduce(0) { $0 + $1.weight }
        return total / Double(range.count)
    }

    var completionRate: Double {
        guard let first = entries.sortedByDateDescending().last else { return 0 }
        guard let last = latestEntry else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: first.date, to: last.date).day ?? 0
        if days == 0 { return 1 }
        let expectedCount = days + 1
        let ratio = Double(entries.count) / Double(expectedCount)
        return min(1, max(0, ratio))
    }

    var longestStreak: Int {
        let sorted = entries.sorted { $0.date < $1.date }
        var currentStreak = 0
        var longest = 0
        var previousDate: Date?

        for entry in sorted {
            if let previous = previousDate {
                if Calendar.current.isDate(entry.date, inSameDayAs: previous) {
                    continue
                }

                let difference = Calendar.current.dateComponents([.day], from: previous, to: entry.date).day ?? 0
                if difference == 1 {
                    currentStreak += 1
                } else {
                    longest = max(longest, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }

            previousDate = entry.date
        }

        return max(longest, currentStreak)
    }

    var totalChange: Double? {
        guard let first = entries.sortedByDateDescending().last, let last = latestEntry else { return nil }
        return last.weight - first.weight
    }

    // MARK: - Persistence

    private func loadEntries() {
        do {
            let data = try Data(contentsOf: saveURL)
            let decoded = try JSONDecoder().decode([WeightEntry].self, from: data)
            entries = decoded.sorted { $0.date > $1.date }
        } catch {
            entries = []
        }
    }

    private func persistEntries() async {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(entries)
            try data.write(to: saveURL, options: [.atomic])
        } catch {
            #if DEBUG
            print("Failed to persist entries: \(error.localizedDescription)")
            #endif
        }
    }

    func replaceAll(with entries: [WeightEntry]) {
        self.entries = entries.sorted { $0.date > $1.date }
    }
}

private extension WeightStore {
    static let previewEntries: [WeightEntry] = {
        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: Date())
        return stride(from: 0, to: 14, by: 1).map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: baseDate) ?? baseDate
            let weight = 180 - Double(offset) * 0.5 + Double.random(in: -0.2...0.2)
            return WeightEntry(date: date, weight: weight, note: offset % 3 == 0 ? "Fasted" : nil)
        }
    }()
}

