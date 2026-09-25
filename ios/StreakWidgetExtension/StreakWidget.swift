import SwiftUI
import WidgetKit

/// Must match `StreakWidgetService._appGroupId`
/// (lib/core/widget/streak_widget_service.dart) — TODO: rename both together
/// once the app's real bundle id (currently the Flutter template placeholder
/// `com.example.mobile`) is decided.
private let appGroupId = "group.com.example.mobile.streak"

/// Colors hand-mirrored from lib/core/theme/app_colors.dart (Style Guide
/// Section 2) — a WidgetKit extension can't import the Dart theme, so these
/// are kept in sync by hand, same as the Android widget's colors.xml.
private enum StreakWidgetColors {
    static let tangerine500 = Color(red: 1, green: 0.416, blue: 0.239)
    static let tangerine50 = Color(red: 1, green: 0.945, blue: 0.922)
    static let ink = Color(red: 0.169, green: 0.129, blue: 0.09)
}

struct StreakEntry: TimelineEntry {
    let date: Date
    let currentStreak: Int
    let last7DaysHasActivity: [Bool]
}

/// App-driven refresh only, same contract as the Android provider
/// (StreakWidgetProvider.kt) — this never fetches anything itself, only
/// re-reads whatever `StreakWidgetService.push` last wrote to the App Group's
/// `UserDefaults`. The single timeline entry never expires on its own; the
/// next render happens when the app calls `HomeWidget.updateWidget`.
struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(
            date: Date(),
            currentStreak: 5,
            last7DaysHasActivity: [true, true, false, true, true, true, false]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        completion(Timeline(entries: [readEntry()], policy: .never))
    }

    private func readEntry() -> StreakEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        let currentStreak = defaults?.integer(forKey: "currentStreak") ?? 0
        let last7Days = defaults?.string(forKey: "last7Days") ?? "0000000"
        return StreakEntry(
            date: Date(),
            currentStreak: currentStreak,
            last7DaysHasActivity: last7Days.map { $0 == "1" }
        )
    }
}

struct StreakWidgetView: View {
    var entry: StreakProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .foregroundColor(StreakWidgetColors.tangerine500)
                    .font(.system(size: 24))
                Text("\(entry.currentStreak)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(StreakWidgetColors.ink)
            }
            Text("day streak")
                .font(.system(size: 12))
                .foregroundColor(StreakWidgetColors.ink)
                .opacity(0.7)
            HStack(spacing: 6) {
                ForEach(0..<7, id: \.self) { index in
                    Circle()
                        .fill(dotColor(for: index))
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.top, 6)
        }
        .padding()
        // WidgetKit's only tap-to-open mechanism — no plain "launch app"
        // API exists for widgets. `homeWidget=true` matches the query
        // param the `home_widget` plugin's AppDelegate hook looks for.
        .widgetURL(URL(string: "bacayu://open?homeWidget=true"))
    }

    private func dotColor(for index: Int) -> Color {
        let active = index < entry.last7DaysHasActivity.count && entry.last7DaysHasActivity[index]
        return active ? StreakWidgetColors.tangerine500 : Color(.systemGray4)
    }
}

struct StreakWidget: Widget {
    let kind: String = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    StreakWidgetColors.tangerine50
                }
        }
        .configurationDisplayName("BacaYu Streak")
        .description("Shows your BacaYu reading streak")
        .supportedFamilies([.systemSmall])
    }
}
