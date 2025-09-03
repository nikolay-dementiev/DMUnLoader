//
//  MultipleScenesWithinSwiftUI-SDK
//
//  Created by Mykola Dementiev
//

import SwiftUI

public protocol MP_Scene {
    var hudState: HudState { get }
}

public struct MultipleScenesWithinSwiftUI_SDK_Scene<Body: Scene>: Scene, MP_Scene {
    
    @StateObject public var hudState = HudState()
//    @UIApplicationDelegateAdaptor var delegate: MVPAppDelegate
    
    private let _body: (HudState) -> Body
    
    public init(@SceneBuilder body: @escaping (HudState) -> Body) {
        self._body = body
    }
    
    public var body: Body {
        _body(hudState)
    }
}
