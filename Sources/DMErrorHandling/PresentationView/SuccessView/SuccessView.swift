//
//  SwiftUIView.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 28.01.2025.
//

import SwiftUI

internal struct SuccessView: View {
    let assosiatedObject: Any?
    
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.green)
            Text("\(assosiatedObject as? String ?? "Успішно!")")
                .foregroundColor(.white)
        }
    }
}
