//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import UIKit
import XCTest
import DMUnLoader

/// The views of the HUD read Reduce Motion and Reduce Transparency from values of their own,
/// which the HUD's window takes from the system's settings.
///
/// SwiftUI reports a settable twin of each setting through the system's value (measured on
/// iOS 17.5, 18.6 and 26.5), so a rendered view stands in for a device with the setting on.
@MainActor
final class SystemAccessibilitySettingsTests: XCTestCase {

    func test_systemSettings_reduceMotionOnly_reachTheHUDAsReduceMotionOnly() {
        let reading = render(reduceMotion: true, reduceTransparency: false)

        XCTAssertEqual(reading.reducesMotion, true, "Reduce Motion reaches the HUD's views")
        XCTAssertEqual(reading.reducesTransparency, false, "Reduce Transparency stays off for the HUD's views")
    }

    func test_systemSettings_reduceTransparencyOnly_reachTheHUDAsReduceTransparencyOnly() {
        let reading = render(reduceMotion: false, reduceTransparency: true)

        XCTAssertEqual(reading.reducesMotion, false, "Reduce Motion stays off for the HUD's views")
        XCTAssertEqual(reading.reducesTransparency, true, "Reduce Transparency reaches the HUD's views")
    }

    // MARK: - Helpers

    private final class Reading {
        var reducesMotion: Bool?
        var reducesTransparency: Bool?
    }

    private struct HUDValuesReader: View {
        @Environment(\.hudReducesMotion) private var reducesMotion
        @Environment(\.hudReducesTransparency) private var reducesTransparency
        let reading: Reading

        var body: some View {
            Color.clear.onAppear {
                reading.reducesMotion = reducesMotion
                reading.reducesTransparency = reducesTransparency
            }
        }
    }

    /// What a view under the system settings reads, with the two settings as given. The
    /// window belongs to no scene: SwiftUI still evaluates the view and calls `onAppear`.
    private func render(reduceMotion: Bool, reduceTransparency: Bool) -> Reading {
        let reading = Reading()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.rootViewController = UIHostingController(
            rootView: HUDValuesReader(reading: reading)
                .modifier(SystemAccessibilitySettings())
                .environment(\._accessibilityReduceMotion, reduceMotion)
                .environment(\._accessibilityReduceTransparency, reduceTransparency)
        )
        window.isHidden = false
        defer { window.isHidden = true }
        let deadline = Date().addingTimeInterval(5)
        while reading.reducesMotion == nil, Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        return reading
    }
}
