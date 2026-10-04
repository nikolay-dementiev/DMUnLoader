//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SnapshotTesting
import XCTest

/// The record mode of the image snapshots for each combination of the two variables that
/// decide it. The CI variable outranks the record variable, so a run on CI never writes a
/// reference, whatever the record variable says.
final class SnapshotRecordModeTests: XCTestCase {

    func test_recordMode_withCI_neverWritesWhateverTheRecordVariableSays() {
        for value in Self.recordValues {
            XCTAssertEqual(
                SnapshotSettings.record(in: ["CI": "true", "SNAPSHOT_TESTING_RECORD": value]),
                .never,
                "with CI set, SNAPSHOT_TESTING_RECORD=\(value) writes no reference"
            )
        }
    }

    func test_recordMode_withCIAndNoRecordVariable_neverWrites() {
        XCTAssertEqual(
            SnapshotSettings.record(in: ["CI": "true"]),
            .never,
            "with CI set, a missing reference fails and is never written"
        )
    }

    func test_recordMode_withoutCI_leavesTheModeToTheLibrary() {
        for value in Self.recordValues {
            XCTAssertNil(
                SnapshotSettings.record(in: ["SNAPSHOT_TESTING_RECORD": value]),
                "without CI, SNAPSHOT_TESTING_RECORD=\(value) is the library's to read"
            )
        }
    }

    func test_recordMode_withoutCIOrRecordVariable_recordsOnlyMissingReferences() {
        XCTAssertEqual(
            SnapshotSettings.record(in: [:]),
            .missing,
            "on a developer's machine a missing reference is recorded, and the test fails once"
        )
    }

    private static let recordValues = ["all", "failed", "missing", "never", "once"]
}
