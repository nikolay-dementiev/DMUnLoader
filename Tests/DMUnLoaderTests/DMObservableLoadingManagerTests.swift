//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import Combine
import Observation
import XCTest
import os
import DMUnLoader

/// The Observation view of a loading manager. The manager stays the one owner of the state, so every
/// test changes the manager, or the facade, and reads what the other one shows. The auto-hide runs on a
/// spy, so no test waits for a clock.
@MainActor
final class DMObservableLoadingManagerTests: XCTestCase {

    // MARK: - Tracking

    func test_observableFacade_stateChange_updatesTrackedState() {
        let (sut, manager) = makeSUT()
        let changed = OSAllocatedUnfairLock(initialState: false)
        withObservationTracking {
            _ = sut.loadableState
        } onChange: {
            changed.withLock { $0 = true }
        }

        manager.showLoading(provider: provider)

        XCTAssertTrue(
            changed.withLock { $0 },
            "a change of the state of the manager notifies who tracked the state of the facade"
        )
        XCTAssertEqual(sut.loadableState, loading, "the facade shows the state that the manager has")
    }

    func test_observableFacade_hide_changesUnderlyingManagerOnce() {
        let (sut, manager) = makeSUT()
        sut.showFailure(DMAppError.custom("Lost"), provider: provider)
        XCTAssertEqual(sut.loadableState, failure, "the facade shows the failure that the manager has")
        var emitted: [DMLoadableType] = []
        let subscription = manager.$loadableState.dropFirst().sink { emitted.append($0) }

        sut.hide()

        XCTAssertEqual(manager.loadableState, DMLoadableType.none, "hide resets the manager to none")
        XCTAssertEqual(emitted, [DMLoadableType.none], "the manager publishes exactly one change for one hide")
        XCTAssertEqual(sut.loadableState, DMLoadableType.none, "the facade shows the state that the manager has")
        subscription.cancel()
    }

    /// The first assertion is the premise of the facade: it fails when a system publishes the new value
    /// of `@Published` after the property has changed, and then the facade may read the manager instead.
    func test_observationBridge_publishedWillSet_usesEmittedState() {
        let (sut, manager) = makeSUT()
        var managerWhilePublishing: [DMLoadableType] = []
        let subscription = manager.$loadableState.dropFirst().sink { _ in
            managerWhilePublishing.append(manager.loadableState)
        }

        manager.showLoading(provider: provider)

        XCTAssertEqual(
            managerWhilePublishing,
            [DMLoadableType.none],
            "premise: the manager still has the previous state while its publisher publishes the new one"
        )
        XCTAssertEqual(sut.loadableState, loading, "the facade holds the state that was emitted, not the one it read")
        subscription.cancel()
    }

    // MARK: - Start and auto-hide

    func test_observableFacade_init_startsInTheStateOfTheManager() {
        let (sut, _) = makeSUT(state: loading)

        XCTAssertEqual(sut.loadableState, loading, "a facade made over a manager that shows a state shows it too")
    }

    func test_observableFacade_autoHide_followsTheManager() throws {
        let scheduler = AutoHideSchedulerSpy()
        let (sut, _) = makeSUT(state: success, scheduler: scheduler)
        XCTAssertEqual(sut.loadableState, success, "the facade starts with the success of the manager")

        try XCTUnwrap(scheduler.scheduled.first, "the manager scheduled the hide of its success").runHide()

        XCTAssertEqual(sut.loadableState, DMLoadableType.none, "the auto-hide of the manager reaches the facade")
    }

    func test_observableFacade_twoFacadesOverOneManager_bothFollow() {
        let (first, manager) = makeSUT()
        let second = DMObservableLoadingManager(manager: manager)
        trackForMemoryLeaks(second)

        manager.showLoading(provider: provider)

        XCTAssertEqual(first.loadableState, loading, "the first facade shows the state of the manager")
        XCTAssertEqual(second.loadableState, loading, "the second facade shows it too")
    }

    func test_observableFacade_equalStateOfAnotherInstance_holdsTheNewInstance() throws {
        let (sut, manager) = makeSUT()
        manager.showFailure(InstanceError(id: 1), provider: provider)
        let first = manager.loadableState

        manager.showFailure(InstanceError(id: 2), provider: provider)

        XCTAssertEqual(first, manager.loadableState, "premise: the two failures compare equal, they differ in the instance")
        guard case let .failure(error, _, _) = sut.loadableState else {
            return XCTFail("the facade shows a failure: \(sut.loadableState)")
        }
        let held = try XCTUnwrap(error as? InstanceError, "the facade holds the error that was given")
        XCTAssertEqual(held.id, 2, "the facade holds the instance that the manager has, not the equal one it had")
    }

    // MARK: - Forwarding

    func test_observableFacade_operations_forwardToTheManagerWithTheSameArguments() {
        let (sut, manager) = makeSUT()
        let retry = DMButtonAction {}

        sut.showLoading(provider: provider)
        XCTAssertEqual(manager.loadableState, loading, "showLoading shows the loading state of the provider it was given")

        sut.showSuccess("Saved", provider: provider)
        XCTAssertEqual(manager.loadableState, success, "showSuccess shows the message it was given")

        sut.showFailure(DMAppError.custom("Lost"), provider: provider, onRetry: retry)
        XCTAssertEqual(
            manager.loadableState,
            .failure(error: DMAppError.custom("Lost"), provider: erasedProvider, onRetry: retry),
            "showFailure passes the retry action it was given"
        )

        sut.showFailure(DMAppError.custom("Lost"), provider: provider)
        XCTAssertEqual(manager.loadableState, failure, "showFailure with no retry action gives a failure without one")
    }

    // MARK: - Lifetime

    func test_observableFacade_released_isDeallocatedAndLeavesTheManagerWorking() {
        let (_, manager) = makeSUT()
        weak var weakSUT: DMObservableLoadingManager?
        do {
            let sut = DMObservableLoadingManager(manager: manager)
            weakSUT = sut
        }

        XCTAssertNil(weakSUT, "nothing keeps the facade alive once its owner lets it go")
        manager.showLoading(provider: provider)
        XCTAssertEqual(manager.loadableState, loading, "the manager goes on working without the facade")
    }

    func test_observableFacade_holdsTheManager_untilReleased() {
        weak var weakManager: DMLoadingManagerMain?
        var sut: DMObservableLoadingManager?
        do {
            let manager = DMLoadingManagerMain(state: .none, settings: DMLoadingManagerDefaultSettings())
            weakManager = manager
            sut = DMObservableLoadingManager(manager: manager)
        }

        withExtendedLifetime(sut) {
            XCTAssertNotNil(weakManager, "the facade keeps the manager it wraps alive")
        }
        sut = nil
        XCTAssertNil(weakManager, "the manager goes away with the last one that holds it")
    }

    // MARK: - Helpers

    private let provider = DefaultDMLoadingViewProvider()

    private var erasedProvider: AnyDMLoadingViewProvider {
        provider.eraseToAnyViewProvider()
    }

    private var loading: DMLoadableType {
        .loading(provider: erasedProvider)
    }

    private var success: DMLoadableType {
        .success("Saved", provider: erasedProvider)
    }

    private var failure: DMLoadableType {
        .failure(error: DMAppError.custom("Lost"), provider: erasedProvider)
    }

    private func makeSUT(
        state: DMLoadableType = .none,
        scheduler: AutoHideSchedulerSpy = AutoHideSchedulerSpy(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: DMObservableLoadingManager, manager: DMLoadingManagerMain) {
        let manager = DMLoadingManagerMain(
            state: state,
            settings: DMLoadingManagerDefaultSettings(),
            autoHideScheduler: scheduler
        )
        let sut = DMObservableLoadingManager(manager: manager)
        trackForMemoryLeaks(manager, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, manager)
    }
}

/// An error whose description is the same for every instance, so two failures made with it compare equal
/// by `DMLoadableType` and differ only in the instance.
private final class InstanceError: Error, CustomStringConvertible {
    let id: Int

    init(id: Int) {
        self.id = id
    }

    var description: String {
        "Lost"
    }
}
