import Foundation
import GRDB

struct MouseHeatmapEntry: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "mouse_heatmap"

    var date: String
    var screenId: String
    var bucketX: Int
    var bucketY: Int
    var clickCount: Int

    enum Columns {
        static let date = Column(CodingKeys.date)
        static let screenId = Column(CodingKeys.screenId)
        static let bucketX = Column(CodingKeys.bucketX)
        static let bucketY = Column(CodingKeys.bucketY)
        static let clickCount = Column(CodingKeys.clickCount)
    }
}
