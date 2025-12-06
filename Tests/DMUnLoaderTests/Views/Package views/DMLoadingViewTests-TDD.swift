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

struct DMLoadingView_TDD<LLM: DMLoadingManager>: View {
    @ObservedObject private(set) var loadingManager: LLM
    @State private var animateTheAppearance = false
    
#if DEBUG
    let inspection: Inspection<Self>? = getInspectionIfAvailable()
#endif
    
    init(loadingManager: LLM) {
        self.loadingManager = loadingManager
    }
    
    var body: some View {
        ZStack {
            let loadableState = loadingManager.loadableState
            switch loadableState {
            case .none:
                EmptyView()
                    .tag(DMLoadingViewOwnSettings.emptyViewTag)
            case .loading(let provider):
                provider.getLoadingView()
                    .scaleEffect(animateTheAppearance ? 1 : 0.9)
                    .tag(DMLoadingViewOwnSettings.loadingViewTag)
            case let .failure(error, provider, onRetry):
                provider.getErrorView(
                    error: error,
                    onRetry: onRetry,
                    onClose: DMButtonAction(loadingManager.hide)
                )
                .tag(DMLoadingViewOwnSettings.failureViewTag)
            default:
                EmptyView()
            }
        }
        .transition(.opacity)
        .animation(.easeInOut, value: loadingManager.loadableState)
        .onAppear {
            animateTheAppearance.toggle()
        }
        .animation(Animation.spring(duration: 0.2),
                   value: animateTheAppearance)
#if DEBUG
        .onReceive(inspection?.notice ?? EmptyPublisher().notice) { [weak inspection] in
            inspection?.visit(self, $0)
        }
#endif
    }
}

@MainActor
final class DMLoadingViewTests_TDD: XCTestCase {
    
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
                named: "View-LoadingState-iPhone13Pro-light",
                record: false
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
    
    func testLoadingView_TheOverlayAnimatesSmoothly_IntoView() throws {
        // Given
        let provider = StubDMLoadingViewProvider()
        let loadingManager = StubDMLoadingManager(
            loadableState: .loading(
                provider: provider.eraseToAnyViewProvider()
            )
        )
        let animationDuration: Double = 0.2
        
        // When
        let sut = makeSUT(manager: loadingManager)
        
        let inspection = try XCTUnwrap(
            sut.inspection,
            "Inspection should be available in debug mode"
        )
        
        // Then
        assertSnapshot(
            of: sut,
            as: .image(
                layout: .device(config: .iPhone13Pro),
                traits: .init(userInterfaceStyle: .light)
            ),
            named: "BeforeAnimation-iPhone13Pro-light",
            record: false
        )
        
        let exp = inspection.inspect(after: animationDuration + 0.01) { view in
            let actualView = try view.actualView()
            
            assertSnapshot(
                of: actualView,
                as: .image(
                    layout: .device(config: .iPhone13Pro),
                    traits: .init(userInterfaceStyle: .light)
                ),
                named: "AfterAnimation-iPhone13Pro-light",
                record: false
            )
        }
        
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }
        wait(for: [exp], timeout: animationDuration + 0.05)
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
                named: "View-FailureState-iPhone13Pro-light",
                record: false
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
    
    // MARK: - Helpers
    
    private func makeSUT<LM: DMLoadingManager>(manager loadingManager: LM) -> DMLoadingView_TDD<LM> {
        
        let sut = DMLoadingView_TDD(loadingManager: loadingManager)
        
        trackForMemoryLeaks(loadingManager)
        
        return sut
    }
    
}
