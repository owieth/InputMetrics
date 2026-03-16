import Foundation
import GRDB

struct WidgetDailySummary: Codable, FetchableRecord {
    var date: String
    var mouseDistancePx: Double
    var mouseClicksLeft: Int
    var mouseClicksRight: Int
    var mouseClicksMiddle: Int
    var keystrokes: Int
    var activeMinutes: Int

    var totalClicks: Int { mouseClicksLeft + mouseClicksRight + mouseClicksMiddle }

    enum CodingKeys: String, CodingKey {
        case date
        case mouseDistancePx = "mouse_distance_px"
        case mouseClicksLeft = "mouse_clicks_left"
        case mouseClicksRight = "mouse_clicks_right"
        case mouseClicksMiddle = "mouse_clicks_middle"
        case keystrokes
        case activeMinutes = "active_minutes"
    }
}

enum WidgetDataProvider {
    static let appGroupID = "group.com.inputmetrics.shared"

    static func sharedDatabaseURL() -> URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent("metrics.db")
    }

    static func sharedDefaults() -> UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static func fetchTodaySummary() -> WidgetDailySummary? {
        guard let dbURL = sharedDatabaseURL(),
              FileManager.default.fileExists(atPath: dbURL.path) else {
            return nil
        }

        do {
            let dbQueue = try DatabaseQueue(path: dbURL.path)
            return try dbQueue.read { db in
                try WidgetDailySummary.fetchOne(
                    db,
                    sql: "SELECT * FROM daily_summary WHERE date = ?",
                    arguments: [todayString()]
                )
            }
        } catch {
            return nil
        }
    }

    static func todayString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    static func distanceUnit() -> String {
        sharedDefaults()?.string(forKey: "distanceUnit") ?? "metric"
    }

    static func formatDistance(_ pixels: Double) -> String {
        let pixelsPerMeter = 4330.0
        let meters = pixels / pixelsPerMeter
        let unit = distanceUnit()

        if unit == "imperial" {
            let feet = meters / 0.3048
            if feet >= 5280 {
                return String(format: "%.2f mi", feet / 5280)
            } else {
                return String(format: "%.1f ft", feet)
            }
        } else {
            if meters >= 1000 {
                return String(format: "%.2f km", meters / 1000)
            } else {
                return String(format: "%.1f m", meters)
            }
        }
    }

    static func formatActiveTime(_ minutes: Int) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "\(hours)h"
            }
            return "\(hours)h \(mins)m"
        } else {
            return "\(minutes)m"
        }
    }

    static func formatCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 10_000 {
            return String(format: "%.1fk", Double(count) / 1000)
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = ","
            return formatter.string(from: NSNumber(value: count)) ?? "\(count)"
        }
    }
}
