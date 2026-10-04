//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

/// The seconds of a `Duration`, which the auto-hide delay is read in.
final class DurationTimeIntervalTests: XCTestCase {

    func test_timeInterval_wholeSeconds_isTheSeconds() {
        XCTAssertEqual(Duration.seconds(2).timeInterval, 2, "two whole seconds are two seconds")
    }

    func test_timeInterval_milliseconds_isTheFractionOfASecond() {
        XCTAssertEqual(Duration.milliseconds(50).timeInterval, 0.05, "fifty milliseconds are 0.05 seconds")
    }

    func test_timeInterval_secondsAndMilliseconds_addUp() {
        let duration = Duration.seconds(2) + Duration.milliseconds(500)

        XCTAssertEqual(duration.timeInterval, 2.5, "two seconds and five hundred milliseconds are 2.5 seconds")
    }

    func test_timeInterval_zero_isZero() {
        XCTAssertEqual(Duration.zero.timeInterval, 0, "a zero duration has no seconds")
    }
}
