//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMUnLoader

extension ProgressIndicatorProperties: Equatable {
    public static func == (lhs: ProgressIndicatorProperties, rhs: ProgressIndicatorProperties) -> Bool {
        lhs.size == rhs.size && lhs.tintColor == rhs.tintColor
    }
}

extension LoadingTextProperties: Equatable {
    public static func == (lhs: LoadingTextProperties, rhs: LoadingTextProperties) -> Bool {
        lhs.text == rhs.text &&
        lhs.alignment == rhs.alignment &&
        lhs.foregroundColor == rhs.foregroundColor &&
        lhs.font == rhs.font &&
        lhs.lineLimit == rhs.lineLimit &&
        lhs.linePadding == rhs.linePadding
    }
}

extension ErrorTextSettings: Equatable {
    public static func == (lhs: ErrorTextSettings, rhs: ErrorTextSettings) -> Bool {
        lhs.foregroundColor == rhs.foregroundColor &&
        lhs.multilineTextAlignment == rhs.multilineTextAlignment &&
        lhs.padding == rhs.padding
    }
}

extension ActionButtonSettings: Equatable {
    public static func == (lhs: ActionButtonSettings, rhs: ActionButtonSettings) -> Bool {
        lhs.text == rhs.text &&
        lhs.backgroundColor == rhs.backgroundColor &&
        lhs.cornerRadius == rhs.cornerRadius
    }
}

extension ErrorImageSettings: Equatable {
    public static func == (lhs: ErrorImageSettings, rhs: ErrorImageSettings) -> Bool {
        lhs.image == rhs.image &&
        lhs.foregroundColor == rhs.foregroundColor &&
        lhs.frameSize == rhs.frameSize
    }
}

extension CustomSizeViewSettings: Equatable {
    public static func == (lhs: CustomSizeViewSettings, rhs: CustomSizeViewSettings) -> Bool {
        lhs.width == rhs.width &&
        lhs.height == rhs.height &&
        lhs.alignment == rhs.alignment
    }
}

extension SuccessImageProperties: Equatable {
    public static func == (lhs: SuccessImageProperties, rhs: SuccessImageProperties) -> Bool {
        lhs.image == rhs.image &&
        lhs.frame == rhs.frame &&
        lhs.foregroundColor == rhs.foregroundColor
    }
}

extension SuccessTextProperties: Equatable {
    public static func == (lhs: SuccessTextProperties, rhs: SuccessTextProperties) -> Bool {
        lhs.text == rhs.text &&
        lhs.foregroundColor == rhs.foregroundColor
    }
}

extension DMLoadingDefaultViewSettings: Equatable {
    public static func == (lhs: DMLoadingDefaultViewSettings, rhs: DMLoadingDefaultViewSettings) -> Bool {
        lhs.loadingTextProperties == rhs.loadingTextProperties &&
        lhs.progressIndicatorProperties == rhs.progressIndicatorProperties &&
        lhs.loadingContainerForegroundColor == rhs.loadingContainerForegroundColor &&
        lhs.frameGeometrySize == rhs.frameGeometrySize
    }
}

extension DMErrorDefaultViewSettings: Equatable {
    public static func == (lhs: DMErrorDefaultViewSettings, rhs: DMErrorDefaultViewSettings) -> Bool {
        lhs.errorText == rhs.errorText &&
        lhs.actionButtonCloseSettings == rhs.actionButtonCloseSettings &&
        lhs.actionButtonRetrySettings == rhs.actionButtonRetrySettings &&
        lhs.errorTextSettings == rhs.errorTextSettings &&
        lhs.errorImageSettings == rhs.errorImageSettings
    }
}

extension DMSuccessDefaultViewSettings: Equatable {
    public static func == (lhs: DMSuccessDefaultViewSettings, rhs: DMSuccessDefaultViewSettings) -> Bool {
        lhs.successImageProperties == rhs.successImageProperties &&
        lhs.successTextProperties == rhs.successTextProperties
    }
}
