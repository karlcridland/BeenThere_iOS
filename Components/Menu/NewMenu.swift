//
//  NewMenu.swift
//  Been There
//
//  Created by Karl Cridland on 19/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class NewMenu: UIView {
    let block = UIView()
    
    var menu: MenuEdit?
    let page: PageEditMenu
    
    init(page: PageEditMenu, menu: MenuEdit) {
        self.menu = menu
        self.page = page
        super .init(frame: CGRect(x: UIScreen.main.bounds.width/2 - 125, y: 200, width: 250, height: 200))
        
        if ((menu.menus.count > 0) || (menu.items.count > 0)){
            if (menu.menus.count > 0){
                menuClicked()
            }
            else{
                itemClicked()
            }
        }
        else{
            block.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 65))
            label.text = "new item:"
            layer.cornerRadius = 8
            backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            self.block.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
            self.block.alpha = 0.0
            self.alpha = 0.2
            
            UIView.animate(withDuration: 0.2, animations: {
                self.block.alpha = 1.0
                self.alpha = 1.0
            })
            
            if let view = Settings.shared.home?.view{
                view.addSubview(block)
                view.addSubview(self)
            }
            
            label.font = Settings.shared.font
            label.textColor = .black
            label.numberOfLines = 0
            label.textAlignment = .center
            
            let menuButton = UIButton(frame: CGRect(x: 0, y: 65, width: frame.width, height: 45))
            let item = UIButton(frame: CGRect(x: 0, y: 110, width: frame.width, height: 45))
            let cancel = UIButton(frame: CGRect(x: 0, y: 155, width: frame.width, height: 45))
            
            menuButton.addTarget(self, action: #selector(menuClicked), for: .touchUpInside)
            item.addTarget(self, action: #selector(itemClicked), for: .touchUpInside)
            cancel.addTarget(self, action: #selector(close), for: .touchUpInside)
            for button in [menuButton,item,cancel]{
                button.titleLabel?.font = label.font
                button.setTitleColor(.black, for: .normal)
            }
            
            menuButton.setTitle("sub menu", for: .normal)
            item.setTitle("menu item", for: .normal)
            cancel.setTitle("cancel", for: .normal)
            
            for a in [menuButton,item,cancel,label]{
                addSubview(a)
            }
        }
        
    }
    
    init(page: PageEditMenu) {
        self.page = page
        super .init(frame: CGRect(x: UIScreen.main.bounds.width/2 - 125, y: UIScreen.main.bounds.height/2 - 50, width: 250, height: 200))
        menuClicked()
    }
    
    @objc func menuClicked(){
        if let m = menu{
            m.menus.append(MenuEdit(page: page, title: "new menu"))
            m.update()
        }
        else{
            page.menus.append(MenuEdit(page: page, title: "new menu"))
            page.display()
        }
        close()
    }
    
    @objc func itemClicked(){
        if let m = menu{
            m.items.append(MenuItemEdit(title: nil, subtitle: nil, price: nil, position: m.items.count, diet: ""))
            m.update()
        }
        close()
    }
    
    @objc func close(){
        UIView.animate(withDuration: 0.2, animations: {
            self.block.alpha = 0.0
            self.alpha = 0.0
        })
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { _ in
            self.block.removeFromSuperview()
            self.removeFromSuperview()
        })
        Settings.shared.ca = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

