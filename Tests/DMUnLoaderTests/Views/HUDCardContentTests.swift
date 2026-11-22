//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import ViewInspector
import XCTest
import DMUnLoader

/// The card of a shown HUD holds the view of the state as it is, not wrapped in an `AnyView`, so that
/// SwiftUI sees the type of that view and keeps its identity from one update to the next.
@MainActor
final class HUDCardContentTests: XCTestCase {

    func test_card_ofTheShownHUD_holdsTheStateViewNotAnAnyView() throws {
        let sut = makeSUT()

        // The search ignores the card's content type: it finds the card whatever it holds.
        let card = try sut.inspect().find(HUDCard<AnyView>.self)

        XCTAssertThrowsError(try card.actualView(), "a card that holds an AnyView has the wrong content type") { error in
            guard case InspectionError.typeMismatch = error else {
                XCTFail("the card's content type is the only thing that differs, but the error is \(error)")
                return
            }
        }
    }

    // MARK: - Helpers

    /// A scene view over a manager that shows a failure, with the view model the HUD builds for it.
    private func makeSUT() -> DMHudSceneView<DMLoadingManagerMain> {
        let settings = DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600))
        let manager = DMLoadingManagerMain(state: .none, settings: settings)
        manager.showFailure(DMAppError.custom("failed"), provider: DefaultDMLoadingViewProvider(), onRetry: nil)
        trackForMemoryLeaks(manager)
        return DMHudSceneView(loadingManager: manager, viewModel: hudViewModel(of: manager))
    }
}
