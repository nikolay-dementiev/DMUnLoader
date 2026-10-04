import XCTest

/// The resource bundle of the library in the running app, where the library looks up the
/// default texts of the HUD.
final class LibraryBundleTests: XCTestCase {

    func test_libraryBundle_inTheApp_holdsTheCompiledTable() throws {
        // Where the library looks for it: the resources and the bundle of the app, under the
        // name SwiftPM gives the bundle of the target.
        let places = [Bundle.main.resourceURL, Bundle.main.bundleURL].compactMap { $0 }
        let bundle = try XCTUnwrap(
            places.lazy.compactMap { Bundle(url: $0.appendingPathComponent("DMUnLoader_DMUnLoader.bundle")) }.first,
            "the app holds the resource bundle of the library where the library looks for it"
        )

        XCTAssertNotNil(
            bundle.path(forResource: "Localizable", ofType: "strings"),
            "the string catalog is compiled into a table, not copied as it is"
        )
    }
}
