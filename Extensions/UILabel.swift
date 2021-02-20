//
//  UILabel.swift
//  Been There
//
//  Created by Karl Cridland on 14/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

extension UILabel{
    
    func increase(_ by: CGFloat){
        font = UIFont(name: font.fontName, size: font.pointSize + CGFloat(by))
    }
}
