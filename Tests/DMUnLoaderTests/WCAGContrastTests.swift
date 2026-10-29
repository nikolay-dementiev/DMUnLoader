//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import XCTest

/// The tool that measures contrast, tried on pairs whose ratio is known, so that a measurement of the
/// HUD can be trusted.
@MainActor
final class WCAGContrastTests: XCTestCase {

    func test_ratio_blackOnWhite_is21() {
        XCTAssertEqual(
            WCAGContrast.ratio(.black, .white),
            21,
            accuracy: 0.001,
            "black on white is the largest ratio there is, 21 to 1"
        )
    }

    func test_ratio_aColourOnItself_is1() {
        let gray = WCAGContrast.Sample(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)

        XCTAssertEqual(WCAGContrast.ratio(gray, gray), 1, accuracy: 0.001, "a colour on itself is the smallest ratio, 1 to 1")
    }

    func test_ratio_isTheSameInEitherOrder() {
        let blue = WCAGContrast.Sample(red: 0, green: 0, blue: 1, alpha: 1)

        XCTAssertEqual(
            WCAGContrast.ratio(blue, .white),
            WCAGContrast.ratio(.white, blue),
            accuracy: 0.0001,
            "which of the two colours is the text does not change the ratio"
        )
    }

    func test_ratio_gray767676OnWhite_isTheKnownLimitOf4point5() {
        let gray = WCAGContrast.Sample(red: 118.0 / 255, green: 118.0 / 255, blue: 118.0 / 255, alpha: 1)

        XCTAssertEqual(
            WCAGContrast.ratio(gray, .white),
            4.54,
            accuracy: 0.01,
            "#767676 on white is the lightest gray that reaches 4.5 to 1, at 4.54"
        )
    }

    func test_ratio_ofColours_resolvesTheStyleOfTheInterface() {
        let label = Color(UIColor.label)

        XCTAssertEqual(
            WCAGContrast.ratio(of: label, on: Color(UIColor.systemBackground), behind: .black, in: .light),
            21,
            accuracy: 0.001,
            "the label on the background of the system is black on white in light mode"
        )
        XCTAssertEqual(
            WCAGContrast.ratio(of: label, on: Color(UIColor.systemBackground), behind: .black, in: .dark),
            21,
            accuracy: 0.001,
            "and white on black in dark mode"
        )
    }

    func test_ratio_ofColours_drawsATransparentBackgroundOverWhatIsBehindIt() {
        let half = Color.black.opacity(0.5)

        XCTAssertEqual(
            WCAGContrast.ratio(of: .white, on: half, behind: .white, in: .light),
            WCAGContrast.ratio(WCAGContrast.Sample(red: 0.5, green: 0.5, blue: 0.5, alpha: 1), .white),
            accuracy: 0.001,
            "white on half black over white is white on a middle gray"
        )
        XCTAssertGreaterThan(
            WCAGContrast.ratio(of: .white, on: half, behind: .black, in: .light),
            WCAGContrast.ratio(of: .white, on: half, behind: .white, in: .light),
            "the same card has more contrast over a dark backdrop than over a light one"
        )
    }
}
