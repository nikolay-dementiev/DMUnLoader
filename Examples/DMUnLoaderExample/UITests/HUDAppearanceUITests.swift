import XCTest

/// What the user sees while a HUD is shown: the window of the app and the window of the
/// HUD above it, as the system puts them together. Only a screenshot shows both, so the
/// dim and the blur of the backdrop are checked here and not in a test of a single view.
@MainActor
final class HUDAppearanceUITests: XCTestCase {
    nonisolated override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func test_failureHUD_shownOverContent_dimsAndBlursIt() throws {
        let app = launchForPicture()
        let content = app.buttons[DemoIdentifier.content]
        XCTAssertTrue(content.waitForExistence(timeout: Wait.launch), "the demo screen is shown")
        // The status bar shows the time, so only the area of the content is compared.
        let contentFrame = content.frame

        app.buttons[DemoIdentifier.showFailure].tap()
        XCTAssertTrue(app.buttons["Retry"].waitForExistence(timeout: Wait.screenChange), "the failure HUD is shown")

        let picture = try settledScreenshot(croppedTo: contentFrame)
        try ScreenshotReference.assertMatches(picture.image, named: "FailureHUD-\(picture.screen)")
    }

    func test_failureHUD_backdropDim_matchesReference() throws {
        try assertFailureHUDMatchesReference(named: "FailureHUD-dim", backdrop: "dim")
    }

    func test_failureHUD_backdropMaterial_matchesReference() throws {
        try assertFailureHUDMatchesReference(named: "FailureHUD-material", backdrop: "material")
    }

    func test_failureHUD_backdropClear_matchesReference() throws {
        try assertFailureHUDMatchesReference(named: "FailureHUD-clear", backdrop: "clear")
    }

    // MARK: - Helpers

    private func assertFailureHUDMatchesReference(named name: String, backdrop: String) throws {
        let app = launchForPicture(["--backdrop", backdrop])
        let content = app.buttons[DemoIdentifier.content]
        XCTAssertTrue(content.waitForExistence(timeout: Wait.launch), "the demo screen is shown")
        let contentFrame = content.frame

        app.buttons[DemoIdentifier.showFailure].tap()
        XCTAssertTrue(app.buttons["Retry"].waitForExistence(timeout: Wait.screenChange), "the failure HUD is shown")

        let picture = try settledScreenshot(croppedTo: contentFrame)
        try ScreenshotReference.assertMatches(picture.image, named: "\(name)-\(picture.screen)")
    }

    /// Launches the example as its references were recorded: light appearance, the default
    /// text size, English, and a failure that outlasts the test, so it cannot hide while the
    /// picture is taken. The appearance of the simulator is restored afterwards.
    private func launchForPicture(_ extraArguments: [String] = []) -> XCUIApplication {
        let device = XCUIDevice.shared
        let appearance = device.appearance
        device.appearance = .light
        addTeardownBlock { @MainActor in
            device.appearance = appearance
        }
        let app = XCUIApplication()
        app.launchArguments = [
            "--auto-hide", "600",
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryL",
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US"
        ] + extraArguments
        app.launch()
        return app
    }

    /// The HUD fades in, and the render server draws the blur after the window is on
    /// screen. A picture counts once three screenshots in a row are equal and at least
    /// one second lies between the first and the last of them.
    private func settledScreenshot(croppedTo frame: CGRect) throws -> (image: UIImage, screen: String) {
        var equalSince: Date?
        var previous: Data?
        var equalCount = 0
        for _ in 0..<40 {
            let screenshot = XCUIScreen.main.screenshot().image
            let cropped = try XCTUnwrap(crop(screenshot, to: frame), "the content area lies inside the screenshot")
            let data = try XCTUnwrap(cropped.pngData(), "the cropped screenshot can be encoded")
            if data == previous {
                equalCount += 1
            } else {
                equalCount = 1
                equalSince = Date()
                previous = data
            }
            if equalCount >= 3, let equalSince, Date().timeIntervalSince(equalSince) >= 1 {
                return (cropped, "\(Int(screenshot.size.width))x\(Int(screenshot.size.height))")
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.25))
        }
        throw ScreenshotError.neverSettled
    }

    private func crop(_ image: UIImage, to frame: CGRect) -> UIImage? {
        let pixels = CGRect(
            x: frame.minX * image.scale,
            y: frame.minY * image.scale,
            width: frame.width * image.scale,
            height: frame.height * image.scale
        ).integral
        return image.cgImage?.cropping(to: pixels).map {
            UIImage(cgImage: $0, scale: image.scale, orientation: image.imageOrientation)
        }
    }
}

private enum ScreenshotError: Error, CustomStringConvertible {
    case neverSettled

    var description: String {
        "the screen kept changing: no three screenshots in a row over a second were equal"
    }
}

/// Compares a screenshot with its recorded reference.
///
/// The snapshot library of the package tests cannot be linked into a UI test bundle: it
/// imports Swift Testing, which Xcode makes unavailable there.
@MainActor
enum ScreenshotReference {
    /// How far one colour channel of one pixel may be from its reference, out of 255.
    /// Every pixel has to be within it. Two runs on one machine give identical pictures;
    /// the margin is for another machine's GPU, which draws the blur. Measured on iOS 17.5
    /// and 26.5 with the defects this test exists for: without the blur 49 to 50 percent
    /// of the pixels are further off than this, without the dim 68 to 69 percent.
    static let channelTolerance = 16

    /// A missing reference is recorded on a developer's machine, and the test fails once.
    /// With `CI` set nothing is ever written: a missing reference is a failure.
    static var recordsMissingReferences: Bool {
        ProcessInfo.processInfo.environment["CI"] == nil
    }

    static func assertMatches(
        _ image: UIImage,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let reference = URL(fileURLWithPath: "\(file)")
            .deletingLastPathComponent()
            .appendingPathComponent("__Snapshots__", isDirectory: true)
            .appendingPathComponent("\(name)_ios\(version.majorVersion)_\(version.minorVersion).png")

        guard FileManager.default.fileExists(atPath: reference.path) else {
            return try recordMissingReference(image, at: reference, file: file, line: line)
        }

        let recorded = try XCTUnwrap(
            UIImage(contentsOfFile: reference.path),
            "the reference can be read",
            file: file,
            line: line
        )
        let expected = try XCTUnwrap(pixels(of: recorded), "the reference can be decoded", file: file, line: line)
        let actual = try XCTUnwrap(pixels(of: image), "the screenshot can be decoded", file: file, line: line)
        guard expected.width == actual.width, expected.height == actual.height else {
            return XCTFail(
                "The screenshot is \(actual.width)x\(actual.height) pixels, the reference \(expected.width)x\(expected.height).",
                file: file,
                line: line
            )
        }

        let difference = difference(between: expected, and: actual)
        guard difference.pixels > 0 else { return }

        let attachment = XCTAttachment(image: image)
        attachment.name = "screenshot that differs from \(reference.lastPathComponent)"
        attachment.lifetime = .keepAlways
        XCTContext.runActivity(named: "Screenshot that differs from its reference") { $0.add(attachment) }
        XCTFail(
            "\(difference.pixels) of \(expected.width * expected.height) pixels differ from \(reference.lastPathComponent) "
                + "by more than \(channelTolerance) of 255; the largest difference is \(difference.largest).",
            file: file,
            line: line
        )
    }

    private static func recordMissingReference(
        _ image: UIImage,
        at reference: URL,
        file: StaticString,
        line: UInt
    ) throws {
        guard recordsMissingReferences else {
            return XCTFail(
                "There is no reference at \(reference.path). CI never records one.",
                file: file,
                line: line
            )
        }
        let data = try XCTUnwrap(image.pngData(), "the screenshot can be encoded", file: file, line: line)
        try FileManager.default.createDirectory(at: reference.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: reference)
        XCTFail(
            "Recorded the missing reference \(reference.lastPathComponent). Run the test again.",
            file: file,
            line: line
        )
    }

    /// How many pixels are further from the reference than the tolerance, and by how much
    /// at most.
    private static func difference(between expected: Pixels, and actual: Pixels) -> (pixels: Int, largest: Int) {
        var differing = 0
        var largest = 0
        for index in stride(from: 0, to: expected.bytes.count, by: 4) {
            var distance = 0
            for channel in 0..<4 {
                distance = max(distance, abs(Int(expected.bytes[index + channel]) - Int(actual.bytes[index + channel])))
            }
            if distance > channelTolerance {
                differing += 1
                largest = max(largest, distance)
            }
        }
        return (differing, largest)
    }

    /// The pixels of an image as 8-bit sRGB, four bytes per pixel.
    private struct Pixels {
        let bytes: [UInt8]
        let width: Int
        let height: Int
    }

    private static func pixels(of image: UIImage) -> Pixels? {
        guard let cgImage = image.cgImage, let space = CGColorSpace(name: CGColorSpace.sRGB) else {
            return nil
        }
        let width = cgImage.width
        let height = cgImage.height
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        let drawn = bytes.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: space,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                return false
            }
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        return drawn ? Pixels(bytes: bytes, width: width, height: height) : nil
    }
}
