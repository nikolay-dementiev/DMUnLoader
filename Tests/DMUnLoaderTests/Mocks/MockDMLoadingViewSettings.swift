//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUICore
@testable import DMUnLoader

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
