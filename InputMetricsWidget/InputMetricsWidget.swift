import WidgetKit
import SwiftUI

struct InputMetricsEntry: TimelineEntry {
    let date: Date
    let keystrokes: Int
    let mouseDistance: String
    let totalClicks: Int
    let activeMinutes: Int
    let hasData: Bool

    static let placeholder = InputMetricsEntry(
        date: Date(),
        keystrokes: 1234,
        mouseDistance: "2.5 km",
        totalClicks: 567,
        activeMinutes: 42,
        hasData: true
    )

    static let empty = InputMetricsEntry(
        date: Date(),
        keystrokes: 0,
        mouseDistance: "0 m",
        totalClicks: 0,
        activeMinutes: 0,
        hasData: false
    )
}

struct InputMetricsProvider: TimelineProvider {
    func placeholder(in context: Context) -> InputMetricsEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (InputMetricsEntry) -> Void) {
        completion(context.isPreview ? .placeholder : makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<InputMetricsEntry>) -> Void) {
        let entry = makeEntry()
        let nextUpdate = Date().addingTimeInterval(300)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func makeEntry() -> InputMetricsEntry {
        guard let summary = WidgetDataProvider.fetchTodaySummary() else {
            return .empty
        }
        return InputMetricsEntry(
            date: Date(),
            keystrokes: summary.keystrokes,
            mouseDistance: WidgetDataProvider.formatDistance(summary.mouseDistancePx),
            totalClicks: summary.totalClicks,
            activeMinutes: summary.activeMinutes,
            hasData: true
        )
    }
}

// MARK: - Widget Views

struct InputMetricsWidgetEntryView: View {
    var entry: InputMetricsEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        default:
            mediumWidget
        }
    }

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: "keyboard")
                .font(.title2)
                .foregroundStyle(.purple)

            Spacer()

            if entry.hasData {
                Text(WidgetDataProvider.formatCount(entry.keystrokes))
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .monospacedDigit()

                Text("Keystrokes Today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("No data yet")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Text("Open InputMetrics to start tracking")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .widgetURL(URL(string: "inputmetrics://open"))
    }

    private var mediumWidget: some View {
        HStack(spacing: 0) {
            metricCard(
                icon: "keyboard",
                color: .purple,
                value: WidgetDataProvider.formatCount(entry.keystrokes),
                label: "Keystrokes"
            )

            metricCard(
                icon: "arrow.up.right",
                color: .blue,
                value: entry.mouseDistance,
                label: "Distance"
            )

            metricCard(
                icon: "cursorarrow.click",
                color: .green,
                value: WidgetDataProvider.formatCount(entry.totalClicks),
                label: "Clicks"
            )

            metricCard(
                icon: "clock",
                color: .teal,
                value: WidgetDataProvider.formatActiveTime(entry.activeMinutes),
                label: "Active"
            )
        }
        .widgetURL(URL(string: "inputmetrics://open"))
    }

    private func metricCard(icon: String, color: Color, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(color)

            if entry.hasData {
                Text(value)
                    .font(.system(.callout, design: .rounded, weight: .semibold))
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            } else {
                Text("--")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Widget Configuration

@main
struct InputMetricsWidget: Widget {
    let kind = "InputMetricsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: InputMetricsProvider()) { entry in
            InputMetricsWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Input Stats")
        .description("View today's input metrics at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
