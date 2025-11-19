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
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img!
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
