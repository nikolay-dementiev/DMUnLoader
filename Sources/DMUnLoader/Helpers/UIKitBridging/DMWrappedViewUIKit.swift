//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import UIKit

/// A wrapper struct that allows a `UIView` to be used within a SwiftUI view hierarchy.
/// This struct conforms to `UIViewRepresentable`, enabling seamless integration of UIKit views into SwiftUI.
public struct DMWrappedViewUIKit<View: UIView>: UIViewRepresentable {
    
    /// The `UIView` instance to be wrapped and displayed in SwiftUI.
    public let uiView: View
    
    /// Initializes a new instance of `DMWrappedViewUIKit`.
    /// - Parameter uiView: The `UIView` instance to wrap and display in SwiftUI.
    /// - Example:
    ///   ```swift
    ///   let customView = UILabel()
    ///   customView.text = "Hello from UIKit!"
    ///   customView.textAlignment = .center
    ///
    ///   let wrappedView = DMWrappedViewUIKit(uiView: customView)
    ///   ```
    public init(uiView: View) {
        self.uiView = uiView
    }
    
    /// Creates the `UIView` instance to be added to the SwiftUI view hierarchy.
    /// - Parameter context: The context in which the view is being created.
    /// - Returns: The `UIView` instance to be displayed.
    public func makeUIView(context: Context) -> UIView {
        return uiView
    }
    
    /// Updates the `UIView` instance when the SwiftUI view hierarchy changes.
    /// - Parameters:
    ///   - uiView: The `UIView` instance to update.
    ///   - context: The context in which the view is being updated.
    /// - Note: This method can be overridden to apply updates to the `UIView` if needed.
    public func updateUIView(_ uiView: UIView, context: Context) {
        // Here you can update `UIView` if needed
    }
}
