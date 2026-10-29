//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import XCTest
import DMUnLoader

/// The card around the view of a state. In the accessible look it hugs a view that fits the screen and
/// scrolls one that does not, so that no line is cut off at the largest text sizes; the released card
/// never scrolls.
@MainActor
final class AccessibleAppearanceCardTests: XCTestCase {
    private static let screen = CGSize(width: 390, height: 800)
    private static let padding: CGFloat = 15

    func test_accessibleCard_contentTallerThanTheScreen_takesNoMoreThanTheScreen() {
        let sut = makeCard(.accessible, contentHeight: 3000)

        let height = fittedHeight(of: sut)

        XCTAssertLessThanOrEqual(height, Self.screen.height, "a card taller than the screen scrolls, it takes \(height) pt")
    }

    func test_accessibleCard_contentThatFits_takesTheHeightOfItsContent() {
        let sut = makeCard(.accessible, contentHeight: 100)

        let height = fittedHeight(of: sut)

        XCTAssertEqual(height, 100 + 2 * Self.padding, accuracy: 1, "a card that fits hugs its content, it takes \(height) pt")
    }

    func test_standardCard_contentTallerThanTheScreen_keepsTheHeightOfItsContent() {
        let sut = makeCard(.standard, contentHeight: 3000)

        let height = fittedHeight(of: sut)

        XCTAssertEqual(height, 3000 + 2 * Self.padding, accuracy: 1, "the released card does not scroll, it takes \(height) pt")
    }

    // MARK: - Helpers

    private func makeCard(_ appearance: DMHUDAppearance, contentHeight: CGFloat) -> HUDCard {
        HUDCard(
            appearance: appearance,
            isShown: true,
            content: AnyView(Color.red.frame(width: 200, height: contentHeight))
        )
    }

    /// The height the card takes when the screen offers it a phone width and a phone height.
    private func fittedHeight(of card: HUDCard) -> CGFloat {
        UIHostingController(rootView: card).sizeThatFits(in: Self.screen).height
    }
}
