//
//  ContentView.swift
//  DMErrorHandlingPodExample
//
//  Created by Nikolay Dementiev on 22.01.2025.
//

import SwiftUI
import DMErrorHandling

// loading with custom setting
struct ContentViewCustomSettings: View {
    var body: some View {
        DMLocalLoadingView(provider: CustomDMLoadingViewProvider()) {  
            LoadingContentView()
        }
    }
}
