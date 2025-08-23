import SwiftUI

extension View {
    func hud<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        overlay(alignment: .top) {
            HUD(content: content)
                .onTapGesture {
                    isPresented.wrappedValue = false
                }
                .offset(y: isPresented.wrappedValue ? 0 : -128)
                .animation(Animation.spring(), value: isPresented.wrappedValue)
        }
    }
    
    
    func hudCenter<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        //      overlay(alignment: .center) {
        ZStack {
            switch isPresented.wrappedValue {
            case true:
//                LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)), Color(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing)
//                              .ignoresSafeArea()
                VariableBlurView(maxBlurRadius: 3)
                
                Color.black.opacity(0.1)
                    .ignoresSafeArea()
                MDCenterHUD(content: content)
            default:
                EmptyView()
            }
        }
        .onTapGesture {
            isPresented.wrappedValue = false
        }
        
        //          .offset(y: isPresented.wrappedValue ? 0 : -128)
        //          .animation(Animation.spring(), value: isPresented.wrappedValue)
        //      }
    }
    
}

private struct MDCenterHUD<Content: View>: View {
    @ViewBuilder let content: Content
    @State var animate = false
    
    var body: some View {
        content
            .padding(30)
            .background(Color.gray.opacity(animate ? 0.95 : 0.1))
            .cornerRadius(10)
            .scaleEffect(animate ? 1 : 0.9)
            .transition(.opacity)
            .onAppear {
                animate.toggle()
            }
            .animation(Animation.spring(duration: 0.2, ), value: animate)
    }
}

private struct HUD<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        content
            .padding(.horizontal, 12)
            .padding(16)
            .background(
                Capsule()
                    .foregroundColor(Color.white)
                    .shadow(color: Color(.black).opacity(0.16), radius: 12, x: 0, y: 5)
            )
    }
}


/// A private view used as a blocking overlay to intercept user interactions during loading.
private struct BlockingView: View {
    
    /// The body of the `BlockingView`.
    /// - Returns: A semi-transparent gray color view that covers the entire screen.
    var body: some View {
        Color
            .gray
            .opacity(0.001) // Nearly transparent to allow visual focus on the underlying content
            .ignoresSafeArea() // Ensures the view covers the entire screen, including safe areas
        //.tag(DMRootLoadingModifierOwnSettings.blockingColorViewTag)
    }
}
