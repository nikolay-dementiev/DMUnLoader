//
//  DMUnLoaderPodExample
//
//  Created by Mykola Dementiev
//

import SwiftUI
import DMUnLoader

struct MainTabViewSwiftUI<LM: DMLoadingManagerProtocol>: View {
    
    var loadingManager: LM
    
    var body: some View {
        TabView {
            // First Tab - Default Settings
            NavigationStack {
                makeLoadingContentViewSwiftUI(loadingManager: loadingManager,
                                              provider: DefaultDMLoadingViewProvider())
                .navigationTitle("Default Settings")
            }
            .tabItem {
                Label("Default", systemImage: "gearshape")
            }
            
            // Second Tab - Custom Settings
            NavigationStack {
                makeLoadingContentViewSwiftUI(loadingManager: loadingManager,
                                              provider: CustomDMLoadingViewProvider())
                    .navigationTitle("Custom Settings")
            }
            .tabItem {
                Label("Custom", systemImage: "pencil")
            }
        }
    }
    
    private func makeLoadingContentViewSwiftUI<LVP: DMLoadingViewProviderProtocol>(
        loadingManager: LM,
        provider: LVP
    ) -> some View {
        LoadingContentViewSwiftUI(
            loadingManager: loadingManager,
            provider: provider
        )
    }
}
