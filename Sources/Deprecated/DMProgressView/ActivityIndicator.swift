//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 18.01.2025.
//
//for more detail: https://stackoverflow.com/a/56496896/6643923


import SwiftUI

internal struct ActivityIndicator: UIViewRepresentable {

    @Binding internal var isAnimating: Bool
    internal let style: UIActivityIndicatorView.Style

    internal func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    internal func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
