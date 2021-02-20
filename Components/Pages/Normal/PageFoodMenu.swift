//
//  PageFoodMenu.swift
//  Been There
//
//  Created by Karl Cridland on 19/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageFoodMenu: Page {
    
    let uid: String
    var menus = [MenuEdit]()
    
    var path = [Int]()
    
    var hasTriggered = false
    
    init(uid: String) {
        self.uid = uid
        super .init(title: "food menu")
        Firebase.shared.getMenus(self)
    }
    
    func display(){
        let offset = scroll.contentOffset
        scroll.removeAll()
        var i = 0
        for menu in menus{
            let new = menu.button(i)
            menu.position = i
            scroll.addSubview(new)
            i += 1
        }
        scroll.contentSize = CGSize(width: scroll.frame.width, height: CGFloat(i)*60 + 40)
        scroll.contentOffset = offset
        
        
    }
    
    @objc override func moving(_ gesture: UIPanGestureRecognizer){
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
            for item in self.currentItems(){
                item.transform = CGAffineTransform.identity
            }
        }
        else{
            frame.frame = CGRect(x: 0, y: frame.frame.minY, width: frame.frame.width, height: frame.frame.height)
            for item in currentItems(){
                item.transform = CGAffineTransform(translationX: [frame.frame.minX + translation.x,CGFloat(-90)].max()!, y: 0)
            }
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
                    for item in self.currentItems(){
                        item.transform = CGAffineTransform.identity
                    }
                })
            }
        }
    }
    
    func currentItems() -> [UIView]{
        var all = [UIView]()
        if let menu = self.topMenu() as? MenuEdit{
            if menu.items.count > 0{
                for item in menu.items{
                    all.append(item)
                }
            }
        }
        return all
    }
    
    func topMenu() -> Menu?{
        if path.count > 1{
            if let n = path.first{
                var temp = path
                temp.removeFirst()
                return menus[n].get(temp)
            }
        }
        else{
            if let n = path.first{
                return menus[n]
            }
        }
        return nil
    }
    
    func save(){
        if let menu = topMenu() as? MenuEdit{
            menu.save()
        }
    }
    
    func back(){
        save()
        if let menu = topMenu() as? MenuEdit{
            menu.disappear()
            path.removeLast()
            if let new = topMenu() as? MenuEdit{
                new.update()
            }
        }
        display()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
