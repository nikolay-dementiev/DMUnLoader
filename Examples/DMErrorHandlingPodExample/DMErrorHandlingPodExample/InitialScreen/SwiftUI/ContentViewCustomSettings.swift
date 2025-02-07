//
//  ContentView.swift
//  DMErrorHandlingPodExample
//
//  Created by Nikolay Dementiev on 22.01.2025.
//

import SwiftUI
#if USE_COCOAPODS
import DMErrorHandling
#elseif USE_SPM
import DMErrorHandling
#endif

// loading with custom setting
struct ContentViewCustomSettings: View {
    var body: some View {
        DMLocalLoadingView(provider: CustomDMLoadingViewProvider()) {  
            LoadingContentView()
        }
    }
}
