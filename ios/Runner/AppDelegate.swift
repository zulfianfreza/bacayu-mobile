import Flutter
import UIKit
import ActivityKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 16.2, *) {
      // Timer state is memory-only: discard orphan activities after cold launch.
      SessionActivityControl.pending = Task {
        for activity in Activity<SessionActivityAttributes>.activities {
          await activity.end(nil, dismissalPolicy: .immediate)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "SessionLiveActivity")!
    let channel = FlutterMethodChannel(name: "app.bacayu/session_activity", binaryMessenger: registrar.messenger())
    if #available(iOS 16.2, *) {
      SessionActivityControl.notify = { channel.invokeMethod("changed", arguments: nil) }
    }
    channel.setMethodCallHandler { call, result in
        guard #available(iOS 16.2, *) else { result(nil); return }
        guard ["update", "end", "events"].contains(call.method) else {
          result(FlutterMethodNotImplemented)
          return
        }
        let previous = SessionActivityControl.pending
        SessionActivityControl.pending = Task { @MainActor in
          await previous?.value
          if call.method == "events" {
            let events = SessionActivityControl.events
            SessionActivityControl.events.removeAll()
            result(events)
            return
          }
          if call.method == "end" {
            SessionActivityControl.activityID = nil
            for activity in Activity<SessionActivityAttributes>.activities {
              await activity.end(nil, dismissalPolicy: .immediate)
            }
            result(nil)
            return
          }
          guard let args = call.arguments as? [String: Any],
                let title = args["title"] as? String,
                let status = args["status"] as? String,
                let elapsed = args["elapsed"] as? Double, elapsed.isFinite, elapsed >= 0,
                let timestamp = args["referenceDate"] as? Double, timestamp.isFinite,
                let paused = args["paused"] as? Bool,
                let runningLabel = args["runningLabel"] as? String,
                let pausedLabel = args["pausedLabel"] as? String,
                let pauseLabel = args["pauseLabel"] as? String,
                let resumeLabel = args["resumeLabel"] as? String,
                let tint = args["tint"] as? NSNumber else {
            result(FlutterError(code: "INVALID_ACTIVITY", message: nil, details: nil))
            return
          }
          let state = SessionActivityAttributes.ContentState(
            referenceDate: Date(timeIntervalSince1970: timestamp),
            elapsed: elapsed, paused: paused, status: status)
          let content = ActivityContent(state: state, staleDate: nil)
          do {
            if let activity = Activity<SessionActivityAttributes>.activities.first {
              // Unconsumed native commands take precedence over a stale UI update.
              if SessionActivityControl.events.isEmpty {
                await activity.update(content)
              }
            } else if ActivityAuthorizationInfo().areActivitiesEnabled {
              SessionActivityControl.events.removeAll()
              let activity = try Activity.request(
                attributes: SessionActivityAttributes(title: title, tint: tint.uint32Value,
                  runningLabel: runningLabel, pausedLabel: pausedLabel,
                  pauseLabel: pauseLabel, resumeLabel: resumeLabel),
                content: content, pushType: nil)
              SessionActivityControl.activityID = activity.id
            }
            result(nil)
          } catch {
            result(FlutterError(code: "ACTIVITY_UNAVAILABLE", message: error.localizedDescription, details: nil))
          }
        }
      }
  }
}
