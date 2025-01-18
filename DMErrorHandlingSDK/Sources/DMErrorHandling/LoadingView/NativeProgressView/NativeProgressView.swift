//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 18.01.2025.
//

import SwiftUI


internal struct NativeProgressView: View, LoadingViewScene {
    
    internal var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                
                VStack {
                    Text("Loading...")
                    ProgressView()
                        .controlSize(.large)
                        .progressViewStyle(CircularProgressViewStyle())
                }
                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(20)
                .opacity(1)
                
            }
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity)
        }
    }
}

#Preview {
    NativeProgressView()
}
