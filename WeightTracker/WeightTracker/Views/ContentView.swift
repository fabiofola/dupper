import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: WeightStore
    @State private var showingAddEntry = false
    @State private var editingEntry: WeightEntry?
    @State private var displayMode: DisplayMode = .list

    var body: some View {
        NavigationStack {
            Group {
                if store.allEntries().isEmpty {
                    emptyState
                } else {
                    content
                }
            }
            .navigationTitle("Weight Tracker")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Picker("Display Mode", selection: $displayMode) {
                        Label("List", systemImage: "list.bullet")
                            .tag(DisplayMode.list)
                        Label("Chart", systemImage: "chart.line.uptrend.xyaxis")
                            .tag(DisplayMode.chart)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 160)
                    Button {
                        showingAddEntry = true
                    } label: {
                        Label("Add entry", systemImage: "plus")
                    }
                    .accessibilityIdentifier("addEntry")
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddEntryView()
            }
            .sheet(item: $editingEntry) { entry in
                AddEntryView(entry: entry)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "scalemass")
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text("Log your first weight entry")
                .font(.headline)
            Text("Keep track of trends, stay accountable, and reach your goals by recording your weight daily.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button {
                showingAddEntry = true
            } label: {
                Text("Add Entry")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                summarySection
                switch displayMode {
                case .list:
                    entryList
                case .chart:
                    TrendChartView(entries: store.allEntries())
                        .padding(.horizontal)
                        .transition(.opacity)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.title3)
                .bold()
                .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    StatisticsCard(title: "Latest", value: formattedWeight(store.latestEntry?.weight), trend: store.weeklyChange.map(formatTrend(_:)))
                    StatisticsCard(title: "7-day Change", value: store.weeklyChange.map(formatChange), trend: store.totalChange.map(formatTrend(_:)))
                    StatisticsCard(title: "30-day Avg", value: store.monthlyAverage.map(formatWeight), trend: nil)
                    StatisticsCard(title: "Consistency", value: store.completionRate.formatted(.percent.precision(.fractionLength(0))), trend: "Longest streak: \(store.longestStreak) days")
                }
                .padding(.horizontal)
            }
        }
    }

    private var entryList: some View {
        let entries = store.allEntries()
        return LazyVStack(spacing: 12) {
            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                let previous = index + 1 < entries.count ? entries[index + 1] : nil
                Button {
                    editingEntry = entry
                } label: {
                    EntryRow(entry: entry, previous: previous)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button(role: .destructive) {
                        store.remove(entry)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                Divider()
            }
        }
        .padding(.horizontal)
    }

    private func formattedWeight(_ weight: Double?) -> String {
        guard let weight else { return "--" }
        return formatWeight(weight)
    }

    private func formatWeight(_ weight: Double) -> String {
        weight.formatted(.number.precision(.fractionLength(1))) + " lb"
    }

    private func formatChange(_ change: Double) -> String {
        let formatted = formatWeight(abs(change))
        return change >= 0 ? "+\(formatted)" : "-\(formatted)"
    }

    private func formatTrend(_ change: Double) -> String {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 1
        let measurement = Measurement(value: change, unit: UnitMass.pounds)
        let string = formatter.string(from: measurement)
        return change >= 0 ? "+\(string)" : string
    }

    enum DisplayMode: Hashable {
        case list
        case chart
    }
}

private struct EntryRow: View {
    let entry: WeightEntry
    let previous: WeightEntry?

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.date, format: .dateTime.weekday(.wide).day().month())
                    .font(.headline)
                if let note = entry.note {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(entry.weight, format: .number.precision(.fractionLength(1)))
                    .font(.title3)
                    .bold()
                if let change = change(from: previous) {
                    Text(change)
                        .font(.caption)
                        .foregroundStyle(change.hasPrefix("+") ? Color.red : Color.green)
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func change(from previous: WeightEntry?) -> String? {
        guard let previous else { return nil }
        let difference = entry.weight - previous.weight
        guard difference != 0 else { return nil }
        let formatted = difference.magnitude.formatted(.number.precision(.fractionLength(1)))
        return (difference > 0 ? "+" : "-") + formatted + " lb"
    }
}

#Preview {
    ContentView()
        .environmentObject(WeightStore(preview: true))
}
