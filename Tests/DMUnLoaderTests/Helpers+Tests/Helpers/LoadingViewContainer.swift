//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

struct LoadingViewContainer<Content: View>: View {
    @ViewBuilder var overlayView: Content
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
            
            overlayView
                .padding(15)
                .background(Color.gray.opacity(0.8))
                .cornerRadius(10)
                .scaleEffect(1)
        }
    }
}
