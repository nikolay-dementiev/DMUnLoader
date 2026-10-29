//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import ViewInspector
import XCTest
import DMUnLoader

/// The Observation view of a loading manager in a real SwiftUI view, hosted in a window: the view that
/// reads the state of the facade is evaluated again when the manager changes it. The package tests of
/// the facade track the property by hand; this is the proof that SwiftUI does the same.
@MainActor
final class DMObservableLoadingManagerHostedTests: XCTestCase {

    func test_observableFacade_swiftUIView_isEvaluatedAgainWhenTheStateChanges() {
        let (sut, manager) = makeSUT()
        let probe = RenderProbe()
        ViewHosting.host(view: StateReadingView(facade: sut, probe: probe))
        defer { ViewHosting.expel() }
        waitUntil(!probe.states.isEmpty)
        XCTAssertEqual(
            probe.states.first,
            DMLoadableType.none.rawValue,
            "the view first reads the state that the manager has"
        )

        manager.showLoading(provider: provider)
        waitUntil(probe.states.last == loading.rawValue)

        XCTAssertEqual(probe.states.last, loading.rawValue, "the view is evaluated again and reads the new state")
    }

    // MARK: - Helpers

    private let provider = DefaultDMLoadingViewProvider()

    private var loading: DMLoadableType {
        .loading(provider: provider.eraseToAnyViewProvider())
    }

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: DMObservableLoadingManager, manager: DMLoadingManagerMain) {
        let manager = DMLoadingManagerMain(
            state: .none,
            settings: DMLoadingManagerDefaultSettings(),
            autoHideScheduler: AutoHideSchedulerSpy()
        )
        let sut = DMObservableLoadingManager(manager: manager)
        trackForMemoryLeaks(manager, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, manager)
    }

    private func waitUntil(_ condition: @autoclosure () -> Bool) {
        let deadline = Date().addingTimeInterval(TestTiming.callbackAllowance)
        while !condition(), Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.02))
        }
    }
}

/// Records the state that the view read each time it was evaluated.
@MainActor
private final class RenderProbe {
    private(set) var states: [String] = []

    func record(_ state: DMLoadableType) {
        states.append(state.rawValue)
    }
}

private struct StateReadingView: View {
    let facade: DMObservableLoadingManager
    let probe: RenderProbe

    var body: some View {
        probe.record(facade.loadableState)
        return Text(verbatim: facade.loadableState.rawValue)
    }
}
