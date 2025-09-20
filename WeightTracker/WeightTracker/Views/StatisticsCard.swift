import SwiftUI

struct StatisticsCard: View {
    let title: String
    let value: String?
    let trend: String?

    init(title: String, value: String?, trend: String?) {
        self.title = title
        self.value = value
        self.trend = trend
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value ?? "--")
                .font(.title2)
                .bold()
            if let trend {
                Text(trend)
                    .font(.caption)
                    .foregroundStyle(color(for: trend))
            }
        }
        .padding()
        .frame(minWidth: 140, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func color(for trend: String) -> Color {
        if trend.hasPrefix("+") {
            return .red
        } else if trend.hasPrefix("-") {
            return .green
        } else {
            return .secondary
        }
    }
}

#Preview {
    StatisticsCard(title: "Weekly", value: "180.2 lb", trend: "-1.6 lb")
        .padding()
        .previewLayout(.sizeThatFits)
}
