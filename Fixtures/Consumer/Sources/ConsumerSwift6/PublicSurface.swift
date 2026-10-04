import SwiftUI
import DMUnLoader

// Symbols a consumer can reach today without importing anything else. Each line pins one
// part of the public contract that lives on a type the package does not own.
@MainActor
func publicSurfaceInUse() {
    let optional: Int? = 1
    _ = optional.isSomeValue()
    _ = (try? optional.unwrapValue()) != nil
    _ = Set<EdgeInsets>()
    let error: any DMError = NSError(domain: "consumer", code: 1)
    _ = error
    let color: Color? = nil
    _ = Text("text").foregroundStyle(color)
    _ = DMButtonAction { }
}
