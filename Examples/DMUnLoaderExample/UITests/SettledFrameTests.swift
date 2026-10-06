import XCTest

/// The settled read of a control's frame. The frames come from a script and the clock moves
/// with the pauses, so these tests run without the app.
@MainActor
final class SettledFrameTests: XCTestCase {

    func test_settle_frameChangesTwiceThenHolds_givesTheFrameThatHolds() {
        let frames = [covering(x: 0), covering(x: 10), covering(x: 20), covering(x: 20)]
        let source = scriptedSource { frames[min($0, frames.count - 1)] }

        let result = settledFrame(from: source, containing: screenCentre, within: 15)

        XCTAssertEqual(result, .settled(covering(x: 20)), "the frame that two reads agree on is the settled frame")
        XCTAssertEqual(source.elapsed(), 0.75, "the frame settles at the read that agrees with the one before it")
    }

    func test_settle_twoEqualReads_settleAtTheSecondRead() {
        let source = scriptedSource { _ in covering(x: 0) }

        let result = settledFrame(from: source, containing: screenCentre, within: 15)

        XCTAssertEqual(result, .settled(covering(x: 0)), "a frame that two consecutive reads agree on settles")
        XCTAssertEqual(source.elapsed(), 0.25, "the second read comes 0.25 s after the first")
    }

    func test_settle_readsOneIntervalApart_settleAtThatInterval() {
        let source = scriptedSource { _ in covering(x: 0) }

        let result = settledFrame(from: source, containing: screenCentre, within: 15, every: 0.5)

        XCTAssertEqual(result, .settled(covering(x: 0)), "the frame settles with a longer interval as well")
        XCTAssertEqual(source.elapsed(), 0.5, "the second read comes one interval after the first")
    }

    func test_settle_frameNeverCoversTheCentre_givesNoFrameAfterTheBudget() {
        let source = scriptedSource { _ in outside }

        let result = settledFrame(from: source, containing: screenCentre, within: 15)

        guard case let .unsettled(reads) = result else {
            return XCTFail("a frame that never covers the centre must not settle: \(result)")
        }
        XCTAssertEqual(reads.count, 61, "the frame is read at 0, 0.25, ... 15 s, and then given up")
        XCTAssertTrue(reads.allSatisfy { !$0.contains(screenCentre) }, "every frame read misses the centre")
    }

    func test_settle_frameKeepsChanging_givesNoFrameAfterTheBudget() {
        let source = scriptedSource { covering(x: CGFloat($0)) }

        let result = settledFrame(from: source, containing: screenCentre, within: 15)

        guard case let .unsettled(reads) = result else {
            return XCTFail("a frame that keeps changing must not settle: \(result)")
        }
        XCTAssertEqual(reads.count, 61, "the frame is read until the budget is spent")
        let agreeing = zip(reads, reads.dropFirst()).filter { $0 == $1 }.count
        XCTAssertEqual(agreeing, 0, "no two consecutive reads agree, so no read settles")
    }

    /// A source whose n-th read, counted from 0, is `frame(n)`. Each pause moves the clock on by
    /// its length, and `elapsed` reads the clock.
    @MainActor
    private func scriptedSource(_ frame: @escaping (Int) -> CGRect) -> FrameSource {
        var reads = 0
        var now: TimeInterval = 0
        return FrameSource(
            read: {
                defer { reads += 1 }
                return frame(reads)
            },
            pause: { now += $0 },
            elapsed: { now }
        )
    }
}

/// The centre of a 402 by 874 point screen, where the example's touches are aimed.
private let screenCentre = CGPoint(x: 201, y: 437)

/// A frame of the full screen, moved to the right by `x`, so that it covers the centre.
private func covering(x: CGFloat) -> CGRect {
    CGRect(x: x, y: 0, width: 402, height: 874)
}

/// A frame below the screen, which does not cover the centre.
private let outside = CGRect(x: 0, y: 874, width: 402, height: 100)
