//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

/// The text that describes a state for logs, read through the public interface only.
@MainActor
final class DMLoadableTypeDiagnosticDescriptionTests: XCTestCase {

    func test_diagnosticDescription_loading_isLoading() {
        let sut = DMLoadableType.loading(provider: Self.provider)

        XCTAssertEqual(sut.diagnosticDescription, "Loading")
    }

    func test_diagnosticDescription_failureWithPlainError_isErrorWithTheErrorInBackticks() {
        let sut = DMLoadableType.failure(error: PlainFailure.offline, provider: Self.provider)

        XCTAssertEqual(sut.diagnosticDescription, "Error: `offline`")
    }

    func test_diagnosticDescription_failureWithLocalizedError_usesTheErrorNotItsLocalizedDescription() {
        let sut = DMLoadableType.failure(error: ReadableFailure.unreadable, provider: Self.provider)

        XCTAssertEqual(
            sut.diagnosticDescription,
            "Error: `unreadable`",
            "the text is the error as it prints, not the 'Readable' of its localized description"
        )
    }

    func test_diagnosticDescription_success_isSuccessWithTheMessageInBackticks() {
        let sut = DMLoadableType.success("Saved", provider: Self.provider)

        XCTAssertEqual(sut.diagnosticDescription, "Success: `Saved`")
    }

    func test_diagnosticDescription_none_isNone() {
        XCTAssertEqual(DMLoadableType.none.diagnosticDescription, "None")
    }

    func test_diagnosticDescription_inEveryState_isWhatRawValueReturns() {
        let states: [(name: String, state: DMLoadableType)] = [
            ("loading", .loading(provider: Self.provider)),
            ("failure", .failure(error: PlainFailure.offline, provider: Self.provider)),
            ("success", .success("Saved", provider: Self.provider)),
            ("none", .none)
        ]

        for (name, state) in states {
            XCTAssertEqual(
                state.diagnosticDescription,
                state.rawValue,
                "the \(name) state has one text through diagnosticDescription and another through rawValue"
            )
        }
    }

    // MARK: - Helpers

    private static var provider: AnyDMLoadingViewProvider {
        DefaultDMLoadingViewProvider().eraseToAnyViewProvider()
    }
}

private enum PlainFailure: Error {
    case offline
}

private enum ReadableFailure: LocalizedError {
    case unreadable

    var errorDescription: String? { "Readable" }
}
