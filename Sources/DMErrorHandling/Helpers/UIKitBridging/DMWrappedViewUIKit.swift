//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUI
import UIKit

public struct DMWrappedViewUIKit<View: UIView>: UIViewRepresentable {
    public let uiView: View
    
    public func makeUIView(context: Context) -> UIView {
        return uiView
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        // Here you can update `UIView` if needed
    }
}
