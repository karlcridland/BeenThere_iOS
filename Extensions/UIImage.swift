//
//  UIImage.swift
//  Kaktus
//
//  Created by Karl Cridland on 12/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

extension UIImage{
    
    func compress(_ percentage: CGFloat) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            a in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
    func compress() -> UIImage{
        var compressed = self
        while compressed.pngData()!.count > 2 * 1024 * 1024{
            compressed = compressed.compress(0.5)!
        }
        return compressed
    }
    
}

