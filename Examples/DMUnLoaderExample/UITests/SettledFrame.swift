import XCTest

@MainActor
struct FrameSource {
    let read: () -> CGRect
    let pause: (TimeInterval) -> Void
    let elapsed: () -> TimeInterval
}

enum FrameSettling: Equatable {
    case settled(CGRect)
    case unsettled(reads: [CGRect])
}

@MainActor
func settledFrame(
    from source: FrameSource,
    containing point: CGPoint,
    within budget: TimeInterval,
    every interval: TimeInterval = 0.25
) -> FrameSettling {
    let frame = source.read()
    return frame.contains(point) ? .settled(frame) : .unsettled(reads: [frame])
}
