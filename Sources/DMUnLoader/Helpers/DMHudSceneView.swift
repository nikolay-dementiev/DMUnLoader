//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

struct DMHudSceneView<LM: DMLoadingManager>: View {
    @ObservedObject var loadingManager: LM

    init(loadingManager: LM) {
        self.loadingManager = loadingManager
    }
    
    var body: some View {
        Color.clear
            .ignoresSafeArea(.all)
            .hudCenter(loadingManager: loadingManager) {
                DMLoadingView(loadingManager: loadingManager)
            }
    }
}

#Preview("Error") {
    let loadingManager = DMLoadingManagerMain(
        state: .failure(
            error: DMAppError.custom("Something went wrong"),
            provider: DefaultDMLoadingViewProvider()
                .eraseToAnyViewProvider(),
            onRetry: DMButtonAction({ _ in })
        ),
        settings: DMLoadingManagerDefaultSettings()
    )
    
    ZStack {
        // swiftlint:disable:next line_length
        Text("A wiki  is a form of hypertext publication on the internet which is collaboratively edited and managed by its audience directly through a web browser. A typical wiki contains multiple pages that can either be edited by the public or limited to use within an organization for maintaining its knowledge base. Its name derives from the first user-editable website called\nA wiki  is a form of hypertext publication on the internet which is collaboratively edited and managed by its audience directly through a web browser. A typical wiki contains multiple pages that can either be edited by the public or limited to use within an organization for maintaining its knowledge base. Its name derives from the first user-editable website called\nA wiki  is a form of hypertext publication on the internet which is collaboratively edited and managed by its audience directly through a web browser. A typical wiki contains multiple pages that can either be edited by the public or limited to use within an organization for maintaining its knowledge base. Its name derives from the first user-editable website called\nA wiki  is a form of hypertext publication on the internet which is collaboratively edited and managed by its audience directly through a web browser. A typical wiki contains multiple pages that can either be edited by the public or limited to use within an organization for maintaining its knowledge base. Its name derives from the first user-editable website called\nA wiki  is a form of hypertext publication on the internet which is collaboratively edited and managed by its audience directly through a web browser. A typical wiki contains multiple pages that can either be edited by the public or limited to use within an organization for maintaining its knowledge base. Its name derives from the first user-editable website called\n")
        
        DMHudSceneView(loadingManager: loadingManager)
    }.ignoresSafeArea()
}

#Preview("Loading") {
    let loadingManager = DMLoadingManagerMain(
        state: .loading(
            provider: DefaultDMLoadingViewProvider()
                .eraseToAnyViewProvider(),
        ),
        settings: DMLoadingManagerDefaultSettings()
    )
    
    DMHudSceneView(loadingManager: loadingManager)
}

#Preview("Success") {
    let loadingManager = DMLoadingManagerMain(
        state: .success(
            "Wow! All were done!",
            provider: DefaultDMLoadingViewProvider()
                .eraseToAnyViewProvider(),
        ),
        settings: DMLoadingManagerDefaultSettings()
    )
    
    DMHudSceneView(loadingManager: loadingManager)
}

#Preview("None") {
    let loadingManager = DMLoadingManagerMain(
        state: .none,
        settings: DMLoadingManagerDefaultSettings()
    )
    
    DMHudSceneView(loadingManager: loadingManager)
}
