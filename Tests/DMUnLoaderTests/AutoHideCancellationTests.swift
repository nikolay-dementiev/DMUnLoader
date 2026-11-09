//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMUnLoader
import XCTest

/// The token a scheduler hands back for a pending auto-hide: the action it was given runs at most
/// once, on a cancel or on the release of the last reference to it, whichever comes first.
@MainActor
final class AutoHideCancellationTests: XCTestCase {

    func test_cancel_runsTheActionOnce() {
        let runs = RunCounter()
        let sut = makeSUT(runs: runs)

        sut.cancel()

        XCTAssertEqual(runs.count, 1, "a cancel runs the action the scheduler supplied")
    }

    func test_cancelTwice_runsTheActionOnce() {
        let runs = RunCounter()
        let sut = makeSUT(runs: runs)

        sut.cancel()
        sut.cancel()

        XCTAssertEqual(runs.count, 1, "a second cancel runs nothing: the action is spent")
    }

    func test_release_runsTheActionOnce() {
        let runs = RunCounter()

        // The token is dropped at once, without a cancel: an owner that goes away stops the hide.
        _ = makeSUT(runs: runs)

        XCTAssertEqual(runs.count, 1, "the last release of a token that was not cancelled runs the action")
    }

    func test_cancelThenRelease_runsTheActionOnce() {
        let runs = RunCounter()

        do {
            let sut = makeSUT(runs: runs)
            sut.cancel()
        }

        XCTAssertEqual(runs.count, 1, "a release after a cancel runs nothing more")
    }

    func test_keptToken_runsNoAction() {
        let runs = RunCounter()
        let sut = makeSUT(runs: runs)

        XCTAssertEqual(runs.count, 0, "a token that is held and not cancelled runs nothing")
        withExtendedLifetime(sut) {}
    }

    // MARK: - Helpers

    private func makeSUT(runs: RunCounter, file: StaticString = #filePath, line: UInt = #line) -> AutoHideCancellation {
        let sut = AutoHideCancellation { runs.count += 1 }
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}

/// Counts how often the action of a token ran.
private final class RunCounter {
    var count = 0
}
