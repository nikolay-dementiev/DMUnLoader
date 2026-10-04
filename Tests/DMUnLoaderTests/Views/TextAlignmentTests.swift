//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import XCTest
import DMUnLoader

/// How the lines of a loading text and of a success message line up when the text takes two
/// lines. The texts break with a newline, so the two lines do not depend on the width of the
/// view or on the font metrics of a system. The views are drawn and each line is measured
/// from its pixels.
@MainActor
final class TextAlignmentTests: XCTestCase {

    // MARK: - Loading text

    func test_progressText_twoLinesTrailingAlignment_alignsLineEnds() throws {
        let (first, second) = try loadingTextLines(alignment: .trailing)

        XCTAssertLessThanOrEqual(abs(first.end - second.end), 1, "the lines end at the same edge")
    }

    func test_progressText_twoLinesDefaultSettings_centersLines() throws {
        let (first, second) = try loadingTextLines(alignment: nil)

        XCTAssertLessThanOrEqual(abs(first.centre - second.centre), 1, "with the default settings the lines are centred")
    }

    func test_progressText_twoLinesLeadingAlignment_alignsLineStarts() throws {
        let (first, second) = try loadingTextLines(alignment: .leading)

        XCTAssertLessThanOrEqual(abs(first.start - second.start), 1, "the lines start at the same edge")
    }

    // MARK: - Success message

    func test_successText_twoLinesTrailingAlignment_alignsLineEnds() throws {
        let (first, second) = try successTextLines(alignment: .trailing)

        XCTAssertLessThanOrEqual(abs(first.end - second.end), 1, "the lines end at the same edge")
    }

    func test_successText_twoLinesDefaultSettings_centersLines() throws {
        let (first, second) = try successTextLines(alignment: nil)

        XCTAssertLessThanOrEqual(abs(first.centre - second.centre), 1, "with the default settings the lines are centred")
    }

    func test_successText_twoLinesLeadingAlignment_alignsLineStarts() throws {
        let (first, second) = try successTextLines(alignment: .leading)

        XCTAssertLessThanOrEqual(abs(first.start - second.start), 1, "the lines start at the same edge")
    }

    func test_successText_customHorizontalGuide_centersLines() throws {
        let (first, second) = try successTextLines(alignment: Alignment(horizontal: .testGuide, vertical: .top))

        XCTAssertLessThanOrEqual(
            abs(first.centre - second.centre),
            1,
            "a horizontal alignment other than leading or trailing centres the lines"
        )
    }

    // MARK: - Helpers

    /// The rows of the view were not drawn as text lines: the test stops here, with the count it found.
    private struct MissingTextLines: Error, CustomStringConvertible {
        let count: Int

        var description: String {
            "expected at least three drawn lines (two lines of text and the image or indicator), found \(count)"
        }
    }

    /// The two text lines of a loading view; `nil` keeps the default alignment.
    private func loadingTextLines(alignment: TextAlignment?) throws -> (TextLine, TextLine) {
        let text = "Wait\nLoading data"
        let properties = alignment.map { ProgressTextProperties(text: text, alignment: $0) }
            ?? ProgressTextProperties(text: text)
        let provider = DefaultDMLoadingViewProvider(
            loadingViewSettings: DMProgressViewDefaultSettings(loadingTextProperties: properties)
        )
        let lines = try drawnLines(of: provider.getLoadingView())
        // The text comes first; the progress indicator below it.
        guard lines.count >= 3 else {
            throw MissingTextLines(count: lines.count)
        }
        return (try XCTUnwrap(lines.first), lines[1])
    }

    /// The two text lines of a success view; `nil` keeps the default alignment.
    private func successTextLines(alignment: Alignment?) throws -> (TextLine, TextLine) {
        let properties = alignment.map { SuccessTextProperties(alignment: $0) } ?? SuccessTextProperties()
        let provider = DefaultDMLoadingViewProvider(
            successViewSettings: DMSuccessDefaultViewSettings(successTextProperties: properties)
        )
        let lines = try drawnLines(of: provider.getSuccessView(object: "Done\nAll items were saved"))
        // The image comes first; the two text lines below it.
        guard lines.count >= 3 else {
            throw MissingTextLines(count: lines.count)
        }
        return (lines[lines.count - 2], try XCTUnwrap(lines.last))
    }

    /// The horizontal extent of each band of drawn rows of `view`, from the top. The rendering is read once
    /// the view draws three bands: the two text lines and the image or indicator beside them. An animation
    /// keeps changing the rendering, so the wait is for the bands, not for the rendering to stop.
    private func drawnLines(of view: some View) throws -> [TextLine] {
        let controller = UIHostingController(rootView: view)
        controller.view.backgroundColor = .clear
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 320))
        window.rootViewController = controller
        window.isHidden = false
        defer { window.isHidden = true }

        var lines = bands(in: try RenderedAlphas(of: controller.view.renderedLayers()))
        let deadline = Date().addingTimeInterval(TestTiming.callbackAllowance)
        while lines.count < 3, Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
            lines = bands(in: try RenderedAlphas(of: controller.view.renderedLayers()))
        }
        XCTAssertGreaterThanOrEqual(lines.count, 3, "the view draws its two text lines and what follows them")
        return lines
    }

    /// The horizontal extent of each band of drawn rows of the rendering, from the top.
    private func bands(in alphas: RenderedAlphas) -> [TextLine] {
        var lines: [TextLine] = []
        var current: TextLine?
        for row in 0..<alphas.height {
            let drawn = (0..<alphas.width).filter { alphas.values[row * alphas.width + $0] > 0 }
            guard let start = drawn.first, let end = drawn.last else {
                current.map { lines.append($0) }
                current = nil
                continue
            }
            current = current.map { TextLine(start: min($0.start, start), end: max($0.end, end)) }
                ?? TextLine(start: start, end: end)
        }
        current.map { lines.append($0) }
        return lines
    }

    private struct TextLine {
        let start: Int
        let end: Int

        var centre: Double {
            Double(start + end) / 2
        }
    }
}

private enum TestGuide: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[HorizontalAlignment.center]
    }
}

private extension HorizontalAlignment {
    static let testGuide = HorizontalAlignment(TestGuide.self)
}
