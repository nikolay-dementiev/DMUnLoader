//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 25.01.2025.
//

import SwiftUI

internal struct CloseButtonView: View {
    
    internal var action: @MainActor () -> Void
    
    var body: some View {
        Button(action: action, label: {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(.all, 5)
                .background(Color.black.opacity(0.6))
                .clipShape(Circle())
        })
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(Text("Close"))
        .accessibilityHint("Tap to close the screen")
        .accessibilityAddTraits(.isButton)
        .accessibilityRemoveTraits(.isImage)
    }
}
