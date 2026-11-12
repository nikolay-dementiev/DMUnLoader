//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import ViewInspector
import XCTest
import DMUnLoader

/// The scene view acts through the view model it is given and makes none of its own: a tap on the card,
/// a tap outside it and the Close button of a failure all reach that one view model.
@MainActor
final class DMHudSceneViewViewModelTests: XCTestCase {

    func test_closeOnAFailure_reachesTheViewModelThatWasGiven() throws {
        let fixture = makeSUT()

        try fixture.sut.inspect().find(button: "Close").tap()

        XCTAssertEqual(fixture.viewModel.calls, [.closeTapped], "Close reaches the view model that was given")
        XCTAssertNotEqual(fixture.manager.loadableState, .none, "a view model of the scene view's own would have hidden it")
    }

    func test_tapOnTheCard_reachesTheViewModelThatWasGiven() throws {
        let fixture = makeSUT()

        try fixture.sut.inspect().find(HUDCard.self).callOnTapGesture()

        XCTAssertEqual(fixture.viewModel.calls, [.cardTapped], "a tap on the card reaches the view model that was given")
        XCTAssertNotEqual(fixture.manager.loadableState, .none, "a view model of the scene view's own would have hidden it")
    }

    func test_tapOutsideTheCard_reachesTheViewModelThatWasGiven() throws {
        let fixture = makeSUT()

        // The scene view has two clear layers: its own base, and the one outside the card that takes the tap.
        let clearLayers = try fixture.sut.inspect().findAll(ViewType.Color.self, where: { try $0.value() == Color.clear })
        let outsideLayer = try XCTUnwrap(clearLayers.last, "the scene view has a clear layer outside the card")
        try outsideLayer.callOnTapGesture()

        XCTAssertEqual(fixture.viewModel.calls, [.backdropTapped], "a tap outside the card reaches the view model that was given")
        XCTAssertNotEqual(fixture.manager.loadableState, .none, "a view model of the scene view's own would have hidden it")
    }

    // MARK: - Helpers

    private struct Fixture {
        let sut: DMHudSceneView<DMLoadingManagerMain>
        let viewModel: HUDViewModelSpy
        let manager: DMLoadingManagerMain
    }

    /// A scene view over a manager that shows a failure, with a spy for a view model.
    private func makeSUT() -> Fixture {
        let settings = DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600))
        let manager = DMLoadingManagerMain(state: .none, settings: settings)
        manager.showFailure(DMAppError.custom("failed"), provider: DefaultDMLoadingViewProvider(), onRetry: nil)
        let viewModel = HUDViewModelSpy()
        trackForMemoryLeaks(manager)
        return Fixture(
            sut: DMHudSceneView(loadingManager: manager, viewModel: viewModel),
            viewModel: viewModel,
            manager: manager
        )
    }
}

/// Records what the view reports to its view model, and shows a HUD so that the card and the backdrop exist.
@MainActor
private final class HUDViewModelSpy: HUDViewModel {
    enum Call: Equatable {
        case cardTapped
        case backdropTapped
        case closeTapped
    }

    let showsHUD = true
    private(set) var calls: [Call] = []

    func cardTapped() {
        calls.append(.cardTapped)
    }

    func backdropTapped() -> Bool {
        calls.append(.backdropTapped)
        return false
    }

    func closeTapped() {
        calls.append(.closeTapped)
    }
}
