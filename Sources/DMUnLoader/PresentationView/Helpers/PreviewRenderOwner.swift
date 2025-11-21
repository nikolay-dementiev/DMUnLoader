//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

struct PreviewRenderOwner<Content: View>: View {
    @ViewBuilder let content: Content
    
    init(_ content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Group {
            content
        }
        .padding(15)
        .background(Color.gray.opacity(0.8))
        .cornerRadius(10)
        .padding(15)
    }
}
