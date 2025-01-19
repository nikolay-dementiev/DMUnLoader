//
//  EdgeInsets.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 19.01.2025.
//

import SwiftUI


internal extension EdgeInsets {
    
    //this initializer provides default .zero values for ecery paramters
    init(top: CGFloat = .zero,
         bottom: CGFloat = .zero,
         left: CGFloat = .zero,
         right: CGFloat = .zero) {
        
        self.init(top: top,
                  leading: left,
                  bottom: bottom,
                  trailing: right)
    }
}
