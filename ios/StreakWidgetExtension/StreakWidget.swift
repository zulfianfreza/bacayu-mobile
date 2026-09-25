import SwiftUI
import WidgetKit

private let appGroupId = "group.com.example.mobile.streak"

private enum WidgetPalette {
    static let ink = Color(red: 0.169, green: 0.129, blue: 0.09)
    static let flame = Color(red: 1, green: 0.416, blue: 0.239)
    static let inactive = Color(.systemGray4)

    static func background(for bundle: String) -> LinearGradient {
        let colors: [Color]
        switch bundle {
        case "calm_a": colors = [hex(0x7EC8E3), hex(0xD6EFFA)]
        case "calm_b": colors = [hex(0xBFE3F5), hex(0xBFE3F5)]
        case "calm_c": colors = [hex(0x8FD9C4), hex(0xE0F7EF)]
        case "reminder_a": colors = [hex(0xFFB88C), hex(0xFFE3D0)]
        case "reminder_b": colors = [hex(0xFFD9B3), hex(0xFFD9B3)]
        case "reminder_c": colors = [hex(0xFF9F80), hex(0xFFD9CC)]
        case "urgent_a": colors = [hex(0x3A4A7A), hex(0x6C7BA8)]
        case "urgent_b": colors = [hex(0x4B5A8A), hex(0x4B5A8A)]
        case "critical_a": colors = [hex(0x7A2E3A), hex(0xB5495B)]
        case "critical_b": colors = [hex(0x8C3A47), hex(0x8C3A47)]
        case "repair_a": colors = [hex(0x8FA3AD), hex(0xB7C4C9)]
        case "repair_b": colors = [hex(0xA9B8BD), hex(0xA9B8BD)]
        case "done_a": colors = [hex(0xFFDE9E), hex(0xFFF3D6)]
        case "done_b": colors = [hex(0xFFCBA4), hex(0xFFCBA4)]
        case "done_c": colors = [hex(0xB8E3C9), hex(0xE8F7EE)]
        default: colors = [hex(0xD6F0FB), hex(0xD6F0FB)]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private static func hex(_ value: UInt) -> Color {
        Color(red: Double((value >> 16) & 0xff) / 255, green: Double((value >> 8) & 0xff) / 255, blue: Double(value & 0xff) / 255)
    }
}

struct StreakEntry: TimelineEntry {
    let date: Date
    let currentStreak: Int
    let weeklyHeatmap: [Bool]
    let bundleId: String
    let message: String
    let mascotName: String
}

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry { sample }
    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) { completion(readEntry()) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        completion(Timeline(entries: [readEntry()], policy: .never))
    }

    private var sample: StreakEntry {
        StreakEntry(date: Date(), currentStreak: 5, weeklyHeatmap: [true, true, false, true, true, true, false], bundleId: "calm_a", message: "Bacaaa yuk!", mascotName: "mascot_calm_a")
    }

    private func readEntry() -> StreakEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        let heatmap = defaults?.string(forKey: "weekly_heatmap") ?? "0000000"
        return StreakEntry(
            date: Date(),
            currentStreak: defaults?.integer(forKey: "current_streak") ?? 0,
            weeklyHeatmap: heatmap.map { $0 == "1" },
            bundleId: defaults?.string(forKey: "bundle_id") ?? "calm_a",
            message: defaults?.string(forKey: "message_text") ?? "Bacaaa yuk!",
            mascotName: defaults?.string(forKey: "mascot_res_name") ?? "mascot_calm_a"
        )
    }
}

struct StreakWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: StreakEntry

    var body: some View {
        ZStack(alignment: family == .systemSmall ? .bottom : .bottomTrailing) {
            WidgetPalette.background(for: entry.bundleId)
            mascot
            if family == .systemMedium { mediumContent } else { smallContent }
        }
        .widgetURL(URL(string: "bacayu://widget/start-session?homeWidget=true"))
    }

    private var mascot: some View {
        // ponytail: only four generated poses exist. Map missing poses to closest available asset; replace when all PNGs arrive.
        Image(availableMascot)
            .resizable()
            .scaledToFit()
            .frame(width: family == .systemSmall ? 150 : 155, height: family == .systemSmall ? 150 : 155)
            .padding(family == .systemSmall ? 0 : 4)
    }

    private var availableMascot: String {
        switch entry.mascotName {
        case "mascot_calm_b", "mascot_calm_c", "mascot_reminder_a": return entry.mascotName
        default: return entry.bundleId.hasPrefix("reminder") ? "mascot_reminder_a" : "mascot_calm_a"
        }
    }

    private var smallContent: some View {
        VStack(spacing: 2) {
            streakCount
            Text(entry.message).font(.system(size: 12, weight: .medium)).multilineTextAlignment(.center).lineLimit(2)
            Spacer()
        }
        .foregroundStyle(WidgetPalette.ink).padding(12)
    }

    private var mediumContent: some View {
        VStack(alignment: .leading, spacing: 3) {
            streakCount
            Text(entry.message).font(.system(size: 12, weight: .medium)).lineLimit(2).frame(maxWidth: 135, alignment: .leading)
            heatmap.padding(.top, 5)
            Spacer()
        }
        .foregroundStyle(WidgetPalette.ink).frame(maxWidth: .infinity, alignment: .leading).padding(14)
    }

    private var streakCount: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill").foregroundStyle(WidgetPalette.flame).font(.system(size: 23))
            Text("\(entry.currentStreak)").font(.system(size: 26, weight: .bold))
        }
    }

    private var heatmap: some View {
        HStack(spacing: 5) {
            ForEach(Array(["Sn", "Sl", "Rb", "Km", "Jm", "Sb", "Mg"].enumerated()), id: \.offset) { index, day in
                VStack(spacing: 2) {
                    Image(systemName: isActive(index) ? "checkmark.circle.fill" : "circle.fill")
                        .font(.system(size: 12)).foregroundStyle(isActive(index) ? WidgetPalette.flame : WidgetPalette.inactive)
                    Text(day).font(.system(size: 8, weight: .medium))
                }
            }
        }
    }

    private func isActive(_ index: Int) -> Bool { index < entry.weeklyHeatmap.count && entry.weeklyHeatmap[index] }
}

struct StreakWidget: Widget {
    let kind = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakWidgetView(entry: entry).containerBackground(for: .widget) { Color.clear }
        }
        .configurationDisplayName("BacaYu Streak")
        .description("Shows your BacaYu reading streak")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
