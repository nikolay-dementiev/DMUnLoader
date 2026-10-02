import SwiftUI
import DMUnLoader


struct ExampleApp: App {
    @UIApplicationDelegateAdaptor private var delegate: DMAppDelegateType

    var body: some Scene {
        WindowGroup {
            DMRootLoadingView { loadingManager in
                ContentView(
                    loadingManager: loadingManager,
                    provider: DefaultDMLoadingViewProvider()
                )
            }
        }
    }
}

struct ContentView<
    LM: DMLoadingManager,
    Provider: DMLoadingViewProvider
>: View {
    let loadingManager: LM
    let provider: Provider

    var body: some View {
        VStack {
            Button("Show loading") {
                loadingManager.showLoading(provider: provider)
            }

            Button("Show success") {
                loadingManager.showSuccess("Data successfully loaded!", provider: provider)
            }
        }
    }
}
