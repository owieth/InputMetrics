import SwiftUI
import LaunchAtLogin

struct SettingsView: View {
    @State private var distanceUnit: DistanceUnit = .metric
    @State private var showResetConfirmation = false
    @State private var exportMessage: String?

    var body: some View {
        Form {
            Section("General") {
                LaunchAtLogin.Toggle("Launch at login")
            }

            Section("Display") {
                Picker("Distance units", selection: $distanceUnit) {
                    Text("Metric (km/m)").tag(DistanceUnit.metric)
                    Text("Imperial (mi/ft)").tag(DistanceUnit.imperial)
                }
            }

            Section("Data") {
                Button("Export data as CSV") {
                    exportData()
                }

                Button("Reset all data", role: .destructive) {
                    showResetConfirmation = true
                }
            }

            if let message = exportMessage {
                Section {
                    Text(message)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 500, minHeight: 400)
        .alert("Reset all data?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                resetData()
            }
        } message: {
            Text("This will permanently delete all tracking data. This action cannot be undone.")
        }
    }

    private func exportData() {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "InputMetrics-Export.csv"
        panel.canCreateDirectories = true
        panel.allowedContentTypes = [.commaSeparatedText]

        panel.begin { response in
            if response == .OK, let url = panel.url {
                do {
                    let csvContent = generateCSV()
                    try csvContent.write(to: url, atomically: true, encoding: .utf8)
                    exportMessage = "Data exported successfully to \(url.lastPathComponent)"
                } catch {
                    exportMessage = "Export failed: \(error.localizedDescription)"
                }
            }
        }
    }

    private func generateCSV() -> String {
        var csv = ""

        // Daily summary section
        csv += "=== DAILY SUMMARY ===\n"
        csv += "Date,Mouse Distance (px),Left Clicks,Right Clicks,Middle Clicks,Keystrokes\n"

        // Get all daily summaries (this is a simplified version)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())

        if let summary = DatabaseManager.shared.getDailySummary(date: today) {
            csv += "\(summary.date),\(summary.mouseDistancePx),\(summary.mouseClicksLeft),\(summary.mouseClicksRight),\(summary.mouseClicksMiddle),\(summary.keystrokes)\n"
        }

        csv += "\n"

        // Mouse heatmap section
        csv += "=== MOUSE HEATMAP ===\n"
        csv += "Date,Screen ID,Bucket X,Bucket Y,Click Count\n"

        let mouseData = DatabaseManager.shared.getMouseHeatmap(date: today)
        for entry in mouseData {
            csv += "\(entry.date),\(entry.screenId),\(entry.bucketX),\(entry.bucketY),\(entry.clickCount)\n"
        }

        csv += "\n"

        // Keyboard heatmap section
        csv += "=== KEYBOARD HEATMAP ===\n"
        csv += "Date,Key Code,Key Name,Modifier Flags,Count\n"

        let keyboardData = DatabaseManager.shared.getKeyboardEntries(date: today)
        for entry in keyboardData {
            let keyName = KeyCodeMapping.keyName(for: entry.keyCode)
            csv += "\(entry.date),\(entry.keyCode),\(keyName),\(entry.modifierFlags),\(entry.count)\n"
        }

        return csv
    }

    private func resetData() {
        DatabaseManager.shared.resetAllData()
        exportMessage = "All data has been reset"
    }
}

#Preview {
    SettingsView()
}
