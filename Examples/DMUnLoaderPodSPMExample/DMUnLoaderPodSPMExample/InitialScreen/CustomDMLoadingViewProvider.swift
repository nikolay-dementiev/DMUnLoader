//
//  DMUnLoaderPodExample
//
//  Created by Mykola Dementiev
//

import SwiftUI
import DMUnLoader

/// A custom implementation of `DMLoadingViewProvider` that provides custom loading and error views.
/// This class also defines settings for the `DMLoadingManager`, including success view configurations.
final class CustomDMLoadingViewProvider: DMLoadingViewProviderProtocol {
    
    public var id: UUID = UUID()
    
    /// The main color used for styling the loading and error views.
    /// This color is applied to text, icons, and buttons for consistency.
    private let mainColor: Color = .yellow
    
    /**
     Provides a custom loading view to display during loading states.
     
     - Returns: A `View` containing a `Text` label and a `ProgressView` styled with the `mainColor`.
       - The `Text` displays a loading message with specific padding, alignment, and opacity.
       - The `ProgressView` uses a circular style and is tinted with the `mainColor`.
       - The view is constrained to a fixed size (100x100 to 150x150) for consistent appearance.
     */
    @MainActor
    func getLoadingView() -> some View {
        VStack {
            Text("loading %$#")
                .lineLimit(2)
                .padding()
                .multilineTextAlignment(.center)
                .foregroundColor(mainColor.opacity(0.8))
                .layoutPriority(1)
            ProgressView()
                .controlSize(.large)
                .progressViewStyle(.circular) // .linear
                .tint(mainColor)
        }
        .frame(minWidth: 100,
               maxWidth: 150,
               minHeight: 100,
               maxHeight: 150)
        .fixedSize()
        .foregroundColor(.cyan)
    }
    
    /**
     Provides a custom error view to display when an error occurs.
     
     - Parameters:
       - error: The `Error` object representing the error that occurred.
       - onRetry: An optional `DMAction` to execute when the user chooses to retry the operation.
       - onClose: A required `DMAction` to execute when the user chooses to close the error view.
     
     - Returns: A `View` containing:
       - An icon (`Image`) styled with the `mainColor`.
       - Two `Text` labels: one for a generic error message and another for the error's localized description.
       - Buttons for "Close" and optionally "Retry," styled with the `mainColor`.
     */
    @MainActor
    func getErrorView(error: Error,
                      onRetry: DMAction?,
                      onClose: DMAction) -> some View {
        VStack {
            Image(systemName: "person.fill.questionmark")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(mainColor)
            
            Text("Some Error text")
                .foregroundColor(mainColor)
                .opacity(0.9)
                .multilineTextAlignment(.center)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            
            Text(error.localizedDescription)
                .foregroundColor(mainColor)
                .opacity(0.8)
                .multilineTextAlignment(.center)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            
            HStack {
                Button("Close this", action: onClose.simpleAction)
                    .padding()
                    .background(mainColor.opacity(0.7))
                    .cornerRadius(8)
                
                if let onRetry = onRetry {
                    Button("Retry this", action: onRetry.simpleAction)
                        .padding()
                        .background(mainColor.opacity(0.7))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    // MARK: - Settings
    
    /**
     Provides the settings for the `DMLoadingManager`.
     
     - Returns: A `CustomLoadingManagerSettings` instance that defines:
       - `autoHideDelay`: The duration after which the loading view automatically hides (4 seconds).
     */
    var loadingManagerSettings: DMLoadingManagerSettings { CustomLoadingManagerSettings() }
    
    /// A private struct defining custom settings for the `DMLoadingManager`.
    private struct CustomLoadingManagerSettings: DMLoadingManagerSettings {
        /// The delay after which the loading view automatically hides.
        var autoHideDelay: Duration = .seconds(4)
    }
    
    /**
     Provides the settings for the success view displayed after a successful operation.
     
     - Returns: A `DMSuccessDefaultViewSettings` instance with customized properties:
       - `successImageProperties`: Defines the foreground color of the success image using the `mainColor`.
     */
    var successViewSettings: DMSuccessViewSettings {
        DMSuccessDefaultViewSettings(successImageProperties: SuccessImageProperties(foregroundColor: mainColor.opacity(0.7)))
    }
}
