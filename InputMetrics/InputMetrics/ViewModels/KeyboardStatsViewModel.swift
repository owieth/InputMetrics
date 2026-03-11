import Foundation
import Observation

@Observable
@MainActor
final class KeyboardStatsViewModel {
    var selectedRange: TimeRange = .week
    var chartData: [DailySummary] = []
    var keyboardEntries: [KeyboardEntry] = []

    var topKeys: [(id: String, name: String, count: Int)] {
        let sorted = keyboardEntries.sorted { $0.count > $1.count }
        return Array(sorted.prefix(5)).map { ($0.compositeId, KeyCodeMapping.keyName(for: $0.keyCode), $0.count) }
    }

    func loadAll() {
        loadChartData()
        loadKeyboardData()
    }

    func onRangeChanged() {
        loadChartData()
    }

    func loadChartData() {
        let calendar = Calendar.current
        let today = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        let daysBack: Int
        switch selectedRange {
        case .week: daysBack = 7
        case .month: daysBack = 30
        case .year: daysBack = 365
        }

        guard let startDate = calendar.date(byAdding: .day, value: -daysBack, to: today) else { return }

        let startString = formatter.string(from: startDate)
        let endString = formatter.string(from: today)

        chartData = DatabaseManager.shared.getDailySummaries(from: startString, to: endString)

        let todayStr = formatter.string(from: today)
        let mouseStats = MouseTracker.shared.getCurrentStats()
        let keyboardStats = KeyboardTracker.shared.getCurrentKeystrokes()

        if let idx = chartData.firstIndex(where: { $0.date == todayStr }) {
            chartData[idx].mouseDistancePx += mouseStats.distance
            chartData[idx].keystrokes += keyboardStats
            chartData[idx].mouseClicksLeft += mouseStats.left
            chartData[idx].mouseClicksRight += mouseStats.right
            chartData[idx].mouseClicksMiddle += mouseStats.middle
            chartData[idx].scrollDistanceVertical += mouseStats.scrollV
            chartData[idx].scrollDistanceHorizontal += mouseStats.scrollH
        } else {
            chartData.append(DailySummary(
                date: todayStr,
                mouseDistancePx: mouseStats.distance,
                mouseClicksLeft: mouseStats.left,
                mouseClicksRight: mouseStats.right,
                mouseClicksMiddle: mouseStats.middle,
                keystrokes: keyboardStats,
                scrollDistanceVertical: mouseStats.scrollV,
                scrollDistanceHorizontal: mouseStats.scrollH
            ))
        }
    }

    func loadKeyboardData() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())

        keyboardEntries = DatabaseManager.shared.getKeyboardEntries(date: today)
    }
}
