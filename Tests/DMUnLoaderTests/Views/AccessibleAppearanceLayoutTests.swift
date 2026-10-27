//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMAction
import SwiftUI
import UIKit
import XCTest
import DMUnLoader

/// The loading view of the accessible look at the largest text sizes, with long localized texts: it
/// takes the width the card has and is as tall as its text needs, so that no line is cut. The height
/// the text needs is measured with the font and the width of the view, not guessed.
@MainActor
final class AccessibleAppearanceLayoutTests: XCTestCase {
    /// The width that a phone 390 points wide leaves to the content of the card: the window less the
    /// 15 points of the HUD around the card and the 15 points of the card around its content, on each side.
    private static let phoneContentWidth: CGFloat = 390 - 2 * 15 - 2 * 15

    /// The padding of the loading text on each side, which `ProgressTextProperties` gives by default.
    private static let textPadding: CGFloat = 10

    private struct Size {
        let dynamicType: DynamicTypeSize
        let category: UIContentSizeCategory
    }

    private static let accessibilitySizes = [
        Size(dynamicType: .accessibility1, category: .accessibilityMedium),
        Size(dynamicType: .accessibility2, category: .accessibilityLarge),
        Size(dynamicType: .accessibility3, category: .accessibilityExtraLarge),
        Size(dynamicType: .accessibility4, category: .accessibilityExtraExtraLarge),
        Size(dynamicType: .accessibility5, category: .accessibilityExtraExtraExtraLarge)
    ]

    /// Long texts of three languages; the German one has a compound word that no line holds at the
    /// largest size, the Arabic one runs right to left. Written with escapes to keep the source ASCII.
    private static let loadingTexts = [
        "Loading the data, please wait a moment while everything is made ready for you",
        "Die Daten werden geladen, bitte warten Sie einen Moment, w\u{E4}hrend alles f\u{FC}r Sie "
            + "vorbereitet wird: Datenschutzgrundverordnungsbest\u{E4}tigung",
        "\u{062C}\u{0627}\u{0631}\u{064D} \u{062A}\u{062D}\u{0645}\u{064A}\u{0644} "
            + "\u{0627}\u{0644}\u{0628}\u{064A}\u{0627}\u{0646}\u{0627}\u{062A}\u{060C} "
            + "\u{064A}\u{0631}\u{062C}\u{0649} \u{0627}\u{0644}\u{0627}\u{0646}\u{062A}\u{0638}\u{0627}\u{0631} "
            + "\u{0644}\u{062D}\u{0638}\u{0629} \u{0628}\u{064A}\u{0646}\u{0645}\u{0627} "
            + "\u{064A}\u{062A}\u{0645} \u{062A}\u{062C}\u{0647}\u{064A}\u{0632} "
            + "\u{0643}\u{0644} \u{0634}\u{064A}\u{0621} \u{0644}\u{0643}"
    ]

    func test_accessibleAppearance_accessibilityTextSizes_keepsLoadingTextVisible() {
        for size in Self.accessibilitySizes {
            for text in Self.loadingTexts {
                let fitted = fittedSize(of: loadingView(.accessible, text: text, size: size))
                let needed = neededHeight(of: text, size: size)

                XCTAssertLessThanOrEqual(
                    fitted.width,
                    Self.phoneContentWidth + 0.5,
                    "\(size.dynamicType): the view stays inside the \(Self.phoneContentWidth) points of the card: \(fitted.width)"
                )
                XCTAssertGreaterThanOrEqual(
                    fitted.height,
                    needed - 1,
                    "\(size.dynamicType): the view is as tall as its text needs, \(needed) points, "
                        + "so no line is cut: \(fitted.height)"
                )
            }
        }
    }

    func test_standardAppearance_accessibilityTextSizes_recordsTheCutText() {
        let size = Self.accessibilitySizes[4]
        let text = Self.loadingTexts[0]

        let fitted = fittedSize(of: loadingView(.standard, text: text, size: size))

        XCTAssertLessThanOrEqual(fitted.height, 150.5, "the released look keeps to half of its 300 points, as the README says")
        XCTAssertLessThan(fitted.height, neededHeight(of: text, size: size), "and so cuts the text, which stays as it is")
    }

    // MARK: - Close and Retry

    func test_accessibleAppearance_accessibilityTextSizes_stacksCloseAndRetry() {
        for size in Self.accessibilitySizes {
            let gain = heightRetryAdds(.accessible, at: size.dynamicType)

            XCTAssertGreaterThanOrEqual(
                gain,
                Self.buttonHeight,
                "\(size.dynamicType): Retry stands under Close, so it adds the height of a button: \(gain)"
            )
        }
    }

    func test_accessibleAppearance_defaultTextSize_keepsCloseAndRetrySideBySide() {
        let gain = heightRetryAdds(.accessible, at: .large)

        XCTAssertLessThan(gain, Self.buttonHeight, "at the default size the two buttons share a row: \(gain)")
    }

    func test_standardAppearance_accessibilityTextSizes_keepsCloseAndRetrySideBySide() {
        let gain = heightRetryAdds(.standard, at: .accessibility3)

        XCTAssertLessThan(gain, Self.buttonHeight, "the released look keeps the two buttons in a row: \(gain)")
    }

    // MARK: - Helpers

    /// The height of the button of the HUD, which its style gives as a minimum.
    private static let buttonHeight: CGFloat = 44

    /// How much taller the error view gets when it has a Retry button next to its Close button.
    private func heightRetryAdds(_ appearance: DMHUDAppearance, at size: DynamicTypeSize) -> CGFloat {
        let withRetry = fittedSize(of: errorView(appearance, retry: true, size: size)).height
        let withoutRetry = fittedSize(of: errorView(appearance, retry: false, size: size)).height
        return withRetry - withoutRetry
    }

    private func errorView(_ appearance: DMHUDAppearance, retry: Bool, size: DynamicTypeSize) -> some View {
        DefaultDMLoadingViewProvider(appearance: appearance)
            .getErrorView(
                error: DMAppError.custom("The server did not answer."),
                onRetry: retry ? DMButtonAction {} : nil,
                onClose: DMButtonAction {}
            )
            .environment(\.hudAppearance, appearance)
            .dynamicTypeSize(size)
    }

    private func loadingView(_ appearance: DMHUDAppearance, text: String, size: Size) -> some View {
        DefaultDMLoadingViewProvider(appearance: appearance)
            .getLoadingView()
            .environment(\.hudAppearance, appearance)
            .environment(\.hudTexts, FixedHUDTexts(loading: text))
            .dynamicTypeSize(size.dynamicType)
    }

    /// The size the view takes when the card offers it the width of a phone and as much height as it wants.
    private func fittedSize(of view: some View) -> CGSize {
        let host = UIHostingController(rootView: view)
        return host.sizeThatFits(in: CGSize(width: Self.phoneContentWidth, height: .greatestFiniteMagnitude))
    }

    /// The height that the text takes in the body font at the size, in the width left by the view's padding.
    private func neededHeight(of text: String, size: Size) -> CGFloat {
        let font = UIFont.preferredFont(
            forTextStyle: .body,
            compatibleWith: UITraitCollection(preferredContentSizeCategory: size.category)
        )
        let width = Self.phoneContentWidth - 2 * Self.textPadding
        let bounds = (text as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return ceil(bounds.height)
    }
}

/// The default texts of the HUD with a loading text of the test.
private struct FixedHUDTexts: HUDTexts {
    let loading: String

    func text(for role: HUDDefaultText) -> String {
        role == .loadingText ? loading : role.english
    }
}
