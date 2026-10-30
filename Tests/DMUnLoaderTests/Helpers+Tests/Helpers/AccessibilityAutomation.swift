//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import Darwin
import XCTest

/// The accessibility automation service, switched on inside the test process.
///
/// SwiftUI builds the accessibility tree of a view only while an assistive technology or the automation
/// service is on. XCUITest turns the service on; a test of the package does not run under it, and
/// without it the tree of a hosted HUD has no element. The tests that read the tree turn the service on
/// themselves, and off again when the test ends.
///
/// The switch is a function of the system library `libAccessibility`. It is not documented, so it is
/// found at run time and never linked: a system that does not offer it ends the tests that need it with a
/// message that names the switch, not with a crash and not with a skip. This is test code only. Nothing
/// of the library and nothing of the example uses it.
@MainActor
enum AccessibilityAutomation {
    private static let libraryPath = "/usr/lib/libAccessibility.dylib"
    private static let setterName = "_AXSSetAutomationEnabled"
    private static let getterName = "_AXSAutomationEnabled"

    /// Switches the automation on.
    ///
    /// - Parameter libraryPath: The system library to look the switch up in. Tests give another path to
    ///   see the failure.
    /// - Returns: `nil` when the automation is on, otherwise why it could not be switched on.
    static func turnOn(libraryPath: String = AccessibilityAutomation.libraryPath) -> String? {
        set(true, libraryPath: libraryPath)
    }

    /// Switches the automation off, as it was before the test.
    static func turnOff(libraryPath: String = AccessibilityAutomation.libraryPath) {
        _ = set(false, libraryPath: libraryPath)
    }

    /// Whether the system reports the automation as on, or `nil` when it does not say.
    static func isOn(libraryPath: String = AccessibilityAutomation.libraryPath) -> Bool? {
        guard let handle = dlopen(libraryPath, RTLD_NOW), let symbol = dlsym(handle, getterName) else {
            return nil
        }
        typealias Getter = @convention(c) () -> Bool
        return unsafeBitCast(symbol, to: Getter.self)()
    }

    private static func set(_ on: Bool, libraryPath: String) -> String? {
        guard let handle = dlopen(libraryPath, RTLD_NOW) else {
            return failure("the library \(libraryPath) cannot be opened")
        }
        guard let symbol = dlsym(handle, setterName) else {
            return failure("the library \(libraryPath) has no function \(setterName)")
        }
        typealias Setter = @convention(c) (Bool) -> Void
        unsafeBitCast(symbol, to: Setter.self)(on)
        return nil
    }

    private static func failure(_ reason: String) -> String {
        """
        The accessibility automation cannot be switched on: \(reason). The tests that read the \
        accessibility tree of the HUD need it, because SwiftUI builds that tree only while the \
        automation service is on. This test fails and does not skip, so that a system that drops the \
        switch is seen; the switch lives in AccessibilityAutomation.swift.
        """
    }
}

@MainActor
extension XCTestCase {
    /// Switches the accessibility automation on for this test and off again when the test ends.
    ///
    /// - Returns: Whether the automation is on. When it is not, the test has failed with a message that
    ///   names the switch, and the caller returns.
    @discardableResult
    func turnOnAccessibilityAutomation(file: StaticString = #filePath, line: UInt = #line) -> Bool {
        if let reason = AccessibilityAutomation.turnOn() {
            XCTFail(reason, file: file, line: line)
            return false
        }
        addTeardownBlock {
            AccessibilityAutomation.turnOff()
        }
        return true
    }
}
