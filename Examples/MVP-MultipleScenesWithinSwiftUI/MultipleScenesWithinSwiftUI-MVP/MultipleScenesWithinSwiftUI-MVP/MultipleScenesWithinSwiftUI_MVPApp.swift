//
//  MultipleScenesWithinSwiftUI-MVP
//
//  Created by Mykola Dementiev
//

import SwiftUI
import MPSwiftUI_SDK

@main
struct MultipleScenesWithinSwiftUI_MVPApp: App {
    @UIApplicationDelegateAdaptor var delegate: MVPAppDelegate
    
    var body: some Scene {
        MultipleScenesWithinSwiftUI_SDK_Scene { hudState in
            WindowGroup {
//                ContentView()
                AppMainSceneView(hudState: hudState)
            }
        }
    }
}
