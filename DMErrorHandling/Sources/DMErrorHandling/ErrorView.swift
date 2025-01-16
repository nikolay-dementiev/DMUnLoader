//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 16.01.2025.
//

import SwiftUI

public struct ErrorView: View {
    let error: Error
    let onRetry: (() -> Void)?

    public var body: some View {
        VStack {
//            Image(.error)
            Text("An error has occured")
            Text(error.localizedDescription)
            Button("Retry") { onRetry?() }
        }
    }
}

#Preview {
    ErrorView(error: DMAppError.custom(errorDescription: "Some error Test"),
              onRetry: nil )
}
