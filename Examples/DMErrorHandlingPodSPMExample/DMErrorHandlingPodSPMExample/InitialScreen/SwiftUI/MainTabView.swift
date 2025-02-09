//
//  MainTabView.swift
//  DMErrorHandlingPodExample
//
//  Created by Nikolay Dementiev on 09.02.2025.
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
