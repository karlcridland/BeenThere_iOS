//
//  CGPoint.swift
//  Been There
//
//  Created by Karl Cridland on 14/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint{
    
    func midPoint(_ point: CGPoint) -> CGPoint{
        return CGPoint(x: (self.x + point.x)/2, y: (self.y + point.y)/2)
    }
    
    func scaled(_ by: CGFloat) -> CGPoint{
        return CGPoint(x: self.x*by, y: self.y*by)
    }
    
    func distance(_ point: CGPoint) -> CGFloat{
        let x = (self.x-point.x)*(self.x-point.x)
        let y = (self.y-point.y)*(self.y-point.y)
        return (x+y).squareRoot()
    }
}
