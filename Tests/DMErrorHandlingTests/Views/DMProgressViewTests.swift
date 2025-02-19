import XCTest
@testable import YourAppModule // Replace with your app's module name
import SwiftUI
import ViewInspector

// Conform DMProgressView to Inspectable
extension DMProgressView: Inspectable {}

class DMProgressViewTests: XCTestCase {
    
    // MARK: - Mock Dependencies
    
    struct MockSettingsProvider: DMLoadingViewSettings {
        var frameGeometrySize: CGSize = CGSize(width: 200, height: 200)
        
        var loadingTextProperties: LoadingTextProperties = .init(
            text: "Loading...",
            foregroundColor: .blue,
            font: .system(size: 16),
            lineLimit: 1,
            linePadding: 8
        )
        
        var progressIndicatorProperties: ProgressIndicatorProperties = .init(
            size: .regular,
            tintColor: .green
        )
        
        var loadingContainerForegroundColor: Color = .white
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        let settingsProvider = MockSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        XCTAssertNotNil(view.settingsProvider, "The settingsProvider should be initialized")
    }
    
    // MARK: - Rendering Tests
    
    func testRendersContainerView() throws {
        let settingsProvider = MockSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        // Find the container view by tag
        let containerView = try view.inspect().find(viewWithTag: DMProgressViewOwnSettings.containerViewTag)
        XCTAssertNotNil(containerView, "The container view should be rendered")
    }
    
    func testRendersVStack() throws {
        let settingsProvider = MockSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        // Find the VStack by tag
        let vStack = try view.inspect().find(viewWithTag: DMProgressViewOwnSettings.vStackViewTag)
        XCTAssertNotNil(vStack, "The VStack should be rendered")
    }
    
    func testRendersText() throws {
        let settingsProvider = MockSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        // Find the Text view by tag
        let text = try view.inspect().find(viewWithTag: DMProgressViewOwnSettings.textTag).text()
        XCTAssertEqual(try text.string(), "Loading...", "The Text view should display the correct text")
    }
    
    func testRendersProgressView() throws {
        let settingsProvider = MockSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        // Find the ProgressView by tag
        let progressView = try view.inspect().find(viewWithTag: DMProgressViewOwnSettings.progressViewTag).progressView()
        XCTAssertNotNil(progressView, "The ProgressView should be rendered")
    }
    
    // MARK: - Customization Tests
    
    func testAppliesTextProperties() throws {
        let settingsProvider = MockSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        // Find the Text view by tag
        let text = try view.inspect().find(viewWithTag: DMProgressViewOwnSettings.textTag).text()
        
        // Verify text properties
        XCTAssertEqual(try text.string(), "Loading...", "The Text view should display the correct text")
        XCTAssertEqual(try text.foregroundColor(), .blue, "The Text view should have the correct foreground color")
        XCTAssertEqual(try text.font(), Font.system(size: 16), "The Text view should have the correct font")
        XCTAssertEqual(try text.lineLimit(), 1, "The Text view should have the correct line limit")
        XCTAssertEqual(try text.padding(.horizontal), 8, "The Text view should have the correct padding")
    }
    
    func testAppliesProgressViewProperties() throws {
        let settingsProvider = MockSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        // Find the ProgressView by tag
        let progressView = try view.inspect().find(viewWithTag: DMProgressViewOwnSettings.progressViewTag).progressView()
        
        // Verify ProgressView properties
        XCTAssertEqual(try progressView.controlSize(), .regular, "The ProgressView should have the correct control size")
        XCTAssertEqual(try progressView.tint(), .green, "The ProgressView should have the correct tint color")
    }
    
    // MARK: - Layout Tests
    
    func testRespectsLayoutConstraints() throws {
        let settingsProvider = MockSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        let geometry = settingsProvider.frameGeometrySize
        let minSize = min(geometry.width - 20, geometry.height - 20, 30)
        
        // Find the VStack by tag
        let vStack = try view.inspect().find(viewWithTag: DMProgressViewOwnSettings.vStackViewTag)
        
        // Verify frame constraints
        XCTAssertEqual(try vStack.minimumWidth(), minSize, "The VStack should have the correct minimum width")
        XCTAssertEqual(try vStack.maximumWidth(), geometry.width / 2, "The VStack should have the correct maximum width")
        XCTAssertEqual(try vStack.minimumHeight(), minSize, "The VStack should have the correct minimum height")
        XCTAssertEqual(try vStack.maximumHeight(), geometry.height / 2, "The VStack should have the correct maximum height")
    }
}