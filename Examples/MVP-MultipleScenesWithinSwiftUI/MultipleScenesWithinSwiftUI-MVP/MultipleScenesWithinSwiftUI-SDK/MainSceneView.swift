import SwiftUI

struct MainSceneView: View {
    @EnvironmentObject var sceneDelegate: MVPSceneDelegate
    
    @ObservedObject var hudState: HudState
    @State var showingSheet = false
    
    var body: some View {
        NavigationView {
            MainSceneViewContent(
                hudState: hudState,
                showingSheet: $showingSheet
            )
        }
        .sheet(isPresented: $showingSheet) {
            MainSceneViewContent(
                hudState: hudState,
                showingSheet: $showingSheet
            )
        }
        .onAppear {
            sceneDelegate.hudState = hudState
        }
    }
}

struct MainSceneViewContent: View {
    @ObservedObject var hudState: HudState
    @Binding var showingSheet: Bool
    
    var body: some View {
        VStack {
            Button("Show hud") {
                hudState.show()
            }
            
            Button("Show sheet") {
                showingSheet = true
            }
        }
        .font(.largeTitle)
        .frame(maxWidth: .infinity)
    }
}
