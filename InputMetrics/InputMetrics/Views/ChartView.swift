import SwiftUI
import Charts

enum ChartMetric {
    case distance
    case keystrokes
}

struct ChartView: View {
    let data: [DailySummary]
    let range: TimeRange
    var metric: ChartMetric = .distance

    var body: some View {
        VStack(alignment: .leading) {
            Text(chartTitle)
                .font(.headline)
                .padding(.bottom, 4)

            if data.isEmpty {
                Text("No data available")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Chart(data, id: \.date) { item in
                    BarMark(
                        x: .value("Date", item.date),
                        y: .value("Value", metricValue(for: item))
                    )
                    .foregroundStyle(Color.blue)
                }
                .chartYAxisLabel(yAxisLabel)
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisValueLabel(format: xAxisFormat)
                    }
                }
            }
        }
    }

    private var chartTitle: String {
        switch metric {
        case .distance:
            return "Mouse Distance"
        case .keystrokes:
            return "Keystrokes"
        }
    }

    private var yAxisLabel: String {
        switch metric {
        case .distance:
            return "Distance (km)"
        case .keystrokes:
            return "Keystrokes"
        }
    }

    private var xAxisFormat: Date.FormatStyle {
        switch range {
        case .week:
            return .dateTime.weekday(.abbreviated)
        case .month:
            return .dateTime.day()
        case .year:
            return .dateTime.month().day()
        }
    }

    private func metricValue(for item: DailySummary) -> Double {
        switch metric {
        case .distance:
            return DistanceConverter.metersToKilometers(DistanceConverter.pixelsToMeters(item.mouseDistancePx))
        case .keystrokes:
            return Double(item.keystrokes)
        }
    }
}

#Preview {
    ChartView(
        data: [
            DailySummary(date: "2025-01-10", mouseDistancePx: 5000000, mouseClicksLeft: 100, mouseClicksRight: 20, mouseClicksMiddle: 5, keystrokes: 2000),
            DailySummary(date: "2025-01-11", mouseDistancePx: 7000000, mouseClicksLeft: 150, mouseClicksRight: 30, mouseClicksMiddle: 8, keystrokes: 3000),
            DailySummary(date: "2025-01-12", mouseDistancePx: 4000000, mouseClicksLeft: 80, mouseClicksRight: 15, mouseClicksMiddle: 3, keystrokes: 1500)
        ],
        range: .week
    )
    .frame(height: 250)
    .padding()
}
