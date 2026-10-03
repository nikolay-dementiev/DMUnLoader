import DMUnLoader
import SwiftUI
import UIKit

/// The counters of the demo once more, in a strip at the bottom of the screen above the
/// HUD's level. It takes no touch. While a HUD is shown the library hides the app's other
/// windows from assistive technology, which the UI tests read the counters through; a window
/// above the HUD stays readable.
@MainActor
enum CountersWindow {
    private static var window: UIWindow?

    static func show<LM: DMLoadingManager>(for model: DemoModel<LM>) {
        guard window == nil,
              let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first else {
            return
        }
        let bounds = scene.coordinateSpace.bounds
        let window = UIWindow(windowScene: scene)
        window.frame = CGRect(x: 0, y: bounds.height - 100, width: bounds.width, height: 100)
        window.windowLevel = .normal + 10
        window.isUserInteractionEnabled = false
        let controller = UIHostingController(rootView: CountersView(model: model))
        controller.view.backgroundColor = .clear
        window.rootViewController = controller
        window.isHidden = false
        self.window = window
    }
}

private struct CountersView<LM: DMLoadingManager>: View {
    @ObservedObject var model: DemoModel<LM>

    var body: some View {
        VStack {
            HStack {
                Text(DemoText.contentTaps(model.contentTaps))
                    .accessibilityIdentifier(DemoIdentifier.windowContentTaps)
                Text(DemoText.retries(model.retries))
                    .accessibilityIdentifier(DemoIdentifier.windowRetries)
            }
            if LaunchOptions.current.showsAccessibilityTree {
                // Read again twice a second: nothing tells the app when the HUD's tree changes.
                TimelineView(.periodic(from: .now, by: 0.5)) { _ in
                    Text(HUDAccessibilityTree.elements().joined(separator: DemoText.treeSeparator))
                        .accessibilityIdentifier(DemoIdentifier.hudAccessibilityTree)
                }
            }
        }
        .font(.caption)
    }
}

/// The elements that assistive technology reaches in the HUD window, in order: each label, with
/// `DemoText.imageMark` after an image. The UI tests read them here, because XCUITest also lists
/// the elements that SwiftUI hides from assistive technology.
@MainActor
private enum HUDAccessibilityTree {
    static func elements() -> [String] {
        let hudWindows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .filter { NSStringFromClass(type(of: $0)).hasSuffix("DMPassThroughWindow") }
        var elements: [String] = []
        hudWindows.forEach { collect($0, into: &elements) }
        return elements
    }

    private static func collect(_ object: Any, into elements: inout [String]) {
        guard let object = object as? NSObject else { return }
        if let view = object as? UIView, view.isHidden || view.accessibilityElementsHidden {
            return
        }
        if object.isAccessibilityElement {
            let label = object.accessibilityLabel ?? ""
            elements.append(object.accessibilityTraits.contains(.image) ? label + DemoText.imageMark : label)
            return
        }
        children(of: object).forEach { collect($0, into: &elements) }
    }

    private static func children(of object: NSObject) -> [Any] {
        if let children = object.accessibilityElements, !children.isEmpty {
            return children
        }
        let count = object.accessibilityElementCount()
        if count > 0, count != NSNotFound {
            return (0..<count).compactMap { object.accessibilityElement(at: $0) }
        }
        return (object as? UIView)?.subviews ?? []
    }
}
