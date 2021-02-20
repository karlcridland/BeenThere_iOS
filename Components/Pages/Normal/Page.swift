//
//  Page.swift
//  Kaktus
//
//  Created by Karl Cridland on 12/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class Page: UIView {
    
    let scroll: UIScrollView
    let background: UIView
    let title: String
    
    private var home_buttons = false
    
    init(title: String) {
        self.title = title
        let buf = Settings.shared.upper_bound+40
        scroll = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-buf))
        background = UIView(frame: CGRect(x: 0, y: buf, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-buf))
        super.init(frame: CGRect(x: UIScreen.main.bounds.width, y: buf, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-buf))
        if self is PageReverse{
            self.frame = CGRect(x: -UIScreen.main.bounds.width, y: buf, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-buf)
        }
        backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        background.backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        background.backgroundColor = background.backgroundColor?.withAlphaComponent(0.4)
        addSubview(scroll)
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(moving)))
        
        func finish(){
            UIView.animate(withDuration: 0.2, animations: {
                self.frame = CGRect(x: 0, y: buf, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-buf)
            })
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: {_ in
                if let s = self.superview{
                    s.addSubview(self.background)
                    self.background.tag = -1
                    s.bringSubviewToFront(self)
                }
            })
        }
        
        if self is PageMagnify{
            Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false, block: { _ in
                finish()
            })
        }
        else{
            finish()
        }
    }
    
    @objc func moving(_ gesture: UIPanGestureRecognizer){
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
        let translation = gesture.translation(in: self)
        let frame = gesture.view!
        let buf = Settings.shared.upper_bound+40
        if (frame.frame.minX + translation.x >= 0){
            var percentage = (100-(frame.frame.minX*frame.frame.width/800))/100
            if percentage < 0{
                percentage = 0
            }
            self.background.backgroundColor = self.background.backgroundColor?.withAlphaComponent(0.8*percentage)
            frame.center = CGPoint(x: frame.center.x + translation.x, y: frame.center.y)
            gesture.setTranslation(CGPoint.zero, in: self)
        }
        if (gesture.state == .ended){
            if (frame.frame.minX > frame.frame.width/4){
                self.background.removeFromSuperview()
                if let home = Settings.shared.home{
                    home.container?.remove()
                }
            }
            else{
                cancelDisappear()
                UIView.animate(withDuration: 0.1, animations: {
                    self.frame = CGRect(x: 0, y: buf, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-buf)
                    self.background.backgroundColor = self.background.backgroundColor?.withAlphaComponent(0.4)
                })
            }
        }
    }
    
    func cancelDisappear(){}
    
    @objc func disappear(){
        self.background.removeFromSuperview()
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
        })
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in
            self.removeFromSuperview()
        }
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { timer in
            self.background.removeFromSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
