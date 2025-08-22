//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import PreviewSnapshotsTesting

#if os(iOS) || os(tvOS)
let frameworkName = "UIKit"

extension Snapshotting where Value: SwiftUI.View, Format == UIImage {
    static var testStrategyiPhone13Light: Self {
        .image(
            layout: .device(config: .iPhone13(.portrait)),
            traits: UITraitCollection(userInterfaceStyle: .light)
        )
    }
    
    static var testStrategyiPhone13Dark: Self {
        .image(
            layout: .device(config: .iPhone13(.portrait)),
            traits: UITraitCollection(userInterfaceStyle: .dark)
        )
    }
}

#elseif os(macOS)
let frameworkName = "AppKit"

private extension CGSize {
    static let iPhone13Size = CGSize(width: 390, height: 844)
}

@MainActor
extension Snapshotting where Value: SwiftUI.View, Format == NSImage {
    
    static var testStrategyiPhone13Light: Self {
        getStrategy(appearance: .vibrantLight,
                    size: .iPhone13Size)
    }
    
    static var testStrategyiPhone13Dark: Self {
        getStrategy(appearance: .vibrantDark,
                    size: .iPhone13Size)
    }
    
    private static func getStrategy(appearance appearanceName: NSAppearance.Name,
                                    size: CGSize? = nil) -> Self {
        Snapshotting<NSView, NSImage>
            .image(size: size)
            .pullback { view in
            let view = NSHostingView(rootView: view)
            view.appearance = NSAppearance(named: appearanceName)
        
            view.wantsLayer = true
            view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
            return view
        }
    }
}
#endif
