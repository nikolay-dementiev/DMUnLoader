//
//  ContentViewDefaultSettingsUIKit.swift
//  DMErrorHandlingPodExample
//
//  Created by Nikolay Dementiev on 04.02.2025.
//

import UIKit
import DMErrorHandling

final class ContentViewDefaultSettingsUIKit<CV: LoadingContentViewUIKit, LVP: DMLoadingViewProvider>: DMLocalLoadingViewUIKit<CV, LVP> {
    
    override init(provider: LVP,
                  innerView: CV,
                  manager: GlobalLoadingStateManager) {
        super.init(provider: provider,
                   innerView: innerView,
                   manager: manager)
        
        innerView.loadingManager = self.loadingManager
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
