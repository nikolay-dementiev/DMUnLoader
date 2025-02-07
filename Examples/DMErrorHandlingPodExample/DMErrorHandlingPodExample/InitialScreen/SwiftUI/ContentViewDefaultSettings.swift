//
//  ContentViewDefaultSettings.swift
//  DMErrorHandlingPodExample
//
//  Created by Nikolay Dementiev on 03.02.2025.
//

import SwiftUI
#if USE_COCOAPODS
import DMErrorHandling
#elseif USE_SPM
import DMErrorHandling
#endif

// loading with default setting
struct ContentViewDefaultSettings: View {
    var body: some View {
        DMLocalLoadingView(provider: DefaultDMLoadingViewProvider()) {  
            LoadingContentView()
        }
    }
}
