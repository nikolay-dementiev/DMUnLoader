import XCTest

/// Where the frames of a control come from: a read of its frame, a pause before the next read,
/// and the seconds elapsed since the first read.
@MainActor
struct FrameSource {
    let read: () -> CGRect
    let pause: (TimeInterval) -> Void
    let elapsed: () -> TimeInterval

    /// The frames of `element` as the accessibility tree reports them. The pause lets the screen
    /// move on between two reads, and the time is the wall clock, so a slow read counts toward the
    /// budget.
    static func of(_ element: XCUIElement) -> FrameSource {
        let start = ProcessInfo.processInfo.systemUptime
        return FrameSource(
            read: { element.frame },
            pause: { seconds in
                _ = XCTWaiter().wait(for: [XCTestExpectation(description: "the screen moves on")], timeout: seconds)
            },
            elapsed: { ProcessInfo.processInfo.systemUptime - start }
        )
    }
}

/// The outcome of `settledFrame`: the frame that settled, or the frames read when none did.
enum FrameSettling: Equatable {
    case settled(CGRect)
    case unsettled(reads: [CGRect])
}

/// Reads the frame until it settles: a frame that covers `point` and that the read before it
/// returned unchanged, `interval` seconds earlier. Gives up once `budget` seconds have passed
/// since the first read.
@MainActor
func settledFrame(
    from source: FrameSource,
    containing point: CGPoint,
    within budget: TimeInterval,
    every interval: TimeInterval = 0.25
) -> FrameSettling {
    var reads: [CGRect] = []
    while true {
        let frame = source.read()
        reads.append(frame)
        if frame.contains(point), reads.count > 1, reads[reads.count - 2] == frame {
            return .settled(frame)
        }
        guard source.elapsed() < budget else {
            return .unsettled(reads: reads)
        }
        source.pause(interval)
    }
}
