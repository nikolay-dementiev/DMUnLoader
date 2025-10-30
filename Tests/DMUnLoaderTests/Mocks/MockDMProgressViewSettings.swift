//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
@testable import DMUnLoader

struct MockDMProgressViewSettings: DMProgressViewSettings {
    var loadingTextProperties: ProgressTextProperties = ProgressTextProperties(
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
    
    var loadingContainerBackgroundColor: Color = .white
    
    var frameGeometrySize: CGSize = CGSize(width: 200, height: 200)
}

extension MockDMProgressViewSettings: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(loadingTextProperties)
        hasher.combine(progressIndicatorProperties)
        hasher.combine(loadingContainerBackgroundColor)
        hasher.combine(frameGeometrySize)
    }
}
