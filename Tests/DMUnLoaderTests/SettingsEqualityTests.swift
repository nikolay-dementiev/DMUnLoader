//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import XCTest
import DMUnLoader

/// Settings values are equal when every field that changes what is shown is equal. An `id`
/// is such a field: two values made with the default `id` stay different.
final class SettingsEqualityTests: XCTestCase {

    // MARK: - Fields that change what is shown

    func test_actionButtonSettings_sameIDDifferentText_areNotEqual() {
        let id = UUID()

        XCTAssertNotEqual(ActionButtonSettings(id: id, text: "Close"), ActionButtonSettings(id: id, text: "Dismiss"))
    }

    func test_errorImageSettings_differentImages_areNotEqual() {
        XCTAssertNotEqual(
            ErrorImageSettings(image: Image(systemName: "star")),
            ErrorImageSettings(image: Image(systemName: "circle"))
        )
    }

    func test_errorDefaultSettings_sameButtonsDifferentImages_areNotEqual() {
        let close = ActionButtonSettings(text: "Close")
        let retry = ActionButtonSettings(text: "Retry")

        XCTAssertNotEqual(
            DMErrorDefaultViewSettings(
                actionButtonCloseSettings: close,
                actionButtonRetrySettings: retry,
                errorImageSettings: ErrorImageSettings(image: Image(systemName: "star"))
            ),
            DMErrorDefaultViewSettings(
                actionButtonCloseSettings: close,
                actionButtonRetrySettings: retry,
                errorImageSettings: ErrorImageSettings(image: Image(systemName: "circle"))
            )
        )
    }

    func test_successImageProperties_sameIDDifferentImages_areNotEqual() {
        let id = UUID()

        XCTAssertNotEqual(
            SuccessImageProperties(id: id, image: Image(systemName: "star")),
            SuccessImageProperties(id: id, image: Image(systemName: "circle"))
        )
    }

    func test_successTextProperties_differentAlignment_areNotEqual() {
        XCTAssertNotEqual(SuccessTextProperties(alignment: .leading), SuccessTextProperties(alignment: .trailing))
    }

    func test_successDefaultSettings_sameImageDifferentTextAlignment_areNotEqual() {
        let image = SuccessImageProperties()

        XCTAssertNotEqual(
            DMSuccessDefaultViewSettings(
                successImageProperties: image,
                successTextProperties: SuccessTextProperties(alignment: .leading)
            ),
            DMSuccessDefaultViewSettings(
                successImageProperties: image,
                successTextProperties: SuccessTextProperties(alignment: .trailing)
            )
        )
    }

    func test_customViewSize_differentAlignment_areNotEqual() {
        XCTAssertNotEqual(
            CustomViewSize(width: 10, height: 10, alignment: .top),
            CustomViewSize(width: 10, height: 10, alignment: .bottom)
        )
    }

    func test_progressDefaultSettings_differentFrameGeometrySize_areNotEqual() {
        XCTAssertNotEqual(
            DMProgressViewDefaultSettings(frameGeometrySize: CGSize(width: 300, height: 300)),
            DMProgressViewDefaultSettings(frameGeometrySize: CGSize(width: 300, height: 200))
        )
    }

    // MARK: - Identities

    func test_errorDefaultSettings_twoDefaultValues_areNotEqual() {
        XCTAssertNotEqual(
            DMErrorDefaultViewSettings(),
            DMErrorDefaultViewSettings(),
            "each default value makes its buttons with an id of their own"
        )
    }

    func test_successDefaultSettings_twoDefaultValues_areNotEqual() {
        XCTAssertNotEqual(
            DMSuccessDefaultViewSettings(),
            DMSuccessDefaultViewSettings(),
            "each default value makes its image properties with an id of their own"
        )
    }

    // MARK: - Hashing

    func test_settingsValues_equalValues_haveEqualHashValues() {
        let id = UUID()
        let close = ActionButtonSettings(id: id, text: "Close")
        let image = SuccessImageProperties(id: id)

        XCTAssertEqual(
            close.hashValue,
            ActionButtonSettings(id: id, text: "Close").hashValue,
            "equal button settings hash alike"
        )
        XCTAssertEqual(
            ErrorImageSettings(image: Image(systemName: "star")).hashValue,
            ErrorImageSettings(image: Image(systemName: "star")).hashValue,
            "equal image settings hash alike"
        )
        XCTAssertEqual(
            DMErrorDefaultViewSettings(actionButtonCloseSettings: close, actionButtonRetrySettings: close).hashValue,
            DMErrorDefaultViewSettings(actionButtonCloseSettings: close, actionButtonRetrySettings: close).hashValue,
            "equal error settings hash alike"
        )
        XCTAssertEqual(image.hashValue, SuccessImageProperties(id: id).hashValue, "equal success images hash alike")
        XCTAssertEqual(
            SuccessTextProperties(alignment: .leading).hashValue,
            SuccessTextProperties(alignment: .leading).hashValue,
            "equal success texts hash alike"
        )
        XCTAssertEqual(
            DMSuccessDefaultViewSettings(successImageProperties: image).hashValue,
            DMSuccessDefaultViewSettings(successImageProperties: image).hashValue,
            "equal success settings hash alike"
        )
        XCTAssertEqual(
            CustomViewSize(width: 1, height: 2, alignment: .top).hashValue,
            CustomViewSize(width: 1, height: 2, alignment: .top).hashValue,
            "equal sizes hash alike"
        )
        XCTAssertEqual(
            DMProgressViewDefaultSettings().hashValue,
            DMProgressViewDefaultSettings().hashValue,
            "equal progress settings hash alike"
        )
    }
}
