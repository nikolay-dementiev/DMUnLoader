//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

/// What the HUD draws behind its card while it shows a loading, a success or a failure.
///
/// The backdrop is only what the user sees. With every backdrop the HUD window takes every
/// touch while a HUD is shown, so the app under it receives none, and a tap outside the card
/// does what it does with the default backdrop.
///
/// Under the system's Reduce Transparency the HUD draws no blur and no material: ``variableBlur``
/// keeps its dim, and ``material(_:)`` gives way to that dim. ``dim(_:)`` and ``clear`` stay
/// as they are.
///
/// A backdrop other than ``variableBlur`` stops DMUnLoader from creating the variable blur while
/// the app runs. It does not remove DMVariableBlurView, and the private API that it uses, from
/// the app: see the README.
public struct DMHUDBackdrop: Sendable {
    package enum Kind: Sendable {
        case variableBlur
        case dim(Color)
        case material(Material)
        case clear
    }

    package let kind: Kind

    private init(kind: Kind) {
        self.kind = kind
    }

    /// The variable blur of DMVariableBlurView under a black dim of opacity 0.2: the backdrop of
    /// every release so far, and the default.
    ///
    /// The blur is strongest in a band across the middle of the screen, where the card is, and
    /// fades to clear towards the top and the bottom. Its radius is at most 4 points. It uses a
    /// private API of the system: read the README of DMVariableBlurView before you ship it. Where
    /// the system does not offer or accept that API, DMVariableBlurView draws the plain blur of
    /// the system over the whole screen instead and writes the reason to the unified log, under
    /// its subsystem `DMVariableBlurView`.
    public static let variableBlur = DMHUDBackdrop(kind: .variableBlur)

    /// A colour over the whole screen, faded in with the card. Draws no blur.
    ///
    /// - Parameter color: The colour, opacity included. The default is black of opacity 0.2,
    ///   the dim of ``variableBlur`` without its blur.
    /// - Returns: A backdrop that draws `color`.
    public static func dim(_ color: Color = .black.opacity(0.2)) -> DMHUDBackdrop {
        DMHUDBackdrop(kind: .dim(color))
    }

    /// A material of the system over the whole screen. Draws no blur of DMVariableBlurView.
    ///
    /// - Parameter material: The material. The default is `.ultraThinMaterial`.
    /// - Returns: A backdrop that draws `material`.
    public static func material(_ material: Material = .ultraThinMaterial) -> DMHUDBackdrop {
        DMHUDBackdrop(kind: .material(material))
    }

    /// Nothing: the app shows through unchanged.
    ///
    /// The HUD still takes every touch while it is shown, and a tap outside the card still does
    /// what it does with the other backdrops.
    public static let clear = DMHUDBackdrop(kind: .clear)
}

/// What the HUD draws for its backdrop: the layer behind the card, and the dim that fades in
/// with the card.
package struct HUDBackdropDrawing {
    /// What lies behind the card, under the dim.
    package enum Layer {
        case none
        case variableBlur
        case material(Material)
    }

    /// The dim, faded in with the card.
    package enum Dim: Equatable {
        case none
        /// The black dim of the default backdrop: black at opacity 0.2.
        case standard
        case color(Color)
    }

    package let layer: Layer
    package let dim: Dim
}

extension DMHUDBackdrop {
    /// What the HUD draws for this backdrop. Under Reduce Transparency it draws no blur and no
    /// material: the variable blur keeps its dim, a material gives way to the dim of the default
    /// backdrop, and a dim and the clear backdrop stay as they are.
    package func drawing(reducesTransparency: Bool) -> HUDBackdropDrawing {
        switch kind {
        case .variableBlur:
            return HUDBackdropDrawing(layer: reducesTransparency ? .none : .variableBlur, dim: .standard)
        case let .material(material):
            return reducesTransparency
                ? HUDBackdropDrawing(layer: .none, dim: .standard)
                : HUDBackdropDrawing(layer: .material(material), dim: .none)
        case let .dim(color):
            return HUDBackdropDrawing(layer: .none, dim: .color(color))
        case .clear:
            return HUDBackdropDrawing(layer: .none, dim: .none)
        }
    }
}
