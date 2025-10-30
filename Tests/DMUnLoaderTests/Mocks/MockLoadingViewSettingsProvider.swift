//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
@testable import DMUnLoader

struct MockLoadingViewSettingsProvider: DMProgressViewSettings {
    var frameGeometrySize: CGSize = CGSize(width: 200,
                                           height: 200)
    
    var loadingTextProperties: ProgressTextProperties = .init(
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
    
    var loadingContainerBackgroundColor: Color = .white
}
