import Foundation
import GRDB

struct DailySummary: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "daily_summary"

    var date: String // "2025-01-16"
    var mouseDistancePx: Double
    var mouseClicksLeft: Int
    var mouseClicksRight: Int
    var mouseClicksMiddle: Int
    var keystrokes: Int

    enum Columns {
        static let date = Column(CodingKeys.date)
        static let mouseDistancePx = Column(CodingKeys.mouseDistancePx)
        static let mouseClicksLeft = Column(CodingKeys.mouseClicksLeft)
        static let mouseClicksRight = Column(CodingKeys.mouseClicksRight)
        static let mouseClicksMiddle = Column(CodingKeys.mouseClicksMiddle)
        static let keystrokes = Column(CodingKeys.keystrokes)
    }
}
