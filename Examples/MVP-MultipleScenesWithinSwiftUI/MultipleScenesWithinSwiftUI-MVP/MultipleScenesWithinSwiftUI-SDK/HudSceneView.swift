import SwiftUI

struct HudSceneView: View {
    @ObservedObject var hudState: HudState
    
    var body: some View {
        Color.clear
            .ignoresSafeArea(.all)
            .hudCenter(isPresented: $hudState.isPresented) {
                DMProgressView(settings: DMLoadingDefaultViewSettings())
            }
    }
}

