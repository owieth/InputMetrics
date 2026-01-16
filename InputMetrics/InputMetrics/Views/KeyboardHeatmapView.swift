import SwiftUI

struct KeyboardHeatmapView: View {
    let entries: [KeyboardEntry]

    private var keyCountMap: [String: Int] {
        var map: [String: Int] = [:]
        for entry in entries {
            let keyName = KeyCodeMapping.keyName(for: entry.keyCode)
            map[keyName, default: 0] += entry.count
        }
        return map
    }

    private var maxCount: Int {
        keyCountMap.values.max() ?? 1
    }

    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<KeyCodeMapping.qwertzLayout.count, id: \.self) { rowIndex in
                HStack(spacing: 2) {
                    ForEach(0..<KeyCodeMapping.qwertzLayout[rowIndex].count, id: \.self) { colIndex in
                        let key = KeyCodeMapping.qwertzLayout[rowIndex][colIndex]
                        if !key.isEmpty {
                            KeyView(
                                label: key,
                                count: keyCountMap[key] ?? 0,
                                maxCount: maxCount
                            )
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.05))
        .cornerRadius(12)
    }
}

struct KeyView: View {
    let label: String
    let count: Int
    let maxCount: Int

    private var intensity: Double {
        guard maxCount > 0 else { return 0 }
        return Double(count) / Double(maxCount)
    }

    private var backgroundColor: Color {
        if intensity == 0 {
            return Color.gray.opacity(0.2)
        } else if intensity < 0.2 {
            return Color.blue.opacity(0.3)
        } else if intensity < 0.4 {
            return Color.cyan.opacity(0.5)
        } else if intensity < 0.6 {
            return Color.green.opacity(0.7)
        } else if intensity < 0.8 {
            return Color.yellow.opacity(0.8)
        } else {
            return Color.red.opacity(0.9)
        }
    }

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            if count > 0 {
                Text("\(count)")
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: keyWidth, height: 40)
        .background(backgroundColor)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
    }

    private var keyWidth: CGFloat {
        // Special widths for certain keys
        if label.contains("Space") {
            return 200
        } else if label == "⌫" || label == "↵" {
            return 60
        } else if label == "⇥" || label == "⇪" {
            return 50
        }
        return 40
    }
}

#Preview {
    KeyboardHeatmapView(entries: [
        KeyboardEntry(date: "2025-01-16", keyCode: 0, modifierFlags: 0, count: 150), // A
        KeyboardEntry(date: "2025-01-16", keyCode: 1, modifierFlags: 0, count: 80),  // S
        KeyboardEntry(date: "2025-01-16", keyCode: 49, modifierFlags: 0, count: 300) // Space
    ])
    .padding()
}
