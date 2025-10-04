//
//  DMUnLoaderPodExample
//
//  Created by Mykola Dementiev
//

import SwiftUI
import DMUnLoader

struct MainTabViewSwiftUI<LM: DMLoadingManagerInteralProtocol>: View {
    
    var loadingManager: LM
    
    var body: some View {
        TabView {
            // First Tab - Default Settings
            NavigationStack {
                ContentViewDefaultSettingsTopViewSwiftUI(loadingManager: loadingManager)
                    .navigationTitle("Default Settings")
            }
            .tabItem {
                Label("Default", systemImage: "gearshape")
            }
            
            // Second Tab - Custom Settings
            NavigationStack {
                ContentViewCustomSettingsTopViewSwiftUI(loadingManager: loadingManager)
                    .navigationTitle("Custom Settings")
            }
            .tabItem {
                Label("Custom", systemImage: "pencil")
            }
        }
    }
}
