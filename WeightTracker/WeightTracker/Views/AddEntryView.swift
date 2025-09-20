import SwiftUI

struct AddEntryView: View {
    @EnvironmentObject private var store: WeightStore
    @Environment(\.dismiss) private var dismiss

    var entry: WeightEntry?

    @State private var date: Date
    @State private var weight: Double
    @State private var note: String
    @State private var useCurrentTime: Bool

    init(entry: WeightEntry? = nil) {
        self.entry = entry
        if let entry {
            _date = State(initialValue: entry.date)
            _weight = State(initialValue: entry.weight)
            _note = State(initialValue: entry.note ?? "")
            _useCurrentTime = State(initialValue: false)
        } else {
            _date = State(initialValue: Date())
            _weight = State(initialValue: 180)
            _note = State(initialValue: "")
            _useCurrentTime = State(initialValue: true)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Measurement") {
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .disabled(useCurrentTime)
                    Toggle("Use current time", isOn: $useCurrentTime)
                        .onChange(of: useCurrentTime) { _, newValue in
                            if newValue {
                                date = Date()
                            }
                        }
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Slider(value: $weight, in: 60...400, step: 0.1) {
                                Text("Weight")
                            }
                            Spacer()
                            Text(weight, format: .number.precision(.fractionLength(1)))
                                .frame(width: 60, alignment: .trailing)
                            Text("lb")
                                .foregroundColor(.secondary)
                        }
                        TextField("Weight", value: $weight, format: .number.precision(.fractionLength(1)))
                            .keyboardType(.decimalPad)
                    }
                    TextField("Notes", text: $note, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle(entry == nil ? "New Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveEntry() }
                        .disabled(!isValid)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .onAppear {
            if useCurrentTime {
                date = Date()
            }
        }
    }

    private var isValid: Bool {
        weight > 0
    }

    private func saveEntry() {
        let finalDate = useCurrentTime ? Date() : date
        if let entry {
            let updated = WeightEntry(id: entry.id, date: finalDate, weight: weight, note: note.nilIfEmpty())
            store.updateEntry(updated)
        } else {
            store.addEntry(weight: weight, date: finalDate, note: note)
        }
        dismiss()
    }
}

#Preview {
    AddEntryView()
        .environmentObject(WeightStore(preview: true))
}
