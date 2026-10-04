//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

package struct DMHudSceneView<LM: DMLoadingManager>: View {
    @ObservedObject var loadingManager: LM
    private let onStateChange: @MainActor (DMLoadableType) -> Void

    /// - Parameter onStateChange: Called with the state of `loadingManager` when the view
    ///   appears and whenever the state changes, also inside one phase.
    package init(loadingManager: LM, onStateChange: @escaping @MainActor (DMLoadableType) -> Void = { _ in }) {
        self.loadingManager = loadingManager
        self.onStateChange = onStateChange
    }

    package var body: some View {
        Color.clear
            .ignoresSafeArea(.all)
            .hudCenter(loadingManager: loadingManager) {
                DMLoadingView(
                    loadingManager: loadingManager,
                    viewModel: DefaultHUDViewModel(loadingManager: loadingManager)
                )
            }
            .onChange(of: loadingManager.loadableState, initial: true) { _, state in
                onStateChange(state)
            }
    }
}

#Preview("Error") {
    let loadingManager = DMLoadingManagerMain(
        state: .failure(
            error: DMAppError.custom("Something went wrong"),
            provider: DefaultDMLoadingViewProvider()
                .eraseToAnyViewProvider(),
            onRetry: DMButtonAction({ _ in })
        ),
        settings: DMLoadingManagerDefaultSettings()
    )
    
    ZStack {
        // swiftlint:disable:next line_length
        Text("A wiki  is a form of hypertext publication on the internet which is collaboratively edited and managed by its audience directly through a web browser. A typical wiki contains multiple pages that can either be edited by the public or limited to use within an organization for maintaining its knowledge base. Its name derives from the first user-editable website called\nA wiki  is a form of hypertext publication on the internet which is collaboratively edited and managed by its audience directly through a web browser. A typical wiki contains multiple pages that can either be edited by the public or limited to use within an organization for maintaining its knowledge base. Its name derives from the first user-editable website called\nA wiki  is a form of hypertext publication on the internet which is collaboratively edited and managed by its audience directly through a web browser. A typical wiki contains multiple pages that can either be edited by the public or limited to use within an organization for maintaining its knowledge base. Its name derives from the first user-editable website called\nA wiki  is a form of hypertext publication on the internet which is collaboratively edited and managed by its audience directly through a web browser. A typical wiki contains multiple pages that can either be edited by the public or limited to use within an organization for maintaining its knowledge base. Its name derives from the first user-editable website called\nA wiki  is a form of hypertext publication on the internet which is collaboratively edited and managed by its audience directly through a web browser. A typical wiki contains multiple pages that can either be edited by the public or limited to use within an organization for maintaining its knowledge base. Its name derives from the first user-editable website called\n")
        
        DMHudSceneView(loadingManager: loadingManager)
    }.ignoresSafeArea()
}

#Preview("Loading") {
    let loadingManager = DMLoadingManagerMain(
        state: .loading(
            provider: DefaultDMLoadingViewProvider()
                .eraseToAnyViewProvider(),
        ),
        settings: DMLoadingManagerDefaultSettings()
    )
    
    DMHudSceneView(loadingManager: loadingManager)
}

#Preview("Success") {
    let loadingManager = DMLoadingManagerMain(
        state: .success(
            "Wow! All were done!",
            provider: DefaultDMLoadingViewProvider()
                .eraseToAnyViewProvider(),
        ),
        settings: DMLoadingManagerDefaultSettings()
    )
    
    DMHudSceneView(loadingManager: loadingManager)
}

#Preview("None") {
    let loadingManager = DMLoadingManagerMain(
        state: .none,
        settings: DMLoadingManagerDefaultSettings()
    )

    DMHudSceneView(loadingManager: loadingManager)
}

#Preview("Dim backdrop") {
    backdropPreview(.dim())
}

#Preview("Material backdrop") {
    backdropPreview(.material())
}

#Preview("Clear backdrop") {
    backdropPreview(.clear)
}

#Preview("Loading under Reduce Transparency") {
    backdropPreview(.variableBlur, reducesTransparency: true)
}

#Preview("Material under Reduce Transparency") {
    backdropPreview(.material(), reducesTransparency: true)
}

/// A loading HUD with `backdrop` over text, so what the backdrop draws shows.
@MainActor
private func backdropPreview(_ backdrop: DMHUDBackdrop, reducesTransparency: Bool = false) -> some View {
    let loadingManager = DMLoadingManagerMain(
        state: .loading(provider: DefaultDMLoadingViewProvider().eraseToAnyViewProvider()),
        settings: DMLoadingManagerDefaultSettings(backdrop: backdrop)
    )
    return ZStack {
        Text(String(repeating: "The app under the HUD. ", count: 60))
        DMHudSceneView(loadingManager: loadingManager)
            .environment(\.hudReducesTransparency, reducesTransparency)
    }
    .ignoresSafeArea()
}
