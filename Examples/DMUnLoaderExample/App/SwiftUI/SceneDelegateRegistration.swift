import SwiftUI
import DMUnLoader

/// The scene delegates the library installed for the SwiftUI path. SwiftUI keeps them out of
/// `UIScene.delegate` and hands each to the views of its scene as an environment object, so
/// the app-hosted tests read them here.
@MainActor
public enum ExampleSceneDelegate {
    private static var registered: [WeakSceneDelegate] = []

    /// The delegate of the scene whose root view appeared last, among the delegates still
    /// alive: when a second scene closes, the first scene's delegate is current again.
    public static var current: DMSceneDelegateBase<DMLoadingManagerMain>? {
        registered.last { $0.sceneDelegate != nil }?.sceneDelegate
    }

    fileprivate static func register(_ sceneDelegate: DMSceneDelegateBase<DMLoadingManagerMain>) {
        registered.removeAll { $0.sceneDelegate == nil || $0.sceneDelegate === sceneDelegate }
        registered.append(WeakSceneDelegate(sceneDelegate: sceneDelegate))
    }
}

private struct WeakSceneDelegate {
    weak var sceneDelegate: DMSceneDelegateBase<DMLoadingManagerMain>?
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
