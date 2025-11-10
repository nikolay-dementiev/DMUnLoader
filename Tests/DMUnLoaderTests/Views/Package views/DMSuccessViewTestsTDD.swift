//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import SwiftUI
import ViewInspector

private struct DMSuccessViewTDD: View {
    let settingsProvider: DMSuccessViewSettings
    
    init(settings settingsProvider: DMSuccessViewSettings) {
        self.settingsProvider = settingsProvider
    }
    
    var body: some View {
        let successImageProperties = settingsProvider.successImageProperties
        
        VStack {
            successImageProperties.image
                .tag(DMSuccessViewOwnSettings.imageTag)
            
            let successTextProperties = settingsProvider.successTextProperties
            if let successText = successTextProperties.text {
                Text(successText)
                    .foregroundColor(successTextProperties.foregroundColor)
                    .tag(DMSuccessViewOwnSettings.textTag)
            }
        }
        .tag(DMSuccessViewOwnSettings.containerViewTag)
    }
}

@MainActor
final class DMSuccessViewTestsTDD: XCTestCase {

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
        
        XCTAssertNotNil(image,
                        "The ImageView should be rendered")
        let imageFormSUT = try image.actualImage().name()
        
        XCTAssertEqual(
            imageFormSUT,
            try settings.successImageProperties.image.name(),
            "The default success image should match the settings"
        )
        XCTAssertEqual(
            imageFormSUT,
            "checkmark.circle.fill",
            "The default success image should be 'checkmark.circle.fill'"
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
    
    // MARK: - Helpers
    
    private func makeSUT(
        settings: DMSuccessViewSettings = DMSuccessDefaultViewSettings()
    ) -> DMSuccessViewTDD {
        let sut = DMSuccessViewTDD(
            settings: settings
        )
        
        return sut
    }
    
}
