//
//  MenuEdit.swift
//  Been There
//
//  Created by Karl Cridland on 19/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class MenuEdit: Menu, UIScrollViewDelegate {
    
    var title: String?
    
    var items = [MenuItemEdit]()
    var menus = [MenuEdit]()
    let page: PageEditMenu?
    let foodPage: PageFoodMenu?
    let click = UIButton()
    let scroll = UIScrollView()
    let t: SearchBar?
    
    var keyboardHeight: CGFloat?
    
    init(page: PageEditMenu, title: String?) {
        self.page = page
        self.title = title
        self.foodPage = nil
        self.t = SearchBar(frame: CGRect(x: 20, y: 10, width: page.frame.width-40, height: 30), placeholder: "title", type: .search)
        super .init(frame: CGRect(x: 0, y: 0, width: page.frame.width, height: page.frame.height))
        update()
        backgroundColor = page.backgroundColor
        scroll.frame = CGRect(x: 0, y: 50, width: page.frame.width, height: page.frame.height-50)
        addSubview(scroll)
        
        if let tt = t{
            tt.input.text = title
            tt.denullify()
            tt.input.textColor = .black
            tt.input.addTarget(self, action: #selector(updateTitle), for: .allEditingEvents)
            addSubview(tt)
        }
        
        scroll.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    init(page: PageFoodMenu, title: String?, items: [MenuItemEdit], menus: [MenuEdit]) {
        self.foodPage = page
        self.title = title
        self.items = items
        self.menus = menus
        self.t = nil
        self.page = nil
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 10, width: page.frame.width-40, height: 30))
        super .init(frame: CGRect(x: 0, y: 0, width: page.frame.width, height: page.frame.height))
        update()
        backgroundColor = page.backgroundColor
        scroll.frame = CGRect(x: 0, y: 50, width: page.frame.width, height: page.frame.height-50)
        addSubview(scroll)
        
        titleLabel.text = "\(title!):"
        titleLabel.font = Settings.shared.font
        titleLabel.increase(3)
        addSubview(titleLabel)
        
        scroll.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    @objc func deleteItem(sender: UIButton){
        if let item = sender.accessibilityElements?[0] as? MenuItemEdit{
            Firebase.shared.removeMenuItems(self)
            items.remove(at: item.position)
            update()
        }
    }
    
    func affirm(){
        for item in items{
            if let p = page{
                item.save(p.path)
            }
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            scroll.frame = CGRect(x: scroll.frame.minX, y: scroll.frame.minY, width: scroll.frame.width, height: frame.height-keyboardRectangle.height)
            
        }
    }
    
    @objc func updateTitle(){
        if let tt = t{
            title = tt.text()
        }
    }
    
    func addReturn(){
        if let tt = t{
            var all = [tt.input]
            for item in items{
                for a in item.textFields(){
                    all.append(a)
                }
            }
            for form in all{
                form.addTarget(self, action: #selector(returnScroll), for: .primaryActionTriggered)
                form.addTarget(self, action: #selector(save), for: .allEditingEvents)
            }
        }
    }
    
    @objc func returnScroll(){
        UIView.animate(withDuration: 0.1, animations: {
            let f = self.scroll.frame
            if let p = self.page{
                self.scroll.frame = CGRect(x: f.minX, y: f.minY, width: f.width, height: p.frame.height-f.minY)
            }
        })
    }
    
    func update(){
        scroll.removeAll()
        var i = 0
        var h = CGFloat(0.0)
        if menus.count > 0{
            for menu in menus{
                let new = menu.button(i)
                menu.position = i
                scroll.addSubview(new)
                i += 1
            }
            scroll.contentSize = CGSize(width: scroll.frame.width, height: CGFloat(i)*60 + 50)
        }
        if items.count > 0{
            for item in items{
                let new = item
                new.update(h, i)
                new.delete.addTarget(self, action: #selector(deleteItem), for: .touchUpInside)
                scroll.addSubview(new.bg)
                scroll.addSubview(new)
                new.bg.frame = new.frame
                h += new.frame.height + 20
                i += 1
                
                if let page = foodPage{
                    if !page.hasTriggered{
                        UIView.animate(withDuration: 0.5, animations: {
                            new.transform = CGAffineTransform(translationX: -90, y: 0)
                        })
                        Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false, block: { _ in
                            UIView.animate(withDuration: 0.3, animations: {
                                new.transform = CGAffineTransform.identity
                            })
                        })
                    }
                }
            }
            if let page = foodPage{
                page.hasTriggered = true
            }
            scroll.contentSize = CGSize(width: scroll.frame.width, height: h + 70 + 50)
            
        }
        if let _ = page{
            let delete = UIButton(frame: CGRect(x: 20, y: [h+20,CGFloat(i)*60 + 20].max()!, width: frame.width-40, height: 50))
            delete.setTitle("delete menu", for: .normal)
            delete.setTitleColor(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), for: .normal)
            delete.titleLabel!.font = Settings.shared.font
            delete.addTarget(self, action: #selector(deleteMenu), for: .touchUpInside)
            scroll.addSubview(delete)
        }
        addReturn()
        returnScroll()
    }
    
    @objc func deleteMenu(){
        let _ = ConfirmAction(title: "delete this menu", with:{
            if let page = self.page{
                self.disappear()
                Firebase.shared.deleteMenu(page.path)
                var temp = page.path
                temp.removeLast()
                if temp.count == 0{
                    page.menus.removeAll(where: {$0 == self})
                    print(page.menus.count)
                }
                else{
                    if let menu = page.getMenu(temp) as? MenuEdit{
                        menu.menus.removeAll(where: {$0 == self})
                        menu.update()
                    }
                }
                page.display()
                page.path.removeLast()
                page.saveAll()
            }
        })
    }
    
    func getMenu(_ path: [Int]) -> Menu?{
        if path.count == 1{
            if items.count > 0{
                return items[path.first!]
            }
            return menus[path.first!]
        }
        else{
            var temp = path
            let menu = menus[path[0]]
            temp.removeFirst()
            return menu.getMenu(temp)
        }
    }
    
    @objc func save(){
        if let t = title{
            if let p = self.page{
                Firebase.shared.saveMenuTitle(title: t, path: p.path)
            }
        }
        for item in items{
            if let p = self.page{
                item.save(p.path)
            }
        }
    }
    
    func saveFromPath(_ path: [Int]){
        if let t = title{
            Firebase.shared.saveMenuTitle(title: t, path: path)
        }
        var i = 0
        for item in items{
            item.position = i
            item.save(path)
            i += 1
        }
    }
    
    func saveAll(_ path: [Int], _ layer: Int){
        var i = 0
        var temp = path
        if temp.count == layer{
            saveFromPath(temp)
        }
        else{
            return
        }
        for menu in menus{
            menu.position = i
            temp.append(i)
            menu.saveAll(path,layer+1)
            i += 1
        }
        
        temp = path
        temp.append(i)
        Firebase.shared.deleteMenu(temp)
        
    }
    
    func button(_ position: Int) -> UIView{
        let view = UIView(frame: CGRect(x: 20, y: 20 + (CGFloat(position) * 60), width: UIScreen.main.bounds.width-40, height: 40))
        click.addTarget(self, action: #selector(openMenu), for: .touchUpInside)
        click.frame = CGRect(x: 10, y: 0, width: view.frame.width-20, height: view.frame.height)
        view.addSubview(click)
        
        if let t = title{
            click.setTitle(t, for: .normal)
            click.titleLabel?.font = Settings.shared.font
            click.setTitleColor(.white, for: .normal)
            click.titleLabel!.textAlignment = .left
        }
        
        view.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 4
        
        let arrow = UIImageView(frame: CGRect(x: view.frame.width-25, y: 10, width: 20, height: 20))
        view.addSubview(arrow)
        arrow.image = UIImage(named: "arrow")
        return view
    }
    
    @objc func openMenu(){
        if let p = self.page{
            p.addSubview(self)
            p.path.append(position)
        }
        if let p = foodPage{
            p.addSubview(self)
            p.path.append(position)
        }
        update()
        if let tt = t{
            tt.input.becomeFirstResponder()
        }
    }
    
    func get(_ path: [Int]) -> Menu?{
        if let first = path.first{
            if menus.count >= first{
                let menu = menus[first]
                var temp = path
                temp.removeFirst()
                return menu.get(temp)
            }
            if items.count >= first{
                return items[first]
            }
        }
        return self
    }
    
    func disappear(){
        removeFromSuperview()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scroll.contentSize, scroll.frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
