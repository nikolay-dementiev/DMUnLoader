import SwiftUI
import MPSwiftUI_SDK

internal struct AppMainSceneView: View {
    @EnvironmentObject var sceneDelegate: MVPSceneDelegate
    
    @ObservedObject var hudState: HudState
    @State var showingSheet = false
    
    internal init(hudState: HudState) {
        self.hudState = hudState
    }
    
    public var body: some View {
        NavigationView {
            AppMainSceneViewContent(
                hudState: hudState,
                showingSheet: $showingSheet
            )
        }
        .sheet(isPresented: $showingSheet) {
            AppMainSceneViewContent(
                hudState: hudState,
                showingSheet: $showingSheet
            )
        }
        .onAppear {
            sceneDelegate.hudState = hudState
        }
    }
}

struct AppMainSceneViewContent: View {
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
