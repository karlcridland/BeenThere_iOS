//
//  Tagger.swift
//  Been There
//
//  Created by Karl Cridland on 14/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class Tagger: UIView{
    
    let uid: String
    var point: CGPoint
    let new: Bool
    
    init(point: CGPoint, uid: String, new: Bool) {
        self.uid = uid
        self.point = point
        self.new = new
        super .init(frame: CGRect(x: point.x - 65, y: point.y, width: 130, height: 30))
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        layer.cornerRadius = 4.0
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        var i = 0
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: {timer in
            if let username = Settings.shared.getProfile(uid)?.username{
                button.setTitle(username, for: .normal)
                button.titleLabel?.font = Settings.shared.font
                button.titleLabel?.increase(-2)
                let width = username.width(font: (button.titleLabel?.font)!) + 20
                button.frame = CGRect(x: 0, y: 0, width: width, height: 30)
                self.frame = CGRect(x: point.x-(width+30)/2, y: point.y, width: width, height: 30)
                timer.invalidate()
                self.isHidden = false
            }
            if i == 20{
                timer.invalidate()
                self.isHidden = true
            }
            i += 1
        })
        
        button.addTarget(self, action: #selector(clicked), for: .touchUpInside)
        if new{
            self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(moving)))
        }
        
        addSubview(button)
        isHidden = true
        if new{
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
                while self.getY()! > 95{
                    self.center = CGPoint(x: self.center.x, y: self.center.y - 1)
                }
                while self.getY()! < 5{
                    self.center = CGPoint(x: self.center.x, y: self.center.y + 1)
                }
                while self.getX()! > 95{
                    self.center = CGPoint(x: self.center.x - 1, y: self.center.y)
                }
                while self.getX()! < 5{
                    self.center = CGPoint(x: self.center.x + 1, y: self.center.y)
                }
                
                if let pad = self.superview as? TagPad{
                    pad.page?.returnScroll()
                    UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            })
        }
        else{
            self.isHidden = false
            self.alpha = 0.0
        }
    }
    
    @objc func clicked(){
        Firebase.shared.getPage(uid)
    }
    
    func show(){
        
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1.0
            
        })
    }
    
    func hide(){
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
        })
    }
    
    @objc func moving(_ gesture: UIPanGestureRecognizer){
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
        let view = gesture.view!
        let translation = gesture.translation(in: view.superview!)
        
        
        var x = view.center.x + translation.x
        var y = view.center.y + translation.y
        
        if let size = getSize(){
            if let o = getOrientation(){
                if o == .landscape{
                    let height = UIScreen.main.bounds.width/(size.width/size.height)
                    let gap = (UIScreen.main.bounds.width-height)/2
                    if (view.frame.maxX + translation.x >= UIScreen.main.bounds.width){
                        x = UIScreen.main.bounds.width - frame.width/2
                    }
                    if (view.frame.minX + translation.x <= 0){
                        x = frame.width/2
                    }
                    if (view.frame.maxY + translation.y >= height + gap){
                        y = height + gap - (frame.height/2)
                    }
                    if (view.frame.minY + translation.y <= gap){
                        y = gap + frame.height/2
                    }
                }
                else{
                    let width = UIScreen.main.bounds.width/(size.height/size.width)
                    let gap = (UIScreen.main.bounds.width-width)/2
                    
                    if (view.frame.maxX + translation.x >= width + gap){
                        x = width + gap - frame.width/2
                    }
                    if (view.frame.minX + translation.x <= gap){
                        x = gap + frame.width/2
                    }
                    if (view.frame.maxY + translation.y >= UIScreen.main.bounds.width){
                        y = UIScreen.main.bounds.width - (frame.height/2)
                    }
                    if (view.frame.minY + translation.y <= 0){
                        y = frame.height/2
                    }
                }
            }
        }
        
        view.center = CGPoint(x: x, y: y)
        gesture.setTranslation(CGPoint.zero, in: view.superview!)
        center = view.center
        
    }
    
    func getX() -> CGFloat?{
        if let o = getOrientation(){
            if o == .landscape{
                return (center.x*100)/UIScreen.main.bounds.width
            }
            if let size = getSize(){
                let width = UIScreen.main.bounds.width/(size.height/size.width)
                let gap = (UIScreen.main.bounds.width-width)/2
                return ((center.x-gap)*100)/width
            }
        }
        return nil
    }
    
    func getY() -> CGFloat?{
        if let o = getOrientation(){
            if o == .landscape{
                if let size = getSize(){
                    let height = UIScreen.main.bounds.width/(size.width/size.height)
                    let gap = (UIScreen.main.bounds.width-height)/2
                    return ((center.y-gap)*100)/height
                }
            }
            return (center.y*100)/UIScreen.main.bounds.width
        }
        return nil
    }
    
    func getSize() -> CGSize?{
        if let pad = superview as? TagPad{
            if let image = pad.page?.button.imageView?.image{
                return image.size
            }
        }
        return nil
    }
    
    func getOrientation() -> orientation?{
        if let pad = superview as? TagPad{
            if let image = pad.page?.button.imageView?.image{
                if image.size.width > image.size.height{
                    return .landscape
                }
                return .portrait
            }
        }
        return nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum orientation{
    case portrait
    case landscape
}
