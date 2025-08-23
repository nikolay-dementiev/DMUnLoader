//
//  MultipleScenesWithinSwiftUI-MVP
//
//  Created by Mykola Dementiev
//

import SwiftUI

@main
struct MultipleScenesWithinSwiftUI_MVPApp: App {
    @StateObject var hudState = HudState()
    @UIApplicationDelegateAdaptor var delegate: MVPAppDelegate
    
    var body: some Scene {
        WindowGroup {
            MainSceneView(hudState: hudState)
        }
    }
}
