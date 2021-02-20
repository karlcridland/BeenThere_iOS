//
//  UIView.swift
//  Kaktus
//
//  Created by Karl Cridland on 11/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    
    func removeAll(){
        for subview in subviews{
            subview.removeFromSuperview()
        }
    }
    
    func addSubview(_ views: [UIView]){
        for view in views{
            addSubview(view)
        }
    }
    
    func bringSubviewsToFront(_ views: [UIView]){
        for view in views{
            bringSubviewToFront(view)
        }
    }
    
}
