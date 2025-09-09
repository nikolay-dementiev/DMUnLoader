import SwiftUI
import DMUnLoader

extension View {
    func hudCenter<Content: View>(
        loadingManager: DMLoadingManager,
        @ViewBuilder content: () -> Content
    ) -> some View {
        overlay(alignment: .center) {
            ZStack {
                switch loadingManager.loadableState {
                case .success,
                        .failure,
                        .loading:
                    VariableBlurView(maxBlurRadius: 3)
                    
//                    MDCenterHUD(content: content)
                    
                    content()
                case .none:
                    EmptyView()
                }
            }
        }
    }
}

//private struct MDCenterHUD<Content: View>: View {
//    @ViewBuilder let content: Content
//    @State private var animate = false
//    
//    var body: some View {
//        content
//            .padding(30)
//            .background(Color.gray.opacity(animate ? 0.95 : 0.1))
//            .cornerRadius(10)
//            .scaleEffect(animate ? 1 : 0.9)
//            .transition(.opacity)
//            .onAppear {
//                animate.toggle()
//            }
//            .animation(
//                Animation.spring(duration: 0.2),
//                value: animate
//            )
//    }
//}

