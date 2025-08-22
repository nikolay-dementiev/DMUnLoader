//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMUnLoader

enum ViewSettingsHelper {
    static func makeLoadingCustomSettings() -> DMLoadingDefaultViewSettings {
        DMLoadingDefaultViewSettings(
            loadingTextProperties: LoadingTextProperties(
                text: "Processing...",
                alignment: .leading,
                foregroundColor: .orange,
                font: .title3
            ),
            progressIndicatorProperties: ProgressIndicatorProperties(
                tintColor: .green
            )
        )
    }
}


