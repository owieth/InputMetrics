import Foundation

@MainActor
class UserPreferences: ObservableObject {
    static let shared = UserPreferences()

    @Published var distanceUnit: DistanceUnit {
        didSet {
            UserDefaults.standard.set(distanceUnit == .metric ? "metric" : "imperial", forKey: "distanceUnit")
        }
    }

    private init() {
        let savedUnit = UserDefaults.standard.string(forKey: "distanceUnit") ?? "metric"
        self.distanceUnit = savedUnit == "metric" ? .metric : .imperial
    }
}
