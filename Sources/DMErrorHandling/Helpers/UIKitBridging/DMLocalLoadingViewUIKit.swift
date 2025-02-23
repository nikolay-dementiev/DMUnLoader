//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUI
import UIKit

open class DMLocalLoadingViewUIKit<UIKitView: UIView,
                                    Provider: DMLoadingViewProviderProtocol>: UIView {
    private typealias HostingContent = DMLocalLoadingView<DMWrappedViewUIKit<UIKitView>, Provider>
    private let hostingController: UIHostingController<AnyView>
    
    public weak private(set) var loadingManager: DMLoadingManager?
    
    public init(provider: Provider,
                innerView: UIKitView,
                manager: GlobalLoadingStateManager) {
        let swiftUIView = Self.makeSwiftUIView(provider: provider, view: innerView)
        self.loadingManager = swiftUIView.getLoadingManager()
        
        hostingController = UIHostingController(rootView:
                                                    AnyView(swiftUIView
                                                        .environment(\.globalLoadingManager, manager)
                                                    ))
        super.init(frame: .zero)
        
        self.loadingManager = swiftUIView.getLoadingManager()
        setupUI()
    }
    
    required public init?(coder: NSCoder) {
        print("init(coder:) has not been implemented")
        return nil
    }

    private func setupUI() {
        guard let view = hostingController.view else { return }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private static func makeSwiftUIView(provider: Provider, view: UIKitView) -> HostingContent {
        let newView = DMLocalLoadingView(provider: provider) {
            DMWrappedViewUIKit(uiView: view)
        }
        
        return newView
    }
}
