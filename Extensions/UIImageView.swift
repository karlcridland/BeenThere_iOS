//
//  UIImageView.swift
//  Kaktus
//
//  Created by Karl Cridland on 07/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView{

    func invert(){
        if let filter = CIFilter(name: "CIColorInvert") {
            let beginImage = CIImage(image: self.image!)
            filter.setValue(beginImage, forKey: kCIInputImageKey)
            if let output = filter.outputImage{
                let newImage = UIImage(ciImage: output)
                self.image = newImage
            }
        }
    }
}
