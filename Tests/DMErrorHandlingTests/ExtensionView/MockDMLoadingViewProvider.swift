//
//  MockDMLoadingViewProvider.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 13.02.2025.
//

import SwiftUI
import XCTest
import Combine
@testable import DMErrorHandling

final class MockDMLoadingViewProvider: DMLoadingViewProviderProtocol {
    typealias LoadingViewType = Text
    typealias ErrorViewType = Text
    typealias SuccessViewType = Text
    
    public var id: UUID = UUID()
    
    @MainActor
    func getLoadingView() -> LoadingViewType {
        Text("Mock Loading View")
    }

    @MainActor
    func getErrorView(error: Error, onRetry: DMAction?, onClose: DMAction) -> ErrorViewType {
        Text("Mock Error View")
    }

    @MainActor
    func getSuccessView(object: DMLoadableTypeSuccess) -> SuccessViewType {
        Text("Mock Success View")
    }

    var loadingManagerSettings: DMLoadingManagerSettings {
        MockDMLoadingManagerSettings(autoHideDelay: .seconds(2))
    }

    var loadingViewSettings: DMLoadingViewSettings {
        MockDMLoadingViewSettings()
    }

    var errorViewSettings: DMErrorViewSettings {
        MockDMErrorViewSettings()
    }

    var successViewSettings: DMSuccessViewSettings {
        MockDMSuccessViewSettings()
    }
}

struct MockDMLoadingViewSettings: DMLoadingViewSettings {
    var loadingTextProperties: LoadingTextProperties = LoadingTextProperties(
        text: "Mock Loading...",
        alignment: .center,
        foregroundColor: .black,
        font: .body,
        lineLimit: 3,
        linePadding: EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
    )
    
    var progressIndicatorProperties: ProgressIndicatorProperties = ProgressIndicatorProperties(
        size: .large,
        tintColor: .blue
    )
    
    var loadingContainerForegroundColor: Color = .white
    
    var frameGeometrySize: CGSize = CGSize(width: 200, height: 200)
}

struct MockDMErrorViewSettings: DMErrorViewSettings {
    var errorText: String? = "Mock Error Occurred"
    
    var actionButtonCloseSettings: ActionButtonSettings = ActionButtonSettings(
        text: "Close",
        backgroundColor: .red,
        cornerRadius: 8
    )
    
    var actionButtonRetrySettings: ActionButtonSettings = ActionButtonSettings(
        text: "Retry",
        backgroundColor: .green,
        cornerRadius: 8
    )
    
    var errorTextSettings: ErrorTextSettings = ErrorTextSettings(
        foregroundColor: .white,
        multilineTextAlignment: .center,
        padding: EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
    )
    
    var errorImageSettings: ErrorImageSettings = ErrorImageSettings(
        image: Image(systemName: "exclamationmark.circle.fill"),
        foregroundColor: .red,
        frameSize: CustomSizeView(width: 50, height: 50)
    )
}

struct MockDMSuccessViewSettings: DMSuccessViewSettings {
    var successImageProperties: SuccessImageProperties = SuccessImageProperties(
        image: Image(systemName: "checkmark.circle.fill"),
        frame: CustomSizeView(width: 50, height: 50),
        foregroundColor: .green
    )
    
    var successTextProperties: SuccessTextProperties = SuccessTextProperties(
        text: "Mock Success!",
        foregroundColor: .white
    )
}
