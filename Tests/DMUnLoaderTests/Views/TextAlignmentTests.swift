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
        XCTAssertGreaterThanOrEqual(lines.count, 3, "two text lines above the progress indicator")
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
        XCTAssertGreaterThanOrEqual(lines.count, 3, "the image above two text lines")
        return (lines[lines.count - 2], try XCTUnwrap(lines.last))
    }

    /// The horizontal extent of each band of drawn rows of `view`, from the top.
    private func drawnLines(of view: some View) throws -> [TextLine] {
        let controller = UIHostingController(rootView: view)
        controller.view.backgroundColor = .clear
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 320))
        window.rootViewController = controller
        window.isHidden = false
        defer { window.isHidden = true }
        controller.view.waitForSettledRendering()
        let alphas = try RenderedAlphas(of: controller.view.renderedLayers())

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
