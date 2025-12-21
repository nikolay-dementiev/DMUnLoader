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
        withSnapshotTesting(
            record: .missing,
            diffTool: .ksdiff
        ) {
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
        assertSnapshot(
            of: sut,
            as: .image(
                layout: .device(config: .iPhone13Pro),
                traits: .init(userInterfaceStyle: .light)
            ),
            named: "View-EmptyState-No-Overlay-or-Background-iPhone13Pro-light",
            record: false
        )
    }
    
    func testLoadingView_AssignTagFromSettingsToEmptyStateView_WhenLoadingStateIsNone() throws {
        // Given
        let loadingManager = StubDMLoadingManager(loadableState: .none)
        
        // When
        let sut = makeSUT(manager: loadingManager)
        let tagToFindTheView = DMLoadingViewOwnSettings.emptyViewTag
        let emptyView = try sut
            .inspect()
            .find(viewWithTag: tagToFindTheView)
        
        // Then
        XCTAssertNotNil(emptyView,
                        "The EmptyView should have the correct tag assigned from settings: `\(tagToFindTheView)`")
    }
    
    // MARK: - Scenario 2: Verify Loading State (`.loading`)
    
    func testLoadingView_ShowsLoadingView_WhenLoadingStateIsLoading() throws {
        // Given
        let provider = StubDMLoadingViewProvider()
        let loadingManager = StubDMLoadingManager(
            loadableState: .loading(
                provider: provider.eraseToAnyViewProvider()
            )
        )
        
        // When
        let sut = makeSUT(manager: loadingManager)
        
        let inspection = try XCTUnwrap(
            sut.inspection,
            "Inspection should be available in debug mode"
        )
        
        // Then
        let exp = inspection.inspect { view in
            let actualView = try view.actualView()
            
            assertSnapshot(
                of: actualView,
                as: .image(
                    layout: .device(config: .iPhone13Pro),
                    traits: .init(userInterfaceStyle: .light)
                ),
                named: "View-LoadingState-iPhone13Pro-light"
            )
        }
        
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }
        wait(for: [exp], timeout: 0.3)
    }
    
    func testLoadingView_AssignTagFromSettingsToEmptyStateView_WhenLoadingStateIsLoading() throws {
        // Given
        let provider = StubDMLoadingViewProvider()
        let loadingManager = StubDMLoadingManager(
            loadableState: .loading(
                provider: provider.eraseToAnyViewProvider()
            )
        )
        
        // When
        let sut = makeSUT(manager: loadingManager)
        let tagToFindTheView = DMLoadingViewOwnSettings.loadingViewTag
        let loadingView = try sut
            .inspect()
            .find(viewWithTag: tagToFindTheView)
        
        // Then
        XCTAssertNotNil(loadingView,
                        "The LoadingView should have the correct tag assigned from settings: `\(tagToFindTheView)`")
    }
    
    func testLoadingView_TheOverlayAnimatesSmoothly_IntoView_forState_Loading() throws {
        try testLoadingView_TheOverlayAnimatesSmoothly_IntoView(state:
                .loading(
                    provider: StubDMLoadingViewProvider()
                        .eraseToAnyViewProvider()
        ))
    }
    
    // MARK: - Scenario 3: Verify Failure State (`.failure`)
    
    func testLoadingView_ShowsFailureView_WhenLoadingStateIsFailure() throws {
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
        
        let inspection = try XCTUnwrap(
            sut.inspection,
            "Inspection should be available in debug mode"
        )
        
        // Then
        let exp = inspection.inspect { view in
            let actualView = try view.actualView()
            
            assertSnapshot(
                of: actualView,
                as: .image(
                    layout: .device(config: .iPhone13Pro),
                    traits: .init(userInterfaceStyle: .light)
                ),
                named: "View-FailureState-iPhone13Pro-light"
            )
        }
        
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }
        wait(for: [exp], timeout: 0.3)
    }
    
    func testLoadingView_AssignTagFromSettingsToFailureStateView_WhenLoadingStateIsFailure() throws {
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
        let tagToFindTheView = DMLoadingViewOwnSettings.failureViewTag
        let failureView = try sut
            .inspect()
            .find(viewWithTag: tagToFindTheView)
        
        // Then
        XCTAssertNotNil(failureView,
                        "The FailureView should have the correct tag assigned from settings: `\(tagToFindTheView)`")
    }
    
    func testLoadingView_TheOverlayAnimatesSmoothly_IntoView_forState_Failure() throws {
        let provider = StubDMLoadingViewProvider()
        try testLoadingView_TheOverlayAnimatesSmoothly_IntoView(
            state:
                    .failure(
                        error: DMUnLoader.DMAppError.custom("Test Error"),
                        provider: provider.eraseToAnyViewProvider()
                    )
        )
    }
    
    // MARK: - Scenario 4: Verify Success State (`.success`)
    
    func testLoadingView_ShowsSuccessView_WhenLoadingStateIsSuccess() throws {
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
        
        let inspection = try XCTUnwrap(
            sut.inspection,
            "Inspection should be available in debug mode"
        )
        
        // Then
        let exp = inspection.inspect { view in
            let actualView = try view.actualView()
            
            assertSnapshot(
                of: actualView,
                as: .image(
                    layout: .device(config: .iPhone13Pro),
                    traits: .init(userInterfaceStyle: .light)
                ),
                named: "View-SuccessState-iPhone13Pro-light"
            )
        }
        
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }
        wait(for: [exp], timeout: 0.3)
    }
    
    func testLoadingView_AssignTagFromSettingsToSuccessStateView_WhenLoadingStateIsSuccess() throws {
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
        let tagToFindTheView = DMLoadingViewOwnSettings.successViewTag
        let actualView = try sut
            .inspect()
            .find(viewWithTag: tagToFindTheView)
        
        // Then
        XCTAssertNotNil(actualView,
                        "The SuccessView should have the correct tag assigned from settings: `\(tagToFindTheView)`")
    }
    
    func testLoadingView_TheOverlayAnimatesSmoothly_IntoView_forState_Success() throws {
        let provider = StubDMLoadingViewProvider()
        try testLoadingView_TheOverlayAnimatesSmoothly_IntoView(
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
    
    // MARK: - Scenario 6: Verify Auto-Hide Behavior
    
    func testAutoHideBehavior_For_Success_Failure_None_States() throws {
        // Given
        let secondsAutoHideDelay: Double = 0.05
        let provider = StubDMLoadingViewProvider()
            .eraseToAnyViewProvider()
        let statesToCheck: [DMLoadableType] = [
            .success(
                "Test Success",
                provider: provider
            ),
            .failure(
                error: DMUnLoader.DMAppError.custom("Test Error"),
                provider: provider.eraseToAnyViewProvider(),
                onRetry: DMButtonAction {}
            ),
            .none
        ]
        
        // When & Then
        try checkAutoHideBehavior_For_States(statesToCheck,
                                             secondsAutoHideDelay: secondsAutoHideDelay)
    }
    
    // MARK: - Helpers
    
    private func makeSUT<LM: DMLoadingManager>(manager loadingManager: LM) -> DMLoadingView<LM> {
        
        let sut = DMLoadingView(loadingManager: loadingManager)
        
        trackForMemoryLeaks(loadingManager)
        
        return sut
    }
    
    private func testLoadingView_TheOverlayAnimatesSmoothly_IntoView(
        state: DMLoadableType,
        record recording: Bool? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        // Given
        let loadingManager = StubDMLoadingManager(
            loadableState: state
        )
        let animationDuration: Double = 0.2
        
        // When
        let sut = makeSUT(manager: loadingManager)
        
        let inspection = try XCTUnwrap(
            sut.inspection,
            "Inspection should be available in debug mode",
            file: file,
            line: line
        )
        
        // Then
        assertSnapshot(
            of: sut,
            as: .image(
                layout: .device(config: .iPhone13Pro),
                traits: .init(userInterfaceStyle: .light)
            ),
            named: "BeforeAnimation-\(state.rawValue)-iPhone13Pro-light",
            record: recording,
            file: file,
            line: line
        )
        
        let exp = inspection.inspect(after: animationDuration + 0.01) { view in
            let actualView = try view.actualView()
            
            assertSnapshot(
                of: actualView,
                as: .image(
                    layout: .device(config: .iPhone13Pro),
                    traits: .init(userInterfaceStyle: .light)
                ),
                named: "AfterAnimation-\(state.rawValue)-iPhone13Pro-light",
                record: recording,
                file: file,
                line: line
            )
        }
        
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }
        
        wait(for: [exp], timeout: animationDuration + 0.05)
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
            
            let inspectableView = try sut.inspect()
                .find(viewWithTag: DMLoadingViewOwnSettings.tapGestureViewTag)
            
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
    
    func checkAutoHideBehavior_For_States(_ states: [DMLoadableType],
                                          secondsAutoHideDelay: Double,
                                          file: StaticString = #filePath,
                                          line: UInt = #line) throws {
        // Given
        try states.forEach { state in
            let settings = StubDMLoadingManagerSettings(autoHideDelay: .seconds(secondsAutoHideDelay))
            let loadingManager = DMLoadingManagerMain(
                state: state,
                settings: settings
            )
            
            // When
            let sut = makeSUT(manager: loadingManager)
            
            let inspection = try XCTUnwrap(
                sut.inspection,
                "Inspection should be available in debug mode"
            )
            
            // Then
            let exp = inspection.inspect(after: secondsAutoHideDelay + 0.01) { view in
                let actualView = try view.actualView()
                
                XCTAssertEqual(actualView
                    .loadingManager
                    .loadableState,
                               .none,
                               "Loading state should be `.none` after the auto-hide delay for given state: `\(state.rawValue)`",
                               file: file,
                               line: line)
            }
            
            ViewHosting.host(view: sut)
            defer { ViewHosting.expel() }
            
            wait(for: [exp], timeout: secondsAutoHideDelay + 0.02)
        }
    }
    
}
