import Charts
import SwiftUI

struct TrendChartView: View {
    let entries: [WeightEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weight Trend")
                .font(.title3)
                .bold()
            if entries.count < 2 {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text("Not enough data")
                        .font(.headline)
                    Text("Log a few entries to see your weight trend.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 200)
            } else {
                Chart(entries.sortedByDateDescending().reversed()) { entry in
                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight", entry.weight)
                    )
                    PointMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight", entry.weight)
                    )
                }
                .chartYAxisLabel("Weight (lb)")
                .frame(minHeight: 240)
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    TrendChartView(entries: WeightStore(preview: true).allEntries())
        .padding()
        .previewLayout(.sizeThatFits)
}
