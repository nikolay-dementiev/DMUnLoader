import SwiftUI
import DMUnLoader

/// The scene delegate the library installed for the SwiftUI path. SwiftUI keeps it out of
/// `UIScene.delegate` and hands it to views as an environment object, so the app-hosted
/// tests read it here.
@MainActor
public enum ExampleSceneDelegate {
    public private(set) static weak var current: DMSceneDelegateBase<DMLoadingManagerMain>?

    fileprivate static func register(_ sceneDelegate: DMSceneDelegateBase<DMLoadingManagerMain>) {
        current = sceneDelegate
    }
}

/// Registers the scene delegate of the environment when the view appears.
struct SceneDelegateRegistration: ViewModifier {
    @EnvironmentObject private var sceneDelegate: DMSceneDelegateBase<DMLoadingManagerMain>

    func body(content: Content) -> some View {
        content.onAppear {
            ExampleSceneDelegate.register(sceneDelegate)
        }
    }
}
