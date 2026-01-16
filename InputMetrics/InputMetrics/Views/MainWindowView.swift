import SwiftUI

enum StatsTab {
    case mouse
    case keyboard
}

struct MainWindowView: View {
    @State private var selectedTab: StatsTab = .mouse

    var body: some View {
        VStack(spacing: 0) {
            // Header with tab switcher
            HStack {
                Picker("View", selection: $selectedTab) {
                    Text("Mouse").tag(StatsTab.mouse)
                    Text("Keyboard").tag(StatsTab.keyboard)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)

                Spacer()
            }
            .padding()

            Divider()

            // Content
            ScrollView {
                switch selectedTab {
                case .mouse:
                    MouseStatsView()
                case .keyboard:
                    KeyboardStatsView()
                }
            }
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

#Preview {
    MainWindowView()
}
