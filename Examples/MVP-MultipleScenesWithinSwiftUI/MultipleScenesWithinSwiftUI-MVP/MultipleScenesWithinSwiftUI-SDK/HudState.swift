//
//  MultipleScenesWithinSwiftUI-MVP
//
//  Created by Mykola Dementiev
//

import Combine

final class HudState: ObservableObject {
  @Published var isPresented: Bool = false

  func show() {
    isPresented = true
  }
}
