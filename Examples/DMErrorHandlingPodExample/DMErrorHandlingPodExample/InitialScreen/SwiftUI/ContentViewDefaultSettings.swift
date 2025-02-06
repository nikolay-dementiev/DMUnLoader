//
//  ContentViewDefaultSettings.swift
//  DMErrorHandlingPodExample
//
//  Created by Nikolay Dementiev on 03.02.2025.
//

import SwiftUI
import DMErrorHandling

// loading with default setting
struct ContentViewDefaultSettings: View {
    var body: some View {
        DMLocalLoadingView(provider: DefaultDMLoadingViewProvider()) {  
            LoadingContentView()
        }
    }
}
