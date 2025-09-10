//
//  DMUnLoaderPodExample
//
//  Created by Mykola Dementiev
//

import SwiftUI
import DMUnLoader

struct MainTabView<LM: DMLoadingManagerInteralProtocol>: View {
    
    var loadingManager: LM
    
    var body: some View {
        TabView {
            // First Tab - Default Settings
            NavigationStack {
//                ContentViewDefaultSettings()
                ContentViewDefaultSettingsTopView(loadingManager: loadingManager)
                    .navigationTitle("Default Settings")
            }
            .tabItem {
                Label("Default", systemImage: "gearshape")
            }
            
            // Second Tab - Custom Settings
            NavigationStack {
                ContentViewCustomSettings()
                    .environmentObject(loadingManager)
                    .navigationTitle("Custom Settings")
            }
            .tabItem {
                Label("Custom", systemImage: "pencil")
            }
        }
    }
}
