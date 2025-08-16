//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader

import PreviewSnapshots
import PreviewSnapshotsTesting

@MainActor
final class DmProgressViewSnapshotTests: XCTestCase {
    override func invokeTest() {
        withSnapshotTesting(record: .failed, diffTool: .ksdiff) {
            super.invokeTest()
        }
    }
    
    func test_progressView_VerifyDefaultInitialization() {
        let snapshots = DMProgressView_Previews.snapshots
        
        expect(
            snapshots,
            named: frameworkName,
            record: false
        )
    }
    
    // MARK: HELPER
    
    func expect<State>(
        _ snapshot: PreviewSnapshots<State>,
        named name: String? = nil,
        record recording: Bool = false,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) {
        snapshot.assertSnapshots(as: ["iPhone13-Light": .testStrategyiPhone13Light,
                                      "iPhone13-Dark": .testStrategyiPhone13Dark],
                                 named: name,
                                 record: recording,
                                 file: file,
                                 testName: testName,
                                 line: line)
    }
}
