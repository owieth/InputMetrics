import os

enum AppLogger {
    static let database = Logger(subsystem: "com.inputmetrics.app", category: "database")
    static let events = Logger(subsystem: "com.inputmetrics.app", category: "events")
    static let mouse = Logger(subsystem: "com.inputmetrics.app", category: "mouse")
    static let keyboard = Logger(subsystem: "com.inputmetrics.app", category: "keyboard")
    static let ui = Logger(subsystem: "com.inputmetrics.app", category: "ui")
    static let general = Logger(subsystem: "com.inputmetrics.app", category: "general")
}
