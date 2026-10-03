//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import SwiftUI
import SnapshotTesting
import ViewInspector

@MainActor
final class DMLoadingViewTests: XCTestCase {

    override func invokeTest() {
        withSnapshotTesting(diffTool: .ksdiff) {
            super.invokeTest()
        }
    }
    
    // MARK: - Scenario 1: Verify Empty State (`.none`)
    
    func testLoadingView_ShowsEmptyStateWith_NoOverlayOrBackground_WhenLoadingStateIsNone() {
        // Given
        let loadingManager = StubDMLoadingManager(loadableState: .none)
        
        // When
        let sut = makeSUT(manager: loadingManager)
        
        // Then
        assertImageSnapshot(
            of: sut,
            style: .light,
            named: "View-EmptyState-No-Overlay-or-Background-iPhone13Pro-light"
        )
    }
    
    func test_noState_hasNeitherBackdropNorCard() {
        // Given
        let loadingManager = StubDMLoadingManager(loadableState: .none)

        // When
        let sut = makeSUT(manager: loadingManager)

        // Then
        XCTAssertThrowsError(
            try sut.inspect().find(ViewType.Color.self),
            "without a state the view draws no backdrop and no card"
        )
    }
    
    // MARK: - Scenario 2: Verify Loading State (`.loading`)
    
    func testLoadingView_ShowsLoadingView_WhenLoadingStateIsLoading() {
        // Given
        let provider = StubDMLoadingViewProvider()
        let loadingManager = StubDMLoadingManager(
            loadableState: .loading(
                provider: provider.eraseToAnyViewProvider()
            )
        )

        // When
        let sut = makeSUT(manager: loadingManager)

        // Then
        assertImageSnapshot(
            of: fadedIn(sut),
            style: .light,
            named: "View-LoadingState-iPhone13Pro-light"
        )
    }
    
    func test_loading_showsTheLoadingViewOfTheProvider() {
        // Given
        let provider = StubDMLoadingViewProvider()
        let loadingManager = StubDMLoadingManager(
            loadableState: .loading(
                provider: provider.eraseToAnyViewProvider()
            )
        )

        // When
        let sut = makeSUT(manager: loadingManager)

        // Then
        XCTAssertNoThrow(
            try sut.inspect().find(text: "Stub Loading View"),
            "while loading the view shows the loading view of the provider"
        )
    }
    
    func testLoadingView_TheOverlayAnimatesSmoothly_IntoView_forState_Loading() {
        testLoadingView_TheOverlayAnimatesSmoothly_IntoView(state:
                .loading(
                    provider: StubDMLoadingViewProvider()
                        .eraseToAnyViewProvider()
        ))
    }
    
    // MARK: - Scenario 3: Verify Failure State (`.failure`)
    
    func testLoadingView_ShowsFailureView_WhenLoadingStateIsFailure() {
        // Given
        let provider = StubDMLoadingViewProvider()
        let loadingManager = StubDMLoadingManager(
            loadableState: .failure(
                error: DMUnLoader.DMAppError.custom("Test Error"),
                provider: provider.eraseToAnyViewProvider(),
                onRetry: DMButtonAction {}
            )
        )

        // When
        let sut = makeSUT(manager: loadingManager)

        // Then
        assertImageSnapshot(
            of: fadedIn(sut),
            style: .light,
            named: "View-FailureState-iPhone13Pro-light"
        )
    }
    
    func test_failure_showsTheErrorViewOfTheProvider() {
        // Given
        let provider = StubDMLoadingViewProvider()
        let loadingManager = StubDMLoadingManager(
            loadableState: .failure(
                error: DMUnLoader.DMAppError.custom("Test Error"),
                provider: provider.eraseToAnyViewProvider()
            )
        )

        // When
        let sut = makeSUT(manager: loadingManager)

        // Then
        XCTAssertNoThrow(
            try sut.inspect().find(text: "Stub Error View"),
            "a failure shows the error view of the provider"
        )
    }
    
    func testLoadingView_TheOverlayAnimatesSmoothly_IntoView_forState_Failure() {
        let provider = StubDMLoadingViewProvider()
        testLoadingView_TheOverlayAnimatesSmoothly_IntoView(
            state:
                    .failure(
                        error: DMUnLoader.DMAppError.custom("Test Error"),
                        provider: provider.eraseToAnyViewProvider()
                    )
        )
    }
    
    // MARK: - Scenario 4: Verify Success State (`.success`)
    
    func testLoadingView_ShowsSuccessView_WhenLoadingStateIsSuccess() {
        // Given
        let provider = StubDMLoadingViewProvider()
        let loadingManager = StubDMLoadingManager(
            loadableState: .success(
                "Test Success",
                provider: provider.eraseToAnyViewProvider()
            )
        )

        // When
        let sut = makeSUT(manager: loadingManager)

        // Then
        assertImageSnapshot(
            of: fadedIn(sut),
            style: .light,
            named: "View-SuccessState-iPhone13Pro-light"
        )
    }
    
    func test_success_showsTheSuccessViewOfTheProvider() {
        // Given
        let provider = StubDMLoadingViewProvider()
        let loadingManager = StubDMLoadingManager(
            loadableState: .success(
                "Test Success",
                provider: provider.eraseToAnyViewProvider()
            )
        )

        // When
        let sut = makeSUT(manager: loadingManager)

        // Then
        XCTAssertNoThrow(
            try sut.inspect().find(text: "Stub Success View"),
            "a success shows the success view of the provider"
        )
    }
    
    func testLoadingView_TheOverlayAnimatesSmoothly_IntoView_forState_Success() {
        let provider = StubDMLoadingViewProvider()
        testLoadingView_TheOverlayAnimatesSmoothly_IntoView(
            state:
                    .success(
                        "Test Success",
                        provider: provider.eraseToAnyViewProvider()
                    )
        )
    }
    
    // MARK: - Scenario 5: Verify Tap Gesture Behavior
    
    func testLoadingView_DoesRespondToTapGestures_WhenInSuccessState() throws {
        // Given & When
        let provider = StubDMLoadingViewProvider()
            .eraseToAnyViewProvider()
        let currentStateConditions: [(DMLoadableType, DMLoadableType)] = [
            (.success(
                "Test Success",
                provider: provider
            ), .none),
            (.loading(provider: provider), .loading(provider: provider)),
            (.failure(
                error: DMUnLoader.DMAppError.custom("Test Error"),
                provider: provider.eraseToAnyViewProvider(),
                onRetry: DMButtonAction {}
            ), .none),
            (.none, .none)
        ]
        
        // Then
        try checktLoadingView_RespondToTapGestures_ForStates(currentStateConditions)
    }
    
    // MARK: - Helpers
    
    private func makeSUT<LM: DMLoadingManager>(manager loadingManager: LM) -> DMLoadingView<LM> {
        
        let sut = DMLoadingView(
            loadingManager: loadingManager,
            viewModel: DefaultHUDViewModel(loadingManager: loadingManager)
        )
        
        trackForMemoryLeaks(loadingManager)
        
        return sut
    }
    
    /// How long a view is hosted before its fade-in can have ended. The fade is a spring of
    /// 0.2 seconds.
    private static let fadeInTime: Double = 0.6

    /// The view hosted in a window of the snapshot device's size until its fade-in has
    /// ended, then taken out of the window, so a snapshot shows the HUD as a person sees it
    /// once it has appeared. The fade-in has ended when two renderings a tenth of a second
    /// apart are the same: on a busy machine, with test runs in parallel, the spring can
    /// still be moving after `fadeInTime`.
    private func fadedIn(_ view: some View) -> UIViewController {
        let controller = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = controller
        window.isHidden = false
        RunLoop.current.run(until: Date().addingTimeInterval(Self.fadeInTime))
        let deadline = Date().addingTimeInterval(TestTiming.callbackAllowance)
        var previous = controller.view.renderedLayers().pngData()
        while Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
            let current = controller.view.renderedLayers().pngData()
            if current == previous {
                break
            }
            previous = current
        }
        window.isHidden = true
        window.rootViewController = nil
        return controller
    }

    private func testLoadingView_TheOverlayAnimatesSmoothly_IntoView(
        state: DMLoadableType,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        // Given
        let loadingManager = StubDMLoadingManager(
            loadableState: state
        )

        // When
        let sut = makeSUT(manager: loadingManager)

        // Then
        assertImageSnapshot(
            of: sut,
            style: .light,
            named: "BeforeAnimation-\(state.rawValue)-iPhone13Pro-light",
            file: file,
            line: line
        )
        assertImageSnapshot(
            of: fadedIn(sut),
            style: .light,
            named: "AfterAnimation-\(state.rawValue)-iPhone13Pro-light",
            file: file,
            line: line
        )
    }
    
    func checktLoadingView_RespondToTapGestures_ForStates(
        _ statesCondition: [(given: DMLoadableType, expected: DMLoadableType)],
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        try statesCondition.forEach { currentStateCondition in
            // Given
            let loadingManager = StubDMLoadingManager(
                loadableState: currentStateCondition.given
            )
            
            // When
            let sut = makeSUT(manager: loadingManager)
            
            // The tap gesture sits on the root of the view.
            let inspectableView = try sut.inspect().zStack()
            
            // Then
            XCTAssertEqual(sut.loadingManager.loadableState,
                           currentStateCondition.given,
                           "The loading state should be `\(currentStateCondition.given)` before the user taps the view",
                           file: file,
                           line: line)
            
            try inspectableView.callOnTapGesture()
            
            XCTAssertEqual(sut.loadingManager.loadableState,
                           currentStateCondition.expected,
                           "The loading state should be `\(currentStateCondition.expected)` after the user taps the view",
                           file: file,
                           line: line)
        }
    }
}
