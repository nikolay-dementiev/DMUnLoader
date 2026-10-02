//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import UIKit
import XCTest
import DMUnLoader

/// UIKit posts `UIScene.didDisconnectNotification` with the scene that disconnected as the
/// notification's object (Apple: "The object of the notification is the UIScene object").
/// The tests post it to a private center, with a stand-in object for the scene.
@MainActor
final class SceneDisconnectObserverTests: XCTestCase {

    func test_disconnect_ofTheObservedScene_callsBack() {
        let (sut, center, scene, calls) = makeSUT()

        center.post(name: UIScene.didDisconnectNotification, object: scene)

        XCTAssertEqual(calls.count, 1, "the disconnect of the observed scene is reported")
        withExtendedLifetime(sut) {}
    }

    func test_disconnect_ofAnotherScene_doesNotCallBack() {
        let (sut, center, scene, calls) = makeSUT()
        // The observed scene stays alive: a new object could otherwise take its address,
        // and a notification center compares objects by address.
        let anotherScene = NSObject()

        center.post(name: UIScene.didDisconnectNotification, object: anotherScene)

        XCTAssertEqual(calls.count, 0, "another scene's disconnect is not this scene's")
        withExtendedLifetime((sut, scene)) {}
    }

    func test_otherNotification_ofTheObservedScene_doesNotCallBack() {
        let (sut, center, scene, calls) = makeSUT()

        center.post(name: UIScene.didEnterBackgroundNotification, object: scene)

        XCTAssertEqual(calls.count, 0, "a scene that only enters the background is still connected")
        withExtendedLifetime(sut) {}
    }

    func test_disconnect_afterTheObserverIsReleased_doesNotCallBack() {
        let center = NotificationCenter()
        let scene = NSObject()
        let calls = CallCounter()
        _ = SceneDisconnectObserver(scene: scene, notificationCenter: center) {
            calls.count += 1
        }

        center.post(name: UIScene.didDisconnectNotification, object: scene)

        XCTAssertEqual(calls.count, 0, "the registration goes away with the observer")
    }

    // MARK: - Helpers

    @MainActor
    private final class CallCounter {
        var count = 0
    }

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: SceneDisconnectObserver, center: NotificationCenter, scene: NSObject, calls: CallCounter) {
        let center = NotificationCenter()
        let scene = NSObject()
        let calls = CallCounter()
        let sut = SceneDisconnectObserver(scene: scene, notificationCenter: center) {
            calls.count += 1
        }
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, center, scene, calls)
    }
}
