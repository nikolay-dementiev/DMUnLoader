//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import UIKit

/// The contrast ratio of the Web Content Accessibility Guidelines between two colours, measured on the
/// colours as the system resolves them in a style of the interface.
@MainActor
enum WCAGContrast {
    /// A colour in sRGB, each channel from 0 to 1.
    struct Sample {
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double

        static let black = Sample(red: 0, green: 0, blue: 0, alpha: 1)
        static let white = Sample(red: 1, green: 1, blue: 1, alpha: 1)
    }

    /// The colour as the system resolves it when the interface is in `style`.
    static func resolve(_ color: Color, in style: UIUserInterfaceStyle) -> Sample {
        let resolved = UIColor(color).resolvedColor(with: UITraitCollection(userInterfaceStyle: style))
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        resolved.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return Sample(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
    }

    /// `top` drawn over `bottom`, which is taken as opaque.
    static func composite(_ top: Sample, over bottom: Sample) -> Sample {
        let alpha = top.alpha
        return Sample(
            red: top.red * alpha + bottom.red * (1 - alpha),
            green: top.green * alpha + bottom.green * (1 - alpha),
            blue: top.blue * alpha + bottom.blue * (1 - alpha),
            alpha: 1
        )
    }

    /// The relative luminance of an opaque colour, from 0 for black to 1 for white.
    static func relativeLuminance(_ sample: Sample) -> Double {
        func linear(_ channel: Double) -> Double {
            channel <= 0.04045 ? channel / 12.92 : pow((channel + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(sample.red) + 0.7152 * linear(sample.green) + 0.0722 * linear(sample.blue)
    }

    /// The ratio of two opaque colours, from 1 for equal luminance to 21 for black on white.
    static func ratio(_ first: Sample, _ second: Sample) -> Double {
        let lighter = max(relativeLuminance(first), relativeLuminance(second))
        let darker = min(relativeLuminance(first), relativeLuminance(second))
        return (lighter + 0.05) / (darker + 0.05)
    }

    /// The ratio of `foreground` to `background` when the interface is in `style` and `behind` lies
    /// behind the background. A background or a foreground that is not opaque is drawn over what is
    /// behind it first, as the screen does.
    static func ratio(
        of foreground: Color,
        on background: Color,
        behind: Sample,
        in style: UIUserInterfaceStyle
    ) -> Double {
        let fill = composite(resolve(background, in: style), over: behind)
        let ink = composite(resolve(foreground, in: style), over: fill)
        return ratio(ink, fill)
    }
}
