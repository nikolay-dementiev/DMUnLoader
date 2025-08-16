//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import SwiftUI
//import UIKit
@testable import DMUnLoader
//import SnapshotTesting

import PreviewSnapshots
import PreviewSnapshotsTesting

@MainActor
final class DmProgressViewSnapshotTests: XCTestCase {
    override func invokeTest() {
        withSnapshotTesting(record: .failed, diffTool: .ksdiff) {
            super.invokeTest()
        }
    }
    
    func test_progressView_initiatedWithLoadingIndicatorAtTheCenterOfTheScreen() {
        let snapshots = DMProgressView_Previews.snapshots
        
        expect(
            snapshots,
            named: "ViewsPreview_ProductionCodebase",
            record: false
        )
    }
    
    // MARK: HELPER
//    private func makeSut() -> DMProgressView_Previews {
////        let sut = DMProgressView(settings: DMLoadingDefaultViewSettings())
//        DMProgressView_Previews
//        
//        return sut
//    }

    func expect<State>(
        _ snapshot: PreviewSnapshots<State>,
        named name: String? = nil,
        record recording: Bool = false,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) {
        snapshot.assertSnapshots(as: ["Light": .testStrategyLight,
                                      "Dark": .testStrategyDark],
                                 named: name,
                                 record: recording,
                                 file: file,
                                 testName: testName,
                                 line: line) {
            addModification($0)
        }
    }
    
    @inlinable nonisolated func addModification(_ view: some View) -> some View {
        view
        .padding(30)
        .background(Color.gray.opacity(0.8))
        .cornerRadius(10)
    }
}


//TODO: need to improve to be able to run within MacOS target as well

//#if os(iOS) || os(tvOS)
//let frameworkName = "UIKit"

extension Snapshotting where Value: SwiftUI.View, Format == UIImage {
    /// Shared image test strategies
    static var testStrategy: Self {
        .image(
            layout: .fixed(width: 400, height: 400),
            traits: UITraitCollection(displayScale: 1)
        )
    }
    
    static var testStrategyLight: Self {
        .image(
            layout: .device(config: .iPhone13(.portrait)),
            traits: UITraitCollection(userInterfaceStyle: .light)
        )
    }
    
    static var testStrategyDark: Self {
        .image(
            layout: .device(config: .iPhone13(.portrait)),
            traits: UITraitCollection(userInterfaceStyle: .dark)
        )
    }
}
//
//#elseif os(macOS)
//let frameworkName = "AppKit"
//
//extension Snapshotting where Value: SwiftUI.View, Format == NSImage {
//    /// Shared image test strategy
////    static var testStrategy: Self {
////        Snapshotting<NSView, NSImage>.image(size: .init(width: 400, height: 400)).pullback { view in
////            let view = NSHostingView(rootView: view)
////            view.wantsLayer = true
////            view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
////            return view
////        }
////    }
//    
//}
//#endif
