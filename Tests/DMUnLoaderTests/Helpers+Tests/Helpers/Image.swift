//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import UIKit
import SwiftUI

extension UIImage {
    static func make(
        withColor color: UIColor,
        width: Int = 10,
        height: Int = 10
    ) -> UIImage {
        let rect = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: height
        )
        
        // Scale 1, not opaque, standard range: the bitmap the former
        // UIGraphicsBeginImageContext call produced, without its optionals.
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false
        format.preferredRange = .standard

        return UIGraphicsImageRenderer(size: rect.size, format: format).image { context in
            color.setFill()
            context.fill(rect)
        }
    }
}

extension Image {
    static func make(
        withColor color: UIColor,
        width: Int = 10,
        height: Int = 10
    ) -> Image {
        let uiImage = UIImage.make(
            withColor: color,
            width: width,
            height: height
        )
       
        return Image(uiImage: uiImage)
    }
}
