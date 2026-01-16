import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize database
        _ = DatabaseManager.shared

        // Create menu bar icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "chart.bar.fill", accessibilityDescription: "InputMetrics")
            button.action = #selector(statusItemClicked)
            button.target = self
        }

        // Create popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 280)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: MenuBarView())

        // Hide dock icon for menu bar-only app
        NSApp.setActivationPolicy(.accessory)

        // Start event monitoring on main actor
        Task { @MainActor in
            EventMonitor.shared.start()
        }

        print("InputMetrics launched successfully")
    }

    @objc private func statusItemClicked() {
        guard let button = statusItem?.button else { return }
        guard let popover = popover else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
