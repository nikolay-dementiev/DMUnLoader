//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import XCTest
import DMUnLoader

/// The contrast of the library's own views in the accessible look, measured as a number: each text
/// against the card it is drawn on, and each icon, indicator and outline, in light and in dark mode.
/// The released look is pinned as it is, so that the default does not change by accident.
@MainActor
final class AccessibleAppearanceContrastTests: XCTestCase {
    private static let styles: [UIUserInterfaceStyle] = [.light, .dark]

    /// What may lie behind a card that is not opaque: the darkest content, and the lightest content
    /// under the dim of 0.2 of the default backdrop.
    private static let behind: [WCAGContrast.Sample] = [
        .black,
        WCAGContrast.Sample(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
    ]

    // MARK: - The accessible look

    func test_accessibleAppearance_everyText_reachesContrast4point5() {
        let pairs = contrastPairs(of: .accessible).texts

        XCTAssertFalse(pairs.isEmpty, "there are texts to measure")
        assertRatios(of: pairs, atLeast: 4.5)
    }

    func test_accessibleAppearance_everyIconIndicatorAndOutline_reachesContrast3() {
        let pairs = contrastPairs(of: .accessible).graphics

        XCTAssertFalse(pairs.isEmpty, "there are icons, indicators and outlines to measure")
        assertRatios(of: pairs, atLeast: 3)
    }

    /// The accessibility audit of Xcode holds the card of a state, its image included, to 4.5 to 1: the
    /// glyph of the default images is the card showing through the coloured disc.
    func test_accessibleAppearance_defaultImages_reachContrast4point5() {
        let pairs = contrastPairs(of: .accessible).graphics.filter { ["error icon", "success icon"].contains($0.name) }

        XCTAssertEqual(pairs.count, 2, "the error icon and the success icon are measured")
        assertRatios(of: pairs, atLeast: 4.5)
    }

    func test_accessibleAppearance_card_isOpaque() {
        for isShown in [true, false] {
            for reducesTransparency in [true, false] {
                let card = DMHUDAppearance.accessible.cardBackground(
                    isShown: isShown,
                    reducesTransparency: reducesTransparency
                )
                for style in Self.styles {
                    XCTAssertEqual(
                        WCAGContrast.resolve(card, in: style).alpha,
                        1,
                        accuracy: 0.001,
                        "the accessible card is opaque (shown \(isShown), reduced transparency \(reducesTransparency), \(style))"
                    )
                }
            }
        }
    }

    // MARK: - The released look

    func test_standardAppearance_isTheReleasedLook() {
        let sut = DMHUDAppearance.standard

        XCTAssertEqual(sut.cardBackground(isShown: true, reducesTransparency: false), Color.gray.opacity(0.8), "gray at 0.8")
        XCTAssertEqual(
            sut.cardBackground(isShown: true, reducesTransparency: true),
            Color.gray.opacity(1),
            "opaque under Reduce Transparency"
        )
        XCTAssertEqual(
            sut.cardBackground(isShown: false, reducesTransparency: false),
            Color.gray.opacity(0.1),
            "faint while it fades in"
        )
        XCTAssertEqual(sut.loadingViewSettings.loadingTextProperties.foregroundColor, .white, "white loading text")
        XCTAssertEqual(sut.loadingViewSettings.progressIndicatorProperties.tintColor, .white, "white indicator")
        XCTAssertEqual(sut.errorViewSettings.errorTextSettings.foregroundColor, .white, "white error text")
        XCTAssertEqual(sut.errorViewSettings.errorImageSettings.foregroundColor, .red, "red error icon")
        XCTAssertEqual(sut.successViewSettings.successTextProperties.foregroundColor, .white, "white success text")
        XCTAssertEqual(sut.successViewSettings.successImageProperties.foregroundColor, .green, "green success icon")
        XCTAssertEqual(sut.buttonColor, .white, "white buttons")
    }

    func test_standardAppearance_recordsTheKnownContrastIssue() {
        let texts = contrastPairs(of: .standard).texts

        var lowest = Double.infinity
        for pair in texts {
            for style in Self.styles {
                for behind in Self.behind {
                    lowest = min(
                        lowest,
                        WCAGContrast.ratio(of: pair.foreground, on: pair.background, behind: behind, in: style)
                    )
                }
            }
        }

        XCTAssertLessThan(lowest, 4.5, "the released look does not reach 4.5 to 1 over light content, as the README says")
    }

    // MARK: - Helpers

    private struct Pair {
        let name: String
        let foreground: Color
        let background: Color
    }

    private struct Pairs {
        let texts: [Pair]
        let graphics: [Pair]
    }

    private func contrastPairs(of appearance: DMHUDAppearance) -> Pairs {
        let card = appearance.cardBackground(isShown: true, reducesTransparency: false)
        let loading = appearance.loadingViewSettings
        let error = appearance.errorViewSettings
        let success = appearance.successViewSettings
        let fallback = Color.primary

        return Pairs(
            texts: [
                Pair(name: "loading text", foreground: loading.loadingTextProperties.foregroundColor, background: card),
                Pair(name: "error text", foreground: error.errorTextSettings.foregroundColor ?? fallback, background: card),
                Pair(
                    name: "success text",
                    foreground: success.successTextProperties.foregroundColor ?? fallback,
                    background: card
                ),
                Pair(name: "button label", foreground: appearance.buttonColor, background: card)
            ],
            graphics: [
                Pair(
                    name: "progress indicator",
                    foreground: loading.progressIndicatorProperties.tintColor ?? fallback,
                    background: card
                ),
                Pair(name: "error icon", foreground: error.errorImageSettings.foregroundColor ?? fallback, background: card),
                Pair(
                    name: "success icon",
                    foreground: success.successImageProperties.foregroundColor ?? fallback,
                    background: card
                ),
                Pair(name: "button outline", foreground: appearance.buttonColor, background: card)
            ]
        )
    }

    private func assertRatios(
        of pairs: [Pair],
        atLeast minimum: Double,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for pair in pairs {
            for style in Self.styles {
                for behind in Self.behind {
                    let ratio = WCAGContrast.ratio(of: pair.foreground, on: pair.background, behind: behind, in: style)
                    XCTAssertGreaterThanOrEqual(
                        ratio,
                        minimum,
                        "\(pair.name) in \(style == .dark ? "dark" : "light") mode over a backdrop of luminance "
                            + "\(WCAGContrast.relativeLuminance(behind)): \(ratio) to 1, at least \(minimum) to 1 is needed",
                        file: file,
                        line: line
                    )
                }
            }
        }
    }
}
