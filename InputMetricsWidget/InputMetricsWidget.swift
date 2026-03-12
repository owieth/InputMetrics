import WidgetKit
import SwiftUI

struct InputMetricsEntry: TimelineEntry {
    let date: Date
    let keystrokes: Int
    let mouseDistance: String
    let clicks: Int
}

struct InputMetricsProvider: TimelineProvider {
    func placeholder(in context: Context) -> InputMetricsEntry {
        InputMetricsEntry(date: Date(), keystrokes: 0, mouseDistance: "0 m", clicks: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (InputMetricsEntry) -> Void) {
        let entry = InputMetricsEntry(date: Date(), keystrokes: 1234, mouseDistance: "2.5 km", clicks: 567)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<InputMetricsEntry>) -> Void) {
        // Read from shared database
        // For now, use placeholder data until App Group is configured
        let entry = InputMetricsEntry(date: Date(), keystrokes: 0, mouseDistance: "0 m", clicks: 0)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(300)))
        completion(timeline)
    }
}

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
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "keyboard")
                .font(.title2)
                .foregroundStyle(.purple)

            Text("\(entry.keystrokes)")
                .font(.title.bold())
                .monospacedDigit()

            Text("Keystrokes Today")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Label("Keystrokes", systemImage: "keyboard")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(entry.keystrokes)")
                    .font(.title2.bold().monospacedDigit())
            }

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Label("Distance", systemImage: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(entry.mouseDistance)
                    .font(.title2.bold().monospacedDigit())
            }

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Label("Clicks", systemImage: "cursorarrow.click")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(entry.clicks)")
                    .font(.title2.bold().monospacedDigit())
            }
        }
        .padding()
    }
}

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
