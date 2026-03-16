import SwiftUI

struct MiniKeyboardHeatmap: View {
    let entries: [KeyboardEntry]

    private var keyCountMap: [Int: Int] {
        var map: [Int: Int] = [:]
        for entry in entries {
            map[entry.keyCode, default: 0] += entry.count
        }
        return map
    }

    private var maxCount: Int {
        keyCountMap.values.max() ?? 1
    }

    private var keyboardLayout: [[(keyCode: Int, label: String, width: CGFloat)]] {
        let label = { (keyCode: Int) in KeyCodeMapping.keyName(for: keyCode) }
        return [
            // Number row
            [(50, label(50), 1), (18, label(18), 1), (19, label(19), 1), (20, label(20), 1), (21, label(21), 1), (23, label(23), 1), (22, label(22), 1), (26, label(26), 1), (28, label(28), 1), (25, label(25), 1), (29, label(29), 1), (27, label(27), 1), (24, label(24), 1)],
            // Top letter row
            [(12, label(12), 1), (13, label(13), 1), (14, label(14), 1), (15, label(15), 1), (17, label(17), 1), (16, label(16), 1), (32, label(32), 1), (34, label(34), 1), (31, label(31), 1), (35, label(35), 1), (33, label(33), 1), (30, label(30), 1)],
            // Middle letter row
            [(0, label(0), 1), (1, label(1), 1), (2, label(2), 1), (3, label(3), 1), (5, label(5), 1), (4, label(4), 1), (38, label(38), 1), (40, label(40), 1), (37, label(37), 1), (41, label(41), 1), (39, label(39), 1), (42, label(42), 1)],
            // Bottom letter row
            [(6, label(6), 1), (7, label(7), 1), (8, label(8), 1), (9, label(9), 1), (11, label(11), 1), (45, label(45), 1), (46, label(46), 1), (43, label(43), 1), (47, label(47), 1), (44, label(44), 1)],
            // Space row
            [(49, label(49), 6)]
        ]
    }

    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<keyboardLayout.count, id: \.self) { rowIndex in
                HStack(spacing: 2) {
                    ForEach(0..<keyboardLayout[rowIndex].count, id: \.self) { keyIndex in
                        let key = keyboardLayout[rowIndex][keyIndex]
                        let count = keyCountMap[key.keyCode] ?? 0
                        let intensity = Double(count) / Double(maxCount)

                        KeyCapView(
                            label: key.label,
                            count: count,
                            intensity: intensity,
                            width: key.width
                        )
                    }
                }
            }
        }
        .padding(8)
        .background(Color.black.opacity(0.05))
        .cornerRadius(8)
    }
}

struct KeyCapView: View {
    let label: String
    let count: Int
    let intensity: Double
    let width: CGFloat

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            if count > 0 {
                Text("\(count)")
                    .font(.system(size: 6))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 28 * width, height: 28)
        .background(HeatmapColor.forKeyboardIntensity(intensity))
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
        )
    }

}
