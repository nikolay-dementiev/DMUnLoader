//
//  DMUnLoaderPodExample
//
//  Created by Mykola Dementiev
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // First Tab - Default Settings
            NavigationStack {
                ContentViewDefaultSettings()
                    .navigationTitle("Default Settings")
            }
            .tabItem {
                Label("Default", systemImage: "gearshape")
            }
            
            // Second Tab - Custom Settings
            NavigationStack {
                ContentViewCustomSettings()
                    .navigationTitle("Custom Settings")
            }
            .tabItem {
                Label("Custom", systemImage: "pencil")
            }
        }
    }
}
