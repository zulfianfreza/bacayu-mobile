import ActivityKit
import Foundation
import AppIntents

@available(iOS 16.2, *)
struct SessionActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var referenceDate: Date
        var elapsed: TimeInterval
        var paused: Bool
        var status: String
    }

    var title: String
    var tint: UInt32
    var runningLabel: String
    var pausedLabel: String
    var pauseLabel: String
    var resumeLabel: String
}

@available(iOS 16.2, *)
@MainActor
enum SessionActivityControl {
    static var activityID: String?
    static var events: [[String: Any]] = []
    static var notify: (() -> Void)?
    static var pending: Task<Void, Never>?
}

@available(iOS 17.0, *)
struct ToggleSessionIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Pause or resume reading"
    static var openAppWhenRun = false

    @Parameter(title: "Activity") var activityID: String

    init() {}
    init(activityID: String) { self.activityID = activityID }

    @MainActor
    func perform() async throws -> some IntentResult {
        let previous = SessionActivityControl.pending
        let task = Task { @MainActor in
            await previous?.value
            // A cold launch cannot restore the memory-only Flutter session.
            guard SessionActivityControl.activityID == activityID,
                  let activity = Activity<SessionActivityAttributes>.activities.first(where: { $0.id == activityID }) else { return }
            var state = activity.content.state
            let now = Date()
            if !state.paused {
                state.elapsed += max(0, now.timeIntervalSince(state.referenceDate))
            }
            state.referenceDate = now
            state.paused.toggle()
            state.status = state.paused ? activity.attributes.pausedLabel : activity.attributes.runningLabel
            SessionActivityControl.events.append([
                "paused": state.paused, "timestamp": now.timeIntervalSince1970
            ])
            await activity.update(ActivityContent(state: state, staleDate: nil))
            SessionActivityControl.notify?()
        }
        SessionActivityControl.pending = task
        await task.value
        return .result()
    }
}
