//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUICore

/// A struct representing a custom size view with optional width, height, and alignment properties.
/// This struct is typically used to define the dimensions and alignment of a view or component.
public struct CustomSizeView {
    
    /// The width of the custom size view.
    /// - Note: If `nil`, the width is not explicitly defined.
    public var width: CGFloat?
    
    /// The height of the custom size view.
    /// - Note: If `nil`, the height is not explicitly defined.
    public var height: CGFloat?
    
    /// The alignment of the custom size view.
    /// - Default: `.center`
    public var alignment: Alignment = .center
    
    /// Initializes a new instance of `CustomSizeView`.
    /// - Parameters:
    ///   - width: The width of the view. Defaults to `nil`.
    ///   - height: The height of the view. Defaults to `nil`.
    ///   - alignment: The alignment of the view. Defaults to `.center`.
    /// - Example:
    ///   ```swift
    ///   let customSize = CustomSizeView(width: 100, height: 200, alignment: .topLeading)
    ///   print("Width: \(customSize.width ?? 0), Height: \(customSize.height ?? 0), Alignment: \(customSize.alignment)")
    ///   // Output: Width: 100, Height: 200, Alignment: topLeading
    ///   ```
    public init(width: CGFloat? = nil,
                height: CGFloat? = nil,
                alignment: Alignment = .center) {
        self.width = width
        self.height = height
        self.alignment = alignment
    }
}
