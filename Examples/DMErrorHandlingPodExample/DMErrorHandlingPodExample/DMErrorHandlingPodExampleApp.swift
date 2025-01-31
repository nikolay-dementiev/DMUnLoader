//
//  DMErrorHandlingPodExampleApp.swift
//  DMErrorHandlingPodExample
//
//  Created by Nikolay Dementiev on 22.01.2025.
//

import SwiftUI
import DMErrorHandling

@main
struct DMErrorHandlingPodExampleApp: App {
    var body: some Scene {
        WindowGroup {
            DMRootLoadingView {
//                ZStack {
                    MainTabView()
                    
//                    BlockingView()
//                        .allowsHitTesting(true)
//                }
            }
        }
    }
    
    private struct MainTabView: View {
        var body: some View {
            TabView {
                ContentViewDefaultSettings()
                    .tabItem {
                        Label("Default", systemImage: "gearshape")
                    }
                
                ContentViewCustomSettings()
                    .tabItem {
                        Label("Custom", systemImage: "pencil")
                    }
            }
        }
    }
}


//struct BlockingView: View {
//    var body: some View {
//        Color.gray.opacity(0.001) // Blocks interactions by giving a transparent background
//            .ignoresSafeArea()
//            //.allowsHitTesting(true) // Forbids any pressing
//    }
//}

