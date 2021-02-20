//
//  PageEditMenu.swift
//  Been There
//
//  Created by Karl Cridland on 18/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageEditMenu: PageReverse {
    
    var hasDisplayed = false
    
    var menus = [MenuEdit]()
    var path = [Int]()
    
    init(){
        super .init(title: "edit menus")
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
        hasDisplayed = true
    }
    
    func addNew(){
        if hasDisplayed{
            if path.count == 0{
                let _ = NewMenu(page: self)
            }
            else{
                if let menu = topMenu() as? MenuEdit{
                    let _ = NewMenu(page: self, menu: menu)
                    menu.update()
                }
            }
        }
        saveAll()
    }
    
    func getMenu(_ path: [Int]) -> Menu?{
        if path.count == 1{
            if path.count > 0{
                return menus[path[0]]
            }
        }
        else{
            var temp = path
            let menu = menus[path[0]]
            temp.removeFirst()
            return menu.getMenu(temp)
        }
        return nil
    }
    
    func saveAll(){
        var i = 0
        for menu in menus{
            menu.position = i
            menu.saveAll([i], 1)
            i += 1
        }
        Firebase.shared.deleteMenu([i])
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
