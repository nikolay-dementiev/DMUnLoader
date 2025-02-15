//
//  CustomSizeView.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 03.02.2025.
//

import SwiftUICore

public struct CustomSizeView {
    public init(width: CGFloat? = nil,
                height: CGFloat? = nil,
                alignment: Alignment = .center) {
        self.width = width
        self.height = height
        self.alignment = alignment
    }
    
    var width: CGFloat?
    var height: CGFloat?
    var alignment: Alignment = .center
}
