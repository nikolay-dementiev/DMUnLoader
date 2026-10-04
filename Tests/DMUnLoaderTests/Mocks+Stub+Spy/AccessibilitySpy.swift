//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMUnLoader

/// Records, in order, what a HUD asks of assistive technology and of the content underneath.
///
/// The focused element is an element or `nil`, as `UIAccessibility.focusedElement(using:)`
/// returns "the element that has the specified assistive technology's focus", or `nil` when
/// none has it.
@MainActor
final class AccessibilitySpy: AccessibilityAnnouncer, ContentUnderneathHiding {
    enum Event: Equatable {
        case readFocus
        case hide
        case restore
        case screenChanged(focusing: ObjectIdentifier?)
    }

    private(set) var events: [Event] = []
    var focused: AnyObject?
    var focusedElementIsOnScreen = true

    var focusedElement: AnyObject? {
        events.append(.readFocus)
        return focused
    }

    func isOnScreen(_ element: AnyObject) -> Bool {
        focusedElementIsOnScreen
    }

    func screenChanged(focusing element: AnyObject?) {
        events.append(.screenChanged(focusing: element.map(ObjectIdentifier.init)))
    }

    func hideContentUnderneath() {
        events.append(.hide)
    }

    func restoreContentUnderneath() {
        events.append(.restore)
    }
}
