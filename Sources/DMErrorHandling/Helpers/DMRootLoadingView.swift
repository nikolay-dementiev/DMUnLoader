//
//  DMRootLoadingView.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 24.01.2025.
//

import SwiftUICore

public struct DMRootLoadingView<Content: View>: View {
    private let content: () -> Content
    
    public init(
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
    }
    
    public var body: some View {
        return content()
            .rootLoading()
    }
}
