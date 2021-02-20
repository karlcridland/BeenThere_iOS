//
//  PageReverse.swift
//  Kaktus
//
//  Created by Karl Cridland on 12/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageReverse: Page {
    override init(title: String) {
        super .init(title: title)
    }
    
    @objc override func moving(_ gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: self)
        let frame = gesture.view!
        let buf = Settings.shared.upper_bound+40
        if (frame.frame.maxX+translation.x <= frame.frame.width){
            var percentage = ((frame.frame.maxX*frame.frame.width/800))/100
            if percentage < 0{
                percentage = 0
            }
            self.background.backgroundColor = self.background.backgroundColor?.withAlphaComponent(0.8*percentage)
            frame.center = CGPoint(x: frame.center.x + translation.x, y: frame.center.y)
            gesture.setTranslation(CGPoint.zero, in: self)
        }
        if (gesture.state == .ended){
            if (frame.frame.maxX < 3*frame.frame.width/4){
                self.background.removeFromSuperview()
                if let home = Settings.shared.home{
                    home.container?.remove()
                }
            }
            else{
                UIView.animate(withDuration: 0.1, animations: {
                    self.frame = CGRect(x: 0, y: buf, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-buf)
                    self.background.backgroundColor = self.background.backgroundColor?.withAlphaComponent(0.4)
                })
            }
        }
    }
    
    @objc override func disappear(){
        self.background.removeFromSuperview()
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0)
        })
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in
            self.removeFromSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
