import ActivityKit
import SwiftUI
import WidgetKit
import UIKit

struct SessionLiveActivityWidget: Widget {
    @ScaledMetric(relativeTo: .body) private var iconSize = 22.0

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SessionActivityAttributes.self) { context in
            HStack {
                bookIcon(paused: context.state.paused)
                    .foregroundStyle(tint(context.attributes.tint))
                    .accessibilityHidden(true)
                VStack(alignment: .leading) {
                    Text(context.attributes.title).font(.subheadline.weight(.semibold)).lineLimit(2)
                    Text(context.state.status).font(.caption)
                }
                Spacer()
                timer(context.state).font(.title2)
                controls(context)
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    bookIcon(paused: context.state.paused)
                        .foregroundStyle(tint(context.attributes.tint))
                        .accessibilityHidden(true)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    timer(context.state).font(.title2)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading) {
                        Text(context.attributes.title).font(.subheadline.weight(.semibold)).lineLimit(2)
                        Text(context.state.status).font(.caption)
                        controls(context)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
            } compactLeading: {
                bookIcon(paused: context.state.paused)
                    .foregroundStyle(tint(context.attributes.tint))
                    .accessibilityLabel(context.state.status)
            } compactTrailing: {
                timer(context.state).frame(maxWidth: 64)
            } minimal: {
                bookIcon(paused: context.state.paused)
                    .foregroundStyle(tint(context.attributes.tint))
                    .accessibilityLabel(context.state.status)
            }
        }
    }

    @ViewBuilder
    private func controls(_ context: ActivityViewContext<SessionActivityAttributes>) -> some View {
        if #available(iOS 17.0, *) {
            Button(intent: ToggleSessionIntent(activityID: context.activityID)) {
                Image(systemName: context.state.paused ? "play.fill" : "pause.fill")
                    .frame(minWidth: 44, minHeight: 44)
            }
            .buttonStyle(.plain)
            .foregroundStyle(tint(context.attributes.tint))
            .accessibilityLabel(context.state.paused ? context.attributes.resumeLabel : context.attributes.pauseLabel)
        }
    }

    @ViewBuilder
    private func bookIcon(paused: Bool) -> some View {
        if paused {
            Image(systemName: "pause.fill")
        } else if let path = Bundle.main.path(forResource: "book-open-02-stroke", ofType: "png"),
                  let image = UIImage(contentsOfFile: path) {
            Image(uiImage: image)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
        } else {
            Image(systemName: "book.fill")
        }
    }

    private func timer(_ state: SessionActivityAttributes.ContentState) -> some View {
        let start = state.referenceDate.addingTimeInterval(-state.elapsed)
        return Text(timerInterval: start...Date.distantFuture,
                    pauseTime: state.paused ? state.referenceDate : nil,
                    countsDown: false)
            .monospacedDigit()
            .multilineTextAlignment(.trailing)
    }

    private func tint(_ argb: UInt32) -> Color {
        Color(red: Double((argb >> 16) & 255) / 255,
              green: Double((argb >> 8) & 255) / 255,
              blue: Double(argb & 255) / 255)
    }
}
