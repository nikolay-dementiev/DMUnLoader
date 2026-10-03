//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMUnLoader

/// A scene that records the presenters it makes, and disconnects when a test says so.
///
/// The live scene reports its disconnect through `SceneDisconnectObserver`, which calls back
/// for `UIScene.didDisconnectNotification` of that scene only, and only while the observer
/// lives (`SceneDisconnectObserverTests`). The spy keeps the same rule for one observation.
@MainActor
final class HUDSceneSpy: HUDScene {
    private(set) var presenters: [HUDOverlayPresenterSpy] = []
    private weak var observation: Observation?

    func makeHUDPresenter() -> any HUDOverlayPresenting {
        let presenter = HUDOverlayPresenterSpy()
        presenters.append(presenter)
        return presenter
    }

    func observeDisconnect(_ onDisconnect: @escaping @MainActor () -> Void) -> AnyObject {
        let observation = Observation(onDisconnect: onDisconnect)
        self.observation = observation
        return observation
    }

    /// The scene disconnects: the observation that is still kept is told.
    func disconnect() {
        observation?.onDisconnect()
    }

    /// The managers presented over this scene, in order, by every presenter it made.
    var presented: [ObjectIdentifier] {
        presenters.flatMap { $0.presented.map(ObjectIdentifier.init) }
    }

    /// How many times the presenters of this scene removed a HUD.
    var dismissCount: Int {
        presenters.map(\.dismissCount).reduce(0, +)
    }

    private final class Observation {
        let onDisconnect: @MainActor () -> Void

        init(onDisconnect: @escaping @MainActor () -> Void) {
            self.onDisconnect = onDisconnect
        }
    }
}
