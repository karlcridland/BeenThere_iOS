//
//  DrinkBanner.swift
//  Been There
//
//  Created by Karl Cridland on 20/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class DrinkBanner: UIView {
    
    var min = CGFloat(0.0)
    var max = CGFloat(0.0)
    let sub: Bool
    let t: String
    let first: Bool
    
    init(title: String, sub: Bool, first: Bool){
        self.sub = sub
        self.t = title
        self.first = first
        super .init(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 0.7505083476)
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: frame.width-20, height: frame.height))
        label.text = title
        label.textColor = .white
        label.font = Settings.shared.font
        addSubview(label)
    }
    
    func inView(){
        if let s = superview as? UIScrollView{
            s.bringSubviewToFront(self)
            let frameMin = s.contentOffset.y
            let frameMax = s.contentOffset.y + s.frame.height
            frame = CGRect(x: 0, y: min, width: frame.width, height: frame.height)
            if min < frameMin || min > frameMax{
                if min < frameMax{
                    if sub{
                        frame = CGRect(x: 0, y: frameMin+20, width: frame.width, height: frame.height)
                    }
                    else{
                        frame = CGRect(x: 0, y: frameMin, width: frame.width, height: frame.height)
                    }
                }
                if max < frameMin{
                    frame = CGRect(x: 0, y: max-frame.height, width: frame.width, height: frame.height)
                }
            }
            if sub{
                if min-40 > frameMin{
                    frame = CGRect(x: 0, y: min-20, width: frame.width, height: frame.height)
                    if first{
                        frame = CGRect(x: 0, y: min, width: frame.width, height: frame.height)
                    }
                }
                else{
                    frame = CGRect(x: 0, y: frameMin+20, width: frame.width, height: frame.height)
                }
                if min == 20 && frameMin < 0{
                    frame = CGRect(x: 0, y: 20, width: frame.width, height: frame.height)
                }
            }
            if frame.maxY > max{
                frame = CGRect(x: 0, y: max-frame.height, width: frame.width, height: frame.height)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

