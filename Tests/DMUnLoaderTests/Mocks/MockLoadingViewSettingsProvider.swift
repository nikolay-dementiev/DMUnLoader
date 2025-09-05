//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUICore
@testable import DMUnLoader

struct MockLoadingViewSettingsProvider: DMLoadingViewSettings {
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
