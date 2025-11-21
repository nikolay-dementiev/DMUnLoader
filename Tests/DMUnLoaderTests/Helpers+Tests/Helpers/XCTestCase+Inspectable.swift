//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import ViewInspector
import SwiftUI

extension XCTestCase {
    func sutImageNameConfirmToExpectedImage(
        sutImage: InspectableView<ViewType.Image>,
        expectedImage: Image,
        expectedImageName: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let imageFormSUT = try sutImage.actualImage().name()
        
        XCTAssertEqual(
            imageFormSUT,
            try expectedImage.name(),
            "`\(Self.self)`: The custom image should match the settings",
            file: file,
            line: line
        )
        XCTAssertEqual(
            imageFormSUT,
            expectedImageName,
            "`\(Self.self)`: The custom image should be '\(expectedImageName)'",
            file: file,
            line: line
        )
    }
}
