//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import UIKit

/// Keeps the HUD of `manager` over the scene of the window this view is in. It learns its
/// scene when UIKit moves it to a window, and takes the HUD away when SwiftUI removes it.
struct SceneHUDAnchor<LM: DMLoadingManager>: UIViewRepresentable {
    let manager: LM

    func makeCoordinator() -> RootViewHUDAttachment {
        RootViewHUDAttachment()
    }

    func makeUIView(context: Context) -> SceneReaderView {
        let view = SceneReaderView()
        view.isUserInteractionEnabled = false
        view.isAccessibilityElement = false
        view.accessibilityElementsHidden = true
        view.onMove = { [weak attachment = context.coordinator] scene in
            attachment?.viewDidMove(to: scene)
        }
        context.coordinator.loadingManagerDidChange(to: manager)
        return view
    }

    func updateUIView(_ view: SceneReaderView, context: Context) {
        context.coordinator.loadingManagerDidChange(to: manager)
    }

    static func dismantleUIView(_ view: SceneReaderView, coordinator: RootViewHUDAttachment) {
        coordinator.viewDidMove(to: nil)
    }
}

/// Reports the scene of each window UIKit moves it to: `nil` for no window, and for a window
/// that belongs to no scene.
final class SceneReaderView: UIView {
    var onMove: (@MainActor (UIWindowScene?) -> Void)?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        onMove?(window?.windowScene)
    }
}
