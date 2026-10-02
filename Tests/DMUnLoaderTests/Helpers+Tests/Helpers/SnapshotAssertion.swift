//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SnapshotTesting
import SwiftUI
import XCTest

/// How every image snapshot of this suite is named, compared and recorded.
enum SnapshotSettings {

    /// The share of pixels that has to match: all of them. A missing button, a changed word
    /// or a clipped line changes a small share of a full-screen image, so a lower value
    /// lets each of them pass. On the GPU path the library reads the failing share back as
    /// a 16-bit float, so a few failing pixels may not count; each of those defects changes
    /// thousands.
    static let precision: Float = 1

    /// How close one pixel has to be to its reference, where 1 is identical. It absorbs the
    /// anti-aliasing noise between two renderings of the same view, and nothing a person
    /// could see.
    static let perceptualPrecision: Float = 0.98

    /// A missing reference is recorded on a developer's machine, and the test fails once.
    /// With `CI` set nothing is ever written: a missing reference is a failure. With
    /// `SNAPSHOT_TESTING_RECORD` set, the library's own record mode applies, so references
    /// can be re-recorded on purpose. A test runner in the simulator sees a variable that
    /// `xcodebuild` passes as `TEST_RUNNER_<name>`.
    static var record: SnapshotTestingConfiguration.Record? {
        let environment = ProcessInfo.processInfo.environment
        if environment["SNAPSHOT_TESTING_RECORD"] != nil {
            return nil
        }
        return environment["CI"] == nil ? .missing : .never
    }

    /// Rendering differs between OS versions, so every version has its own references.
    static var osSuffix: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "_ios\(version.majorVersion)_\(version.minorVersion)"
    }
}

/// Compares a view with its recorded image. Every image snapshot of the suite goes through
/// this function, so the name, the tolerance and the record mode are decided in one place.
@MainActor
func assertImageSnapshot<Content: View>(
    of view: @autoclosure () -> Content,
    layout: SwiftUISnapshotLayout = .device(config: .iPhone13Pro),
    style: UIUserInterfaceStyle,
    named name: String,
    file: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line
) {
    withSnapshotTesting(record: SnapshotSettings.record) {
        assertSnapshot(
            of: view(),
            as: .image(
                precision: SnapshotSettings.precision,
                perceptualPrecision: SnapshotSettings.perceptualPrecision,
                layout: layout,
                traits: .init(userInterfaceStyle: style)
            ),
            named: name + SnapshotSettings.osSuffix,
            file: file,
            testName: testName,
            line: line
        )
    }
}
