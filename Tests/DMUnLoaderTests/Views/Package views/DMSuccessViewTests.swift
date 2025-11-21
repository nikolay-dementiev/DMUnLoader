//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import SwiftUI
import ViewInspector
import SnapshotTesting

@MainActor
final class DMSuccessViewTests: XCTestCase {
    
    override func invokeTest() {
        withSnapshotTesting(
            record: .missing,
            diffTool: .ksdiff
        ) {
            super.invokeTest()
        }
    }

    // MARK: Scenario 1: Verify Default Initialization
    
    func testDefaultInitialization() {
        let settings = DMSuccessDefaultViewSettings()
        let sut = makeSUT(settings: settings)
        
        XCTAssertNotNil(sut.settingsProvider,
                        "The settingsProvider should be initialized")
    }
    
    func testImageRenderedCorrectlyDuringDefaultInitialization() throws {
        let settings = DMSuccessDefaultViewSettings()
        let sut = makeSUT(settings: settings)
        
        let image = try sut
            .inspect()
            .find(viewWithTag: DMSuccessViewOwnSettings.imageTag)
            .image()

        try sutImageNameConfirmToExpectedImage(
            sutImage: image,
            expectedImage: settings.successImageProperties.image,
            expectedImageName: "checkmark.circle.fill"
        )
    }
    
    func testTextRenderedCorrectlyDuringDefaultInitialization() throws {
        let settings = DMSuccessDefaultViewSettings()
        let sut = makeSUT(settings: settings)
        
        let text = try sut
            .inspect()
            .find(viewWithTag: DMSuccessViewOwnSettings.textTag)
            .text()
        
        XCTAssertNotNil(text,
                        "The TextView should be rendered")

        let textFormSUT = try? text.string()
        XCTAssertEqual(textFormSUT,
                       settings.successTextProperties.text,
                       "The default success text should match the settings")
        XCTAssertEqual(textFormSUT,
                       "Success!",
                       "The default success text should match the settings")
    }
    
    // MARK: Scenario 2: Verify Success Image Behavior
    
    func testCustomSuccessImageRendering() throws {
        let settings = DMSuccessDefaultViewSettings(
            successImageProperties: .init(
                image: Image(systemName: "star.fill"),
                frame: CustomViewSize(width: 60, height: 60),
                foregroundColor: .yellow
            )
        )
        let sut = makeSUT(settings: settings)
        
        let image = try sut
            .inspect()
            .find(viewWithTag: DMSuccessViewOwnSettings.imageTag)
            .image()
        
        try sutImageNameConfirmToExpectedImage(
            sutImage: image,
            expectedImage: settings.successImageProperties.image,
            expectedImageName: "star.fill"
        )
        
        try sutImageForegroundColorConfirmToExpectedColor(
            sutImage: image,
            expectedForegroundColorInSettings: settings.successImageProperties.foregroundColor,
            expectedForegroundColor: .yellow
        )
        
        try sutImageFrameSizeConfirmToExpectedsize(
            sutImage: image,
            expectedSizeInSettings: settings.successImageProperties.frame,
            expectedSize: CustomViewSize(width: 60, height: 60)
        )
        
        try sutImageResizableParametersConfirmToExpectedDefault(sutImage: image)
    }
    
    private func sutImageForegroundColorConfirmToExpectedColor(
        sutImage: InspectableView<ViewType.Image>,
        expectedForegroundColorInSettings: Color?,
        expectedForegroundColor: Color,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let imageForegroundColorFormSUT = try sutImage.foregroundColor()
        
        XCTAssertEqual(
            imageForegroundColorFormSUT,
            expectedForegroundColorInSettings,
            "Success image foreground color should match the settings",
            file: file,
            line: line
        )
        XCTAssertEqual(
            imageForegroundColorFormSUT,
            expectedForegroundColor,
            "Success image foreground color should be \(expectedForegroundColor)",
            file: file,
            line: line
        )
    }
    
    private func sutImageFrameSizeConfirmToExpectedsize(
        sutImage: InspectableView<ViewType.Image>,
        expectedSizeInSettings: CustomViewSize,
        expectedSize: CustomViewSize,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let fixedImageFrame = try sutImage.fixedFrame()
        
        [
            "Settings size": expectedSizeInSettings,
            "Expected size": expectedSize
        ]
            .forEach { key, value in
                XCTAssertEqual(
                    fixedImageFrame.width,
                    value.width,
                    "The ImageView `\(key)` frame should have the correct frame width",
                    file: file,
                    line: line
                )
                XCTAssertEqual(fixedImageFrame.height,
                               value.height,
                               "The ImageView `\(key)` height should have the correct frame height",
                               file: file,
                               line: line)
                XCTAssertEqual(fixedImageFrame.alignment,
                               value.alignment,
                               "The ImageView `\(key)` frame should have the correct frame alignment",
                               file: file,
                               line: line)
            }
    }
    
    private func sutImageResizableParametersConfirmToExpectedDefault(
        sutImage: InspectableView<ViewType.Image>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let resizableParameters = try sutImage.actualImage().resizableParameters()
        XCTAssertEqual(
            resizableParameters.capInsets,
            EdgeInsets(),
            "The resizable image capInsets should be equal to EdgeInsets()",
            file: file,
            line: line
        )
        XCTAssertEqual(
            resizableParameters.resizingMode,
            .stretch,
            "The resizable image resizingMode should be .stretch",
            file: file,
            line: line
        )
    }
    
    // MARK: Scenario 3: Verify Success Text Behavior
    
    func testCustomSuccessTextRendering() throws {
        let expectedText = "Operation Completed!"
        let expectedForegroundColor = Color.green
        let settings = DMSuccessDefaultViewSettings(
            successTextProperties: .init(
                text: expectedText,
                foregroundColor: expectedForegroundColor
            )
        )
        let sut = makeSUT(settings: settings)
        
        let text = try sut
            .inspect()
            .find(viewWithTag: DMSuccessViewOwnSettings.textTag)
            .text()
        
        XCTAssertEqual(
            try text.string(),
            expectedText,
            "The custom success text should match the `\(expectedText)`"
        )
        
        XCTAssertEqual(
            try text.attributes().foregroundColor(),
            expectedForegroundColor,
            "The custom success text foreground color should be `\(expectedForegroundColor)`"
        )
    }
    
    func testCustomSuccessTextRederedAssosiatedObject() throws {
        let expectedText = "Operation Completed!"
        let sut = makeSUT(
            settings: DMSuccessDefaultViewSettings(),
            assosiatedObject: MockDMLoadableTypeSuccess(description: expectedText)
        )
        
        let text = try sut
            .inspect()
            .find(viewWithTag: DMSuccessViewOwnSettings.textTag)
            .text()
        
        XCTAssertEqual(
            try text.string(),
            expectedText,
            "The custom success text should match the `\(expectedText)`"
        )
    }
    
    // MARK: Scenario 4: Verify Layout and Alignment
    
    func testThatTheImageVerticallyAligned() throws {
        let sut = makeSUT(settings: DMSuccessDefaultViewSettings())
        
        let image = try sut
            .inspect()
            .find(viewWithTag: DMSuccessViewOwnSettings.imageTag)
            .image()
        
        XCTAssertEqual(
            try image.fixedAlignment(),
            .center,
            "The ImageView should be center aligned"
        )
    }
    
    func testThatTheTextVerticallyAligned() throws {
        let sut = makeSUT(settings: DMSuccessDefaultViewSettings())
        
        let text = try sut
            .inspect()
            .find(viewWithTag: DMSuccessViewOwnSettings.textTag)
            .text()
        
        XCTAssertEqual(
            try text.fixedAlignment(),
            .center,
            "The TextView should be center aligned"
        )
    }
    
    func testRendersImageFrame() throws {
        let settings = DMSuccessDefaultViewSettings()
        let sut = makeSUT(settings: settings)
        
        let imageView = try sut
            .inspect()
            .find(viewWithTag: DMSuccessViewOwnSettings.imageTag)
            .image()
        
        let fixedImageFrame = try? imageView.fixedFrame()
        let successImageProperties = settings.successImageProperties
        
        XCTAssertEqual(fixedImageFrame?.width,
                       successImageProperties.frame.width,
                       "The ImageView frame should have the correct frame width")
        XCTAssertEqual(fixedImageFrame?.height,
                       successImageProperties.frame.height,
                       "The ImageView height should have the correct frame height")
        XCTAssertEqual(fixedImageFrame?.alignment,
                       successImageProperties.frame.alignment,
                       "The ImageView frame should have the correct frame alignment")
    }
    
    func testSpacingBetweenTheImageAndTextIsConsistent() throws {
        let expectedSpacing: CGFloat = 15.0
        let settings = DMSuccessDefaultViewSettings(
            spacingBetweenElements: expectedSpacing
        )
        let sut = makeSUT(settings: settings)
        
        let containerView = try sut
            .inspect()
            .find(viewWithTag: DMSuccessViewOwnSettings.containerViewTag)
            .vStack()
        
        XCTAssertEqual(
            try containerView.spacing(),
            expectedSpacing,
            "The spacing between image and text should be `\(expectedSpacing)`"
        )
    }
    
    // MARK: Scenario 5: Verify Snapshot Testing
    
    func testSnapshotDefaultSuccessView() async throws {
        let settings = DMSuccessDefaultViewSettings()
        let sut = makeSUTWithContainer(settings: settings)
        
        assertSnapshot(
            of: sut,
            as: .image(
                layout: .device(config: .iPhone13Pro),
                traits: .init(userInterfaceStyle: .dark)
            ),
            named: "iPhone13Pro-dark"
        )
        
        assertSnapshot(
            of: sut,
            as: .image(
                layout: .device(config: .iPhone13Pro),
                traits: .init(userInterfaceStyle: .light)
            ),
            named: "iPhone13Pro-light"
        )
    }
    
    func testSnapshotCustomSuccessView() async throws {
        let settings = DMSuccessDefaultViewSettings(
            successImageProperties: .init(
                image: Image(systemName: "star.fill"),
                frame: CustomViewSize(width: 61, height: 70),
                foregroundColor: .cyan
            ),
            successTextProperties: .init(
                text: "Operation Completed!",
                foregroundColor: .pink
            ),
            spacingBetweenElements: 22.2
        )
        
        let sut = makeSUTWithContainer(
            settings: settings,
            assosiatedObject: MockDMLoadableTypeSuccess(description: "All tasks finished successfully.")
        )
        
        assertSnapshot(
            of: sut,
            as: .image(
                layout: .device(config: .iPhone13Pro),
                traits: .init(userInterfaceStyle: .dark)
            ),
            named: "iPhone13Pro-dark"
        )
        
        assertSnapshot(
            of: sut,
            as: .image(
                layout: .device(config: .iPhone13Pro),
                traits: .init(userInterfaceStyle: .light)
            ),
            named: "iPhone13Pro-light"
        )
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        settings: DMSuccessViewSettings,
        assosiatedObject: DMLoadableTypeSuccess? = nil
    ) -> DMSuccessView {
        let sut = DMSuccessView(
            settings: settings,
            assosiatedObject: assosiatedObject
        )
        
        return sut
    }
    
    private func makeSUTWithContainer(
        settings: DMSuccessViewSettings,
        assosiatedObject: DMLoadableTypeSuccess? = nil
    ) -> LoadingViewContainer<DMSuccessView> {
        LoadingViewContainer {
            DMSuccessView(
                settings: settings,
                assosiatedObject: assosiatedObject
            )
        }
    }
}
