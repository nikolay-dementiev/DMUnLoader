//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import SwiftUI
import ViewInspector
import SnapshotTesting

struct DMProgressViewTDD: View {
    let settingsProvider: DMProgressViewSettings
    
    init(settings settingsProvider: DMProgressViewSettings) {
        self.settingsProvider = settingsProvider
    }
    
    var body: some View {
        let geometry = settingsProvider.frameGeometrySize
        let loadingTextProperties = settingsProvider.loadingTextProperties
        let progressIndicatorProperties = settingsProvider.progressIndicatorProperties
        
        let minSize: CGFloat = 30
        ZStack(alignment: .center) {
            Color(settingsProvider.loadingContainerBackgroundColor)
                .tag(DMProgressViewOwnSettings.containerbackgroundColorViewTag)
            VStack {
                Text(loadingTextProperties.text)
                    .foregroundColor(loadingTextProperties.foregroundColor)
                    .font(loadingTextProperties.font)
                    .lineLimit(loadingTextProperties.lineLimit)
                    .padding(loadingTextProperties.linePadding)
                    .tag(DMProgressViewOwnSettings.textTag)
                
                ProgressView()
                    .controlSize(progressIndicatorProperties.size)
                    .progressViewStyle(progressIndicatorProperties.style)
                    .tint(progressIndicatorProperties.tintColor)
                    .layoutPriority(1)
                    .tag(DMProgressViewOwnSettings.progressViewTag)
            }
        }
        .frame(minWidth: minSize,
               maxWidth: geometry.width / 2,
               minHeight: minSize,
               maxHeight: geometry.height / 2)
        .fixedSize()
        .tag(DMProgressViewOwnSettings.zStackViewTag)
    }
}

final class DMProgressViewTests_TDD: XCTestCase {
    
    override func invokeTest() {
        withSnapshotTesting(
            record: .failed,
            diffTool: .ksdiff
        ) {
            super.invokeTest()
        }
    }
    
    // MARK: Scenario 1: Verify Default Initialization
    
    @MainActor
    func testThatViewConfirmToViewProtocol() {
        let sut = makeSUT()
        XCTAssertTrue((sut as Any) is (any View), "DMProgressView should conform to View protocol")
    }
    
    @MainActor
    func testThatTextIsDisplayed() throws {
        let settings = DMProgressViewDefaultSettings()
        let sut = makeSUT(settings: settings)
        
        let text = try sut
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.textTag)
            .text()
            .string()
        
        XCTAssertEqual(text,
                       settings.loadingTextProperties.text,
                       "The Text view should display the correct text")
        
        XCTAssertEqual(text,
                       "Loading...",
                       "The Text view should display the correct text")
    }
    
    @MainActor
    func testThatProgressIndicatorIsDisplayed() throws {
        let settings = DMProgressViewDefaultSettings()
        let sut = makeSUT(settings: settings)
        
        let progressView = try sut
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.progressViewTag)
            .progressView()
        XCTAssertNotNil(progressView,
                        "The ProgressView should be rendered")
    }
    
    // MARK: Scenario 2: Verify Progress Indicator Behavior
    
    @MainActor
    func testThatProgressIndicatorHasCorrectStyle() throws {
        let settings = DMProgressViewDefaultSettings(
            progressIndicatorProperties: ProgressIndicatorProperties(
                tintColor: .green
            )
        )
        let sut = makeSUT(settings: settings)
        
        let progressView = try sut
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.progressViewTag)
            .progressView()
        
        let progressViewStyle = try? progressView.progressViewStyle() as? CircularProgressViewStyle
        XCTAssertNotNil(progressViewStyle,
                        "The ProgressView should be `CircularProgressViewStyle` type")
        
        let progressViewLayoutPriority = try? progressView.layoutPriority()
        XCTAssertEqual(progressViewLayoutPriority,
                       1,
                       "The ProgressView should have layout priority equal `1`")
        XCTAssertEqual(try progressView.tint(),
                       settings.progressIndicatorProperties.tintColor,
                       "The ProgressView should have the correct tint color")
        
        /* `controlSize` - Not implemented in ViewInspector for iOS
        XCTAssertEqual(try progressView.controlSize(),
                       .regular,
                       "The ProgressView should have the correct control size")
        */
    }
    
    @MainActor
    func testThatProgressIndicatorHasSmallSize() throws {
        let settings = DMProgressViewDefaultSettings(
            progressIndicatorProperties: ProgressIndicatorProperties(
                size: .small
            )
        )
        let sut = makeSUT(settings: settings)
        
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
                layout: .sizeThatFits,
                traits: .init(userInterfaceStyle: .dark)
            ),
            named: "size-that-fits-dark"
        )
    }
    
    // MARK: Scenario 3: Verify Loading Text Behavior
    
    @MainActor
    func testThatLoadingTextHasCorrectStyle() throws {
        let settings = DMProgressViewDefaultSettings(
            loadingTextProperties: .init(
                text: "Please wait...",
                foregroundColor: .red,
                font: .headline,
                lineLimit: 1,
                linePadding: .init(top: 8,
                                   leading: 8,
                                   bottom: 8,
                                   trailing: 8)
            )
        )
        let sut = makeSUT(settings: settings)
        
        let text = try sut
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.textTag)
            .text()
        
        let loadingTextProperties = settings.loadingTextProperties
        XCTAssertEqual(try text.string(),
                       loadingTextProperties.text,
                       "The Text view should display the correct text")
        XCTAssertEqual(try text.attributes().foregroundColor(),
                       loadingTextProperties.foregroundColor,
                       "The Text view should have the correct foreground color")
        XCTAssertEqual(try text.attributes().font(),
                       loadingTextProperties.font,
                       "The Text view should have the correct font")
        XCTAssertEqual(try text.lineLimit(),
                       loadingTextProperties.lineLimit,
                       "The Text view should have the correct line limit")
        XCTAssertEqual(try text.padding(),
                       loadingTextProperties.linePadding,
                       "The Text view should have the correct padding")
    }
    
    // MARK: Scenario 4: Verify Container Appearance
    
    @MainActor
    func testThatContainerHasCorrectForegroundColor() throws {
        let settings = DMProgressViewDefaultSettings(
            loadingContainerBackgroundColor: .blue
        )
        let sut = makeSUT(settings: settings)
        
        let containerBackgroundColor = try sut
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.zStackViewTag)
            .find(viewWithTag: DMProgressViewOwnSettings.containerbackgroundColorViewTag)
            .color()
        
        XCTAssertEqual(try? containerBackgroundColor.value().hashValue,
                       settings.loadingContainerBackgroundColor.hashValue,
                       "The foreground color of the container should match the loading container foreground color")
    }
    
    // MARK: Scenario 5: Verify Geometry and Layout
    
    @MainActor
    func testThatViewAdaptsToDifferentGeometrySizes() throws {
        let settings = DMProgressViewDefaultSettings(
            frameGeometrySize: CGSize(width: 400, height: 400)
        )
        let geometry = settings.frameGeometrySize
        let minSize = min(geometry.width - 20,
                          geometry.height - 20,
                          30)
        
        let sut = makeSUT(settings: settings)
        
        let zStack = try sut
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.zStackViewTag)
            .zStack()
        let flexFrame = try? zStack.flexFrame()
        
        XCTAssertEqual(flexFrame?.minWidth,
                       minSize,
                       "The VStack should have the correct minimum width")
        XCTAssertEqual(flexFrame?.maxWidth,
                       geometry.width / 2,
                       "The VStack should have the correct maximum width")
        XCTAssertEqual(flexFrame?.minHeight,
                       minSize,
                       "The VStack should have the correct minimum height")
        XCTAssertEqual(flexFrame?.maxHeight,
                       geometry.height / 2,
                       "The VStack should have the correct maximum height")
    }
    
    // MARK: Scenario 7: Verify Snapshot Testing
    
    @MainActor
    func testThatViewMatchesSnapshotWithDefaultSettings() {
        let settings = DMProgressViewDefaultSettings()
        let sut = makeSUT(settings: settings)
        
        assertSnapshot(
            of: sut,
            as: .image(
                layout: .device(config: .iPhone13Pro),
                traits: .init(userInterfaceStyle: .dark)
            ),
            named: "iPhone13Pro-dark"
        )
    }
    
    @MainActor
    func testThatViewMatchesSnapshotWithCustomSettings() {
        let settings = DMProgressViewDefaultSettings(
            loadingTextProperties: ProgressTextProperties(
                text: "Wait a bit...\nsecond line...\nthird line...",
                foregroundColor: .yellow,
                font: .title2,
                lineLimit: 2,
                linePadding: EdgeInsets(top: 2, leading: 6, bottom: 3, trailing: 6)
            ),
            progressIndicatorProperties: ProgressIndicatorProperties(
                size: .large,
                tintColor: .orange
            ),
            loadingContainerBackgroundColor: .blue.opacity(0.5),
            frameGeometrySize: CGSize(width: 400, height: 400)
        )
        let sut = makeSUT(settings: settings)
        
        assertSnapshot(
            of: sut,
            as: .image(
                layout: .device(config: .iPhone13Pro),
                traits: .init(userInterfaceStyle: .dark)
            ),
            named: "iPhone13Pro-dark"
        )
    }
    
    // MARK: - Helpers
    
    @MainActor
    private func makeSUT(
        settings: DMProgressViewSettings = MockDMProgressViewSettings()
    ) -> DMProgressViewTDD {
        DMProgressViewTDD(settings: settings)
    }
}
