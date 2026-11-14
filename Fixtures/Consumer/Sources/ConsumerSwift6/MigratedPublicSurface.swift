import SwiftUI
import DMUnLoader

// The surface of PublicSurface.swift for a host that has moved to the replacements: no declaration
// that 2.0.0 removes appears here, so this file must keep compiling when it does.
struct InsetsKey: Hashable {
    let top: CGFloat
    let leading: CGFloat
    let bottom: CGFloat
    let trailing: CGFloat

    init(_ insets: EdgeInsets) {
        top = insets.top
        leading = insets.leading
        bottom = insets.bottom
        trailing = insets.trailing
    }
}

extension View {
    @ViewBuilder
    func foregroundStyleIfPresent<S: ShapeStyle>(_ style: S?) -> some View {
        if let style {
            foregroundStyle(style)
        } else {
            self
        }
    }
}

@MainActor
func migratedPublicSurfaceInUse() {
    let optional: Int? = 1
    _ = optional != nil
    if let unwrapped = optional {
        _ = unwrapped
    }
    _ = Set<InsetsKey>()
    let error: any Error = NSError(domain: "consumer", code: 1)
    _ = error
    let color: Color? = nil
    _ = Text("text").foregroundStyleIfPresent(color)
    _ = ProgressView().progressViewStyle(.circular)
    _ = DMButtonAction { }
    _ = DMLoadableType.none.diagnosticDescription
    let settings = DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(1))
    _ = DMLoadingManagerMain(state: .none, settings: settings)
    let provider: AnyDMLoadingViewProvider = DefaultDMLoadingViewProvider().eraseToAnyViewProvider()
    _ = provider
}
