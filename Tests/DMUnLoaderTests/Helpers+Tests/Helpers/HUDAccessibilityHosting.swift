//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMUnLoader
import UIKit
import XCTest

// MARK: - The elements

/// One element of the accessibility tree of the HUD window, as assistive technology reaches it.
@MainActor
struct HUDAccessibilityElement {
    /// The element itself: a view, or the node that SwiftUI makes for a view of the HUD.
    let object: NSObject
    let label: String?
    let value: String?
    let traits: UIAccessibilityTraits
    /// In screen coordinates.
    let frame: CGRect
    /// In screen coordinates.
    let activationPoint: CGPoint

    init(_ object: NSObject) {
        self.object = object
        label = object.accessibilityLabel
        value = object.accessibilityValue
        traits = object.accessibilityTraits
        frame = object.accessibilityFrame
        activationPoint = object.accessibilityActivationPoint
    }

    /// The label, the value and the traits on one line: what a test pins and what a failure prints.
    var signature: String {
        "label=\(Self.quoted(label)) value=\(Self.quoted(value)) traits=\(traits.names)"
    }

    private static func quoted(_ text: String?) -> String {
        text.map { "\"\($0)\"" } ?? "nil"
    }
}

extension [HUDAccessibilityElement] {
    /// Whether each element follows the one before it in reading order: lower on the screen, or on the
    /// same row and further to the right.
    var areInReadingOrder: Bool {
        zip(self, dropFirst()).allSatisfy { previous, next in
            let sameRow = abs(next.frame.minY - previous.frame.minY) <= 1
            return next.frame.minY > previous.frame.minY + 1 || (sameRow && next.frame.minX >= previous.frame.minX)
        }
    }
}

extension UIAccessibilityTraits {
    /// The names of the traits that are set, such as `button+updatesFrequently`, or `none`.
    var names: String {
        let known: [(UIAccessibilityTraits, String)] = [
            (.button, "button"), (.link, "link"), (.image, "image"), (.staticText, "staticText"),
            (.header, "header"), (.updatesFrequently, "updatesFrequently"), (.selected, "selected"),
            (.notEnabled, "notEnabled"), (.adjustable, "adjustable"), (.summaryElement, "summaryElement"),
            (.searchField, "searchField"), (.keyboardKey, "keyboardKey"), (.playsSound, "playsSound"),
            (.startsMediaSession, "startsMediaSession"), (.allowsDirectInteraction, "allowsDirectInteraction"),
            (.causesPageTurn, "causesPageTurn"), (.tabBar, "tabBar")
        ]
        let found = known.filter { contains($0.0) }.map(\.1)
        let rest = rawValue & ~known.reduce(0) { $0 | $1.0.rawValue }
        let unknown = rest == 0 ? [] : ["0x" + String(rest, radix: 16)]
        let all = found + unknown
        return all.isEmpty ? "none" : all.joined(separator: "+")
    }
}

// MARK: - The walk

/// The walk over the accessibility tree that assistive technology makes: the elements a container hands
/// out, and the views under a view that hands out none.
@MainActor
enum HUDAccessibilityTree {
    /// The elements under `root`, in the order the containers hand them out.
    static func elements(in root: UIView) -> [HUDAccessibilityElement] {
        var found: [NSObject] = []
        collect(root, into: &found)
        return found.map(HUDAccessibilityElement.init)
    }

    /// The container of an element: the next object up the accessibility tree.
    ///
    /// `accessibilityContainer` is not visible on `NSObject` in Swift, and the nodes that SwiftUI makes are
    /// not `UIAccessibilityElement`s, so the property is asked for by its selector.
    static func container(of object: NSObject) -> AnyObject? {
        if let element = object as? UIAccessibilityElement {
            return element.accessibilityContainer as AnyObject?
        }
        return object.perform(NSSelectorFromString("accessibilityContainer"))?.takeUnretainedValue()
    }

    /// One object of the walk up from an element, and whether it handled the escape.
    struct EscapeStep {
        let object: AnyObject
        let handled: Bool
    }

    /// Calls `accessibilityPerformEscape()` on `element` and then on each object above it, the containers
    /// of an element first and the superviews of a view after, until one returns `true`.
    ///
    /// This is a model of how VoiceOver routes the escape gesture, from the focused element up through
    /// its ancestors. VoiceOver itself does not run on the Simulator, so the routing is not observed.
    static func escapeChain(from element: NSObject) -> [EscapeStep] {
        var steps: [EscapeStep] = []
        var current: AnyObject? = element
        while let object = current, steps.count < 32 {
            let handled = (object as? NSObject)?.accessibilityPerformEscape() ?? false
            steps.append(EscapeStep(object: object, handled: handled))
            if handled { break }
            if let view = object as? UIView {
                current = view.superview
            } else if let node = object as? NSObject {
                current = container(of: node)
            } else {
                current = nil
            }
        }
        return steps
    }

    private static func collect(_ object: Any, into found: inout [NSObject]) {
        guard let object = object as? NSObject else { return }
        if let view = object as? UIView, view.isHidden || view.accessibilityElementsHidden {
            return
        }
        if object.isAccessibilityElement {
            found.append(object)
            return
        }
        children(of: object).forEach { collect($0, into: &found) }
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

// MARK: - The look and the state

/// How the HUD looks in a test: the card of every release so far, or the accessible card at the largest
/// accessibility text size.
enum HUDAccessibilityLayout {
    case standard
    case accessible

    @MainActor
    var provider: AnyDMLoadingViewProvider {
        switch self {
        case .standard: DefaultDMLoadingViewProvider().eraseToAnyViewProvider()
        case .accessible: DefaultDMLoadingViewProvider(appearance: .accessible).eraseToAnyViewProvider()
        }
    }

    var sizeCategory: UIContentSizeCategory {
        switch self {
        case .standard: .large
        case .accessible: .accessibilityExtraExtraExtraLarge
        }
    }
}

/// What the retry action of a failure counts.
@MainActor
final class RetryCounter {
    private(set) var count = 0

    func record() {
        count += 1
    }
}

/// The states a HUD shows.
enum HUDShownState {
    case loading
    case success
    case failure
    case failureWithRetry

    @MainActor
    func loadableState(layout: HUDAccessibilityLayout, retries: RetryCounter) -> DMLoadableType {
        let provider = layout.provider
        let error = DMAppError.custom("The server did not answer.")
        switch self {
        case .loading: return .loading(provider: provider)
        case .success: return .success("Saved", provider: provider)
        case .failure: return .failure(error: error, provider: provider)
        case .failureWithRetry:
            return .failure(error: error, provider: provider, onRetry: DMButtonAction { retries.record() })
        }
    }
}

// MARK: - The hosted HUD

/// A HUD that the real presenter shows in a real window of a window scene, for a test to read.
@MainActor
final class HostedHUD {
    let manager: DMLoadingManagerMain
    let retries: RetryCounter
    let scene: UIWindowScene
    private let presenter: any HUDOverlayPresenting
    private let probe: UIWindow

    fileprivate init(
        manager: DMLoadingManagerMain,
        retries: RetryCounter,
        scene: UIWindowScene,
        presenter: any HUDOverlayPresenting,
        probe: UIWindow
    ) {
        self.manager = manager
        self.retries = retries
        self.scene = scene
        self.presenter = presenter
        self.probe = probe
    }

    /// The window of the HUD.
    var window: DMPassThroughWindow? {
        scene.windows.compactMap { $0 as? DMPassThroughWindow }.first
    }

    var elements: [HUDAccessibilityElement] {
        window.map { HUDAccessibilityTree.elements(in: $0) } ?? []
    }

    var signatures: [String] {
        elements.map(\.signature)
    }

    func element(labeled label: String) -> HUDAccessibilityElement? {
        elements.first { $0.label == label }
    }

    /// Whether the HUD window takes a touch at its centre.
    var takesTouches: Bool {
        guard let window else { return false }
        return window.hitTest(CGPoint(x: window.bounds.midX, y: window.bounds.midY), with: nil) != nil
    }

    func remove() {
        presenter.dismiss()
        probe.isHidden = true
    }
}

@MainActor
extension XCTestCase {
    /// Shows `shown` in a HUD in a window scene, with the accessibility automation on, and waits until the
    /// accessibility tree of the HUD window has its elements.
    ///
    /// The package tests run in a process with no connected scene. A window made by `UIWindow(frame:)`
    /// belongs to a scene of its own, which the real presenter uses as it uses the scene of an app.
    ///
    /// - Returns: The hosted HUD, or `nil` when the test has failed already: the automation cannot be
    ///   switched on, or the tree stayed empty.
    func makeHostedHUD(
        showing shown: HUDShownState,
        layout: HUDAccessibilityLayout = .standard,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HostedHUD? {
        guard turnOnAccessibilityAutomation(file: file, line: line) else { return nil }
        let probe = UIWindow(frame: UIScreen.main.bounds)
        guard let scene = probe.windowScene else {
            XCTFail("A window made by UIWindow(frame:) belongs to no window scene.", file: file, line: line)
            return nil
        }
        let retries = RetryCounter()
        let manager = DMLoadingManagerMain(
            state: shown.loadableState(layout: layout, retries: retries),
            settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600))
        )
        let presenter = scene.makeHUDPresenter()
        presenter.present(manager)
        let hud = HostedHUD(manager: manager, retries: retries, scene: scene, presenter: presenter, probe: probe)
        addTeardownBlock { [weak hud] in
            hud?.remove()
        }
        guard waitForTree(of: hud) else {
            XCTFail(
                "The accessibility tree of the HUD window stayed empty with the automation on.",
                file: file,
                line: line
            )
            return nil
        }
        hud.window?.traitOverrides.preferredContentSizeCategory = layout.sizeCategory
        guard waitForTree(of: hud) else {
            XCTFail("The accessibility tree of the HUD window is empty after the text size changed.", file: file, line: line)
            return nil
        }
        return hud
    }

    /// Turns the run loop until `condition` holds, or `timeout` seconds pass.
    func turnRunLoop(until condition: @autoclosure () -> Bool, timeout: TimeInterval = 10) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition(), Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.02))
        }
        return condition()
    }

    /// Turns the run loop for a fixed time, for a change that must not happen to be waited for.
    func turnRunLoop(for seconds: TimeInterval) {
        RunLoop.current.run(until: Date().addingTimeInterval(seconds))
    }

    /// Waits until the HUD has elements and their number has not changed for a short while.
    private func waitForTree(of hud: HostedHUD) -> Bool {
        guard turnRunLoop(until: !hud.elements.isEmpty) else { return false }
        var count = hud.elements.count
        for _ in 0..<50 {
            turnRunLoop(for: 0.1)
            let now = hud.elements.count
            if now == count { return now > 0 }
            count = now
        }
        return count > 0
    }
}
