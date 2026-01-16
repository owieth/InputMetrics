import SwiftUI

struct MenuBarView: View {
    @State private var mouseDistance: Double = 0
    @State private var keystrokes: Int = 0
    @State private var leftClicks: Int = 0
    @State private var rightClicks: Int = 0
    @State private var middleClicks: Int = 0

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("InputMetrics")
                    .font(.headline)
                Spacer()
                Button(action: {
                    // TODO: Open settings
                }) {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.plain)

                Button(action: {
                    // TODO: Open main window
                }) {
                    Image(systemName: "arrow.up.forward.square")
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Stats section
            HStack(alignment: .top, spacing: 40) {
                // Mouse stats
                VStack(alignment: .leading, spacing: 8) {
                    Label("Mouse", systemImage: "cursorarrow")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(DistanceConverter.formatDistance(mouseDistance))
                        .font(.title2.bold())

                    Text("today")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Keyboard stats
                VStack(alignment: .leading, spacing: 8) {
                    Label("Keyboard", systemImage: "keyboard")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("\(keystrokes)")
                        .font(.title2.bold())

                    Text("keystrokes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()

            Divider()

            // Fun comparisons
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("🌍")
                    Text(DistanceConverter.formatEarthComparison(mouseDistance))
                        .font(.caption)
                }

                HStack {
                    Text("🌙")
                    Text(DistanceConverter.formatMoonComparison(mouseDistance))
                        .font(.caption)
                }

                HStack {
                    Text("Clicks:")
                        .font(.caption)
                    Text("\(leftClicks) L | \(rightClicks) R | \(middleClicks) M")
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .frame(width: 320)
        .onReceive(timer) { _ in
            updateStats()
        }
        .onAppear {
            updateStats()
        }
    }

    private func updateStats() {
        // Get current stats from trackers
        let mouseStats = MouseTracker.shared.getCurrentStats()
        let keyboardStats = KeyboardTracker.shared.getCurrentKeystrokes()

        // Get today's persisted data
        let today = getTodayString()
        if let summary = DatabaseManager.shared.getDailySummary(date: today) {
            mouseDistance = summary.mouseDistancePx + mouseStats.distance
            keystrokes = summary.keystrokes + keyboardStats
            leftClicks = summary.mouseClicksLeft + mouseStats.left
            rightClicks = summary.mouseClicksRight + mouseStats.right
            middleClicks = summary.mouseClicksMiddle + mouseStats.middle
        } else {
            mouseDistance = mouseStats.distance
            keystrokes = keyboardStats
            leftClicks = mouseStats.left
            rightClicks = mouseStats.right
            middleClicks = mouseStats.middle
        }
    }

    private func getTodayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

#Preview {
    MenuBarView()
}
