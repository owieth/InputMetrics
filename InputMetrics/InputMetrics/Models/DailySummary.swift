import Foundation
import GRDB

struct DailySummary: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "daily_summary"

    var date: String
    var mouseDistancePx: Double
    var mouseClicksLeft: Int
    var mouseClicksRight: Int
    var mouseClicksMiddle: Int
    var keystrokes: Int
    var scrollDistanceVertical: Double
    var scrollDistanceHorizontal: Double
    var firstActiveAt: String?
    var lastActiveAt: String?
    var activeMinutes: Int = 0
    var avgMouseSpeed: Double = 0
    var peakMouseSpeed: Double = 0
    var peakWPM: Double = 0

    enum CodingKeys: String, CodingKey {
        case date
        case mouseDistancePx = "mouse_distance_px"
        case mouseClicksLeft = "mouse_clicks_left"
        case mouseClicksRight = "mouse_clicks_right"
        case mouseClicksMiddle = "mouse_clicks_middle"
        case keystrokes
        case scrollDistanceVertical = "scroll_distance_vertical"
        case scrollDistanceHorizontal = "scroll_distance_horizontal"
        case firstActiveAt = "first_active_at"
        case lastActiveAt = "last_active_at"
        case activeMinutes = "active_minutes"
        case avgMouseSpeed = "avg_mouse_speed"
        case peakMouseSpeed = "peak_mouse_speed"
        case peakWPM = "peak_wpm"
    }

    enum Columns {
        static let date = Column(CodingKeys.date)
        static let mouseDistancePx = Column(CodingKeys.mouseDistancePx)
        static let mouseClicksLeft = Column(CodingKeys.mouseClicksLeft)
        static let mouseClicksRight = Column(CodingKeys.mouseClicksRight)
        static let mouseClicksMiddle = Column(CodingKeys.mouseClicksMiddle)
        static let keystrokes = Column(CodingKeys.keystrokes)
        static let scrollDistanceVertical = Column(CodingKeys.scrollDistanceVertical)
        static let scrollDistanceHorizontal = Column(CodingKeys.scrollDistanceHorizontal)
        static let firstActiveAt = Column(CodingKeys.firstActiveAt)
        static let lastActiveAt = Column(CodingKeys.lastActiveAt)
        static let activeMinutes = Column(CodingKeys.activeMinutes)
        static let avgMouseSpeed = Column(CodingKeys.avgMouseSpeed)
        static let peakMouseSpeed = Column(CodingKeys.peakMouseSpeed)
        static let peakWPM = Column(CodingKeys.peakWPM)
    }

    static func zero(for date: String) -> DailySummary {
        DailySummary(date: date, mouseDistancePx: 0, mouseClicksLeft: 0, mouseClicksRight: 0, mouseClicksMiddle: 0, keystrokes: 0, scrollDistanceVertical: 0, scrollDistanceHorizontal: 0)
    }
}

extension [DailySummary] {
    func fillingMissingDays(from start: Date, to end: Date) -> [DailySummary] {
        let calendar = Calendar.current
        let formatter = DateHelper.self
        let existing = Dictionary(uniqueKeysWithValues: self.map { ($0.date, $0) })
        var result: [DailySummary] = []
        var current = start
        while current <= end {
            let key = formatter.string(from: current)
            result.append(existing[key] ?? .zero(for: key))
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
        }
        return result
    }
}
