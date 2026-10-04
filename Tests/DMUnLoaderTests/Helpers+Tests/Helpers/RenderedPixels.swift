//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import UIKit
import XCTest

extension UIView {

    /// The layers of the view drawn at one pixel per point. `drawHierarchy` draws nothing
    /// for a window that belongs to no scene, so the layers are rendered instead.
    func renderedLayers() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(bounds: bounds, format: format).image { context in
            layer.render(in: context.cgContext)
        }
    }

    /// Turns the run loop until the rendering of the view has appeared and has stopped changing:
    /// a rendering that differs from the blank first one, then two renderings a tenth of a second
    /// apart that are the same. Gives up after the callback allowance, so a view that never
    /// settles still ends the test.
    func waitForSettledRendering() {
        let blank = renderedLayers().pngData()
        var previous = blank
        var appeared = false
        let deadline = Date().addingTimeInterval(TestTiming.callbackAllowance)
        while Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
            let current = renderedLayers().pngData()
            appeared = appeared || current != blank
            if appeared && current == previous {
                return
            }
            previous = current
        }
    }
}

/// The alpha channel of a rendering, row by row from the top left. A HUD window is clear
/// wherever the HUD draws nothing, so the alpha says what is drawn where.
struct RenderedAlphas {
    let values: [UInt8]
    let width: Int
    let height: Int

    init(of image: UIImage) throws {
        let cgImage = try XCTUnwrap(image.cgImage, "the rendering has a bitmap")
        let width = cgImage.width
        let height = cgImage.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        try pixels.withUnsafeMutableBytes { buffer in
            let context = try XCTUnwrap(
                CGContext(
                    data: buffer.baseAddress,
                    width: width,
                    height: height,
                    bitsPerComponent: 8,
                    bytesPerRow: width * 4,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                ),
                "a bitmap context for the rendering"
            )
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        self.values = stride(from: 3, to: pixels.count, by: 4).map { pixels[$0] }
        self.width = width
        self.height = height
    }

    var maximum: UInt8 {
        values.max() ?? 0
    }

    var centre: UInt8 {
        values[(height / 2) * width + width / 2]
    }
}
