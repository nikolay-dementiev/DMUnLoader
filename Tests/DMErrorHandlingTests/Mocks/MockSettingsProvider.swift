//
//  MockSettingsProvider.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 19.02.2025.
//

import SwiftUICore
@testable import DMErrorHandling

struct MockSettingsProvider: DMLoadingViewSettings {
    var frameGeometrySize: CGSize = CGSize(width: 200,
                                           height: 200)
    
    var loadingTextProperties: LoadingTextProperties = .init(
        text: "Loading...",
        foregroundColor: .blue,
        font: .system(size: 16),
        lineLimit: 1,
        linePadding: .init(top: 8,
                           leading: 8,
                           bottom: 8,
                           trailing: 8)
    )
    
    var progressIndicatorProperties: ProgressIndicatorProperties = .init(
        size: .regular,
        tintColor: .green
    )
    
    var loadingContainerForegroundColor: Color = .white
}
