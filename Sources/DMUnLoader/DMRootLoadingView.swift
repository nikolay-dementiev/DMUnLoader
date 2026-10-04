//  Created by Mykola Dementiev
//

import SwiftUI

/// The root view of a scene that shows the HUD of a loading manager over that scene. The
/// content of the scene receives the manager, to show its states.
public struct DMRootLoadingView<
    LM: DMLoadingManager,
    Content: View
>: View {
    private let managerSource: ManagerSource
    private let content: (LM) -> Content

    /// Creates the loading manager of the scene, shows `content` with it, and hands it to the
    /// scene delegate when the view appears.
    ///
    /// The scene delegate `DMSceneDelegateBase<LM>`, for this `LM`, must be in the environment.
    /// `DMAppDelegate<LM>`, used with `@UIApplicationDelegateAdaptor`, puts it there. Without it
    /// SwiftUI stops the app when the view appears. In an app without `DMAppDelegate`, use
    /// `init(manager:content:onAttachmentFailure:)`.
    public init(@ViewBuilder content: @escaping (LM) -> Content) {
        self.managerSource = .createdForTheSceneDelegate
        self.content = content
    }

    /// Creates the loading manager of the scene, shows `content` with it, and hands it to the
    /// scene delegate when the view appears.
    ///
    /// The scene delegate `DMSceneDelegateBase<DMLoadingManagerMain>` must be in the
    /// environment. `DMAppDelegateType`, used with `@UIApplicationDelegateAdaptor`, puts it
    /// there. Without it SwiftUI stops the app when the view appears. In an app without
    /// `DMAppDelegateType`, use `init(manager:content:onAttachmentFailure:)`.
    public init(@ViewBuilder content: @escaping (DMLoadingManagerMain) -> Content)
        where LM == DMLoadingManagerMain {
        self.managerSource = .createdForTheSceneDelegate
        self.content = content
    }

    /// Shows `content` with a loading manager that the host owns, and shows the HUD of that
    /// manager over the scene of this view, in a window of its own.
    ///
    /// This initializer needs neither `DMAppDelegate` nor a scene delegate of this library. It
    /// does not read the scene delegate from the environment, so the requirement of
    /// `init(content:)` does not apply: the view finds its scene from the window it is shown in.
    ///
    /// - The HUD appears once the view is in a window of a scene. Until then the manager is kept
    ///   and nothing is reported: a view that is not in a window yet is waiting, not failing.
    /// - When the view leaves its window, or its scene disconnects, the HUD window leaves the
    ///   scene. The manager is kept, and the HUD comes back when the view is in a window again.
    /// - Another manager given in a later update takes over the HUD window. The HUD keeps no
    ///   replaced manager alive.
    /// - `content` is evaluated again whenever the manager changes, as with `init(content:)`.
    /// - Use one such view per scene. A scene delegate of this library that is also given a
    ///   manager shows a second HUD window in the same scene.
    ///
    /// Keep the manager alive outside this view, for example in a `@StateObject` of the app. A
    /// manager created inside a `body` is a new manager at every update.
    ///
    /// - Parameters:
    ///   - manager: The loading manager whose HUD is shown. The view holds it strongly.
    ///   - content: The content of the scene. It receives `manager`.
    ///   - onAttachmentFailure: Called on the main actor when the HUD cannot be shown over the
    ///     scene of this view. This version knows no such case and never calls it; see
    ///     ``DMHUDAttachmentFailure``. `nil`, the default, reports nothing.
    public init(
        manager: LM,
        @ViewBuilder content: @escaping (LM) -> Content,
        onAttachmentFailure: (@MainActor (DMHUDAttachmentFailure) -> Void)? = nil
    ) {
        // Not kept: this version knows no failure to report.
        self.managerSource = .injected(manager)
        self.content = content
    }

    /// The content of the scene; the HUD of the manager is shown over the scene.
    public var body: some View {
        switch managerSource {
        case .createdForTheSceneDelegate:
            SceneDelegateRoot(content: content)
        case let .injected(manager):
            InjectedManagerRoot(manager: manager, content: content)
        }
    }

    private enum ManagerSource {
        case createdForTheSceneDelegate
        case injected(LM)
    }
}

/// Creates the loading manager and hands it to the scene delegate of the library, which it
/// reads from the environment.
private struct SceneDelegateRoot<LM: DMLoadingManager, Content: View>: View {
    @EnvironmentObject private var sceneDelegate: DMSceneDelegateBase<LM>
    @StateObject private var loadingManager = LM()

    let content: (LM) -> Content

    var body: some View {
        content(loadingManager)
            .onAppear {
                sceneDelegate.loadingManager = loadingManager
            }
    }
}

/// Shows `content` with the host's manager, and the HUD of that manager over the scene of the
/// window this view is in.
private struct InjectedManagerRoot<LM: DMLoadingManager, Content: View>: View {
    @ObservedObject var manager: LM

    let content: (LM) -> Content

    var body: some View {
        content(manager)
            .background(
                SceneHUDAnchor(manager: manager)
                    .frame(width: 0, height: 0)
                    .accessibilityHidden(true)
            )
    }
}

// MARK: - Previews

@MainActor
private func rootLoadingViewPreview(_ state: (AnyDMLoadingViewProvider) -> DMLoadableType) -> some View {
    let state = state(DefaultDMLoadingViewProvider().eraseToAnyViewProvider())
    let manager = DMLoadingManagerMain(state: state, settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600)))
    return DMRootLoadingView(manager: manager) { _ in
        Text(verbatim: "The content of the scene")
    }
}

#Preview("Idle") {
    rootLoadingViewPreview { _ in .none }
}

#Preview("Loading") {
    rootLoadingViewPreview { .loading(provider: $0) }
}

#Preview("Success") {
    rootLoadingViewPreview { .success("Saved", provider: $0) }
}

#Preview("Failure without Retry") {
    rootLoadingViewPreview { .failure(error: DMAppError.custom("Failed"), provider: $0) }
}

#Preview("Failure with Retry") {
    rootLoadingViewPreview { .failure(error: DMAppError.custom("Failed"), provider: $0, onRetry: DMButtonAction {}) }
}
