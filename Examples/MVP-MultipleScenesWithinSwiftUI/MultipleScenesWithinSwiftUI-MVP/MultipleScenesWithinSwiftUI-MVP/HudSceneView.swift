import SwiftUI

struct HudSceneView: View {
  @EnvironmentObject var hudState: HudState

  var body: some View {
    Color.clear
      .ignoresSafeArea(.all)
      .hudCenter(isPresented: $hudState.isPresented) {
          DMProgressView(settings: DMLoadingDefaultViewSettings())
      }
  }
}

