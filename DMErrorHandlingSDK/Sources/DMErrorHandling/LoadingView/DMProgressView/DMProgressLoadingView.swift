//
//  SwiftUIView.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 18.01.2025.
//
//for more detail: https://stackoverflow.com/a/56496896/6643923

import SwiftUI

struct DMProgressLoadingView<Content>: View, LoadingViewScene where Content: View {
//struct DMProgressLoadingView: View, LoadingViewScene {
    
    @Binding var isShowing: Bool
    var content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                
//                self.content()
//                    .disabled(self.isShowing)
//                    .blur(radius: self.isShowing ? 3 : 0)
                
                VStack {
                    Text("Loading...")
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                }
                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(20)
                .opacity(self.isShowing ? 1 : 0)
                
            }
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity)
        }
    }
}

#Preview {
    DMProgressLoadingView(isShowing: .constant(true)) {
        List(["1", "2", "3", "4", "5"], id: \.self) { row in
            Text(row)
        }.navigationBarTitle(Text("A List"), displayMode: .large)
//        EmptyView()
    }
}
