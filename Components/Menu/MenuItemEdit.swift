//
//  MenuItemEdit.swift
//  Been There
//
//  Created by Karl Cridland on 19/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class MenuItemEdit: Menu{
    
    var title: String?
    var subtitle: String?
    var price: Int?
    
    let pounds = UITextField()
    let pence = UITextField()
    let delete = UIButton(frame: CGRect(x: 10, y: 90, width: 30, height: 30))
    
    let scroll = UIScrollView()
    let bg = UIView()
    
    let v = TButton(frame: CGRect(x: 0, y: 0, width: 80, height: 30), text: "vegetarian")
    let v2 = TButton(frame: CGRect(x: 0, y: 0, width: 80, height: 30), text: "vegan")
    let n = TButton(frame: CGRect(x: 0, y: 0, width: 80, height: 30), text: "contains_nuts")
    let d = TButton(frame: CGRect(x: 0, y: 0, width: 80, height: 30), text: "dairy_free")
    let g = TButton(frame: CGRect(x: 0, y: 0, width: 80, height: 30), text: "gluten_free")
    
    let diet: String
    
    init(title: String?, subtitle: String?, price: Int?, position: Int, diet: String) {
        self.title = title
        self.subtitle = subtitle
        self.price = price
        self.diet = diet
        super .init(frame: CGRect(x: 20, y: 20 + (CGFloat(position) * 150), width: UIScreen.main.bounds.width-40, height: 170))
        scroll.frame = CGRect(x: 10, y: 130, width: frame.width-20, height: 30)
        
        layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        layer.borderWidth = 1
        layer.cornerRadius = 4
        
        let t = SearchBar(frame: CGRect(x: 10, y: 10, width: frame.width-20, height: 30), placeholder: "title", type: .search)
        let s = SearchBar(frame: CGRect(x: 10, y: 50, width: frame.width-20, height: 30), placeholder: "subtitle", type: .search)
        
        addSubview(t)
        addSubview(s)
        
        t.input.addTarget(self, action: #selector(updateTitle), for: .allEditingEvents)
        s.input.addTarget(self, action: #selector(updateSubitle), for: .allEditingEvents)
        
        delete.accessibilityElements = [self]
        delete.setImage(UIImage(named: "delete"), for: .normal)
        addSubview(delete)
        
        let currency = UILabel(frame: CGRect(x: frame.width-300, y: 90, width: 90, height: 30))
        currency.text = "price:   £"
        currency.font = Settings.shared.font
        currency.textAlignment = .right
        currency.textColor = .white
        addSubview(currency)
        
        let point = UILabel(frame: CGRect(x: frame.width-120, y: 90, width: 30, height: 30))
        point.text = "•"
        point.font = Settings.shared.font
        point.textAlignment = .center
        point.textColor = .white
        addSubview(point)
        
        pounds.frame = CGRect(x: frame.width-200, y: 90, width: 80, height: 30)
        pence.frame = CGRect(x: frame.width-90, y: 90, width: 80, height: 30)
        pence.makeChange()
        
        for box in [pounds,pence]{
            box.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            box.layer.borderWidth = 1
            box.layer.cornerRadius = 4
            box.backgroundColor = .white
            box.keyboardType = .numberPad
            box.textColor = .black
            box.font = Settings.shared.font
            box.textAlignment = .center
            box.addTarget(self, action: #selector(updatePrice), for: .allEditingEvents)
            addSubview(box)
        }
        
        if let tt = title{
            t.input.text = tt
            t.denullify()
            t.textChanged()
        }
        
        if let ss = subtitle{
            s.input.text = ss
            s.denullify()
            s.textChanged()
            
        }
        
        if let pp = price{
            pounds.text = String(pp/100)
            pence.text = String(pp%100)
        }
        addSubview(scroll)
        
        var i = 0
        var w = CGFloat(0.0)
        for button in [v,v2,n,d,g]{
            let width = (button.titleLabel!.text!.width(font: button.titleLabel!.font))+10
            button.frame = CGRect(x: w, y: 0, width: width, height: 30)
            scroll.addSubview(button)
            w += width + 5
            button.addTarget(self, action: #selector(click), for: .touchUpInside)
            button.setTitle(button.titleLabel!.text?.replacingOccurrences(of: "_", with: " "), for: .normal)
            if diet.count > 0{
                if diet.characterAtIndex(index: i) == "1"{
                    button.click()
                }
            }
            i += 1
        }
        scroll.contentSize = CGSize(width: w-5, height: 30)
        scroll.showsHorizontalScrollIndicator = false
        
        
    }
    
    @objc func click(sender: TButton){
        if let page = Settings.shared.home?.container?.pages.first(where: {$0 is PageEditMenu}) as? PageEditMenu{
            var temp = page.path
            temp.append(position)
            Firebase.shared.updateDietary(temp,getCode())
        }
    }
    
    private func getCode() -> String{
        var str = ""
        for a in [v,v2,n,d,g]{
            if a.clicked{
                str += "1"
            }
            else{
                str += "0"
            }
        }
        return str
    }
    
    func redisplay(){
        if !edit{
            removeAll()
            backgroundColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
            layer.cornerRadius = 10
            layer.borderWidth = 0
            
            frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width+20, height: frame.height-50)
            
            if let prc = price{
                
                var message = false
                
                if prc == 0{
                    message = true
                }
                else{
                    let label = UILabel(frame: CGRect(x: frame.width-100, y: 0, width: 90, height: 50))
                    label.text = prc.price(currency: .GBP)
                    label.font = Settings.shared.font
                    label.textAlignment = .right
                    label.increase(-1)
                    addSubview(label)
                }
                
                if let t = title{
                    let label = UILabel(frame: CGRect(x: 10, y: 0, width: frame.width-120, height: 50))
                    if message{
                        label.frame = CGRect(x: 10, y: 0, width: frame.width-20, height: 50)
                    }
                    label.text = t
                    label.font = Settings.shared.font
                    label.numberOfLines = 0
                    label.increase(-1)
                    addSubview(label)
                    
                }
            }
            
            if let t = subtitle{
                let label = UILabel(frame: CGRect(x: 10, y: 50, width: frame.width-20, height: frame.height-60))
                label.text = t
                label.textAlignment = .center
                label.font = Settings.shared.font
                label.numberOfLines = 0
                label.increase(-2)
                addSubview(label)
                
                label.backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
                label.layer.cornerRadius = 6
                label.clipsToBounds = true
            }
            
            if subtitle == nil || subtitle?.count == 0{
                frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: 50)
            }
            
            bg.frame = frame
            bg.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2548694349)
            bg.layer.cornerRadius = layer.cornerRadius
            
            var i = 0
            var j = 0
            let points = [
                CGPoint(x: frame.width - 65, y: 12.5),
                CGPoint(x: frame.width - 40, y: 12.5),
                CGPoint(x: frame.width - 15, y: 12.5),
                CGPoint(x: frame.width - 65, y: 37.5),
                CGPoint(x: frame.width - 40, y: 37.5)
            ]
            
            if diet.count > 0{
                for a in [dietaryConfinement.vegetarian,dietaryConfinement.vegan,dietaryConfinement.nuts,dietaryConfinement.dairy,dietaryConfinement.gluten]{
                    if diet.characterAtIndex(index: i) == "1"{
                        bg.addSubview(Dietary(center: points[j], type: a))
                        j += 1
                    }
                    i += 1
                }
            }
            
            scroll.removeFromSuperview()
        }
    }
    
    @objc func updatePrice(){
        if let pnd = Int(pounds.text!){
            if let pnc = Int(pence.text!){
                price = (100*pnd)+pnc
            }
        }
    }
    
    func save(_ path: [Int]) {
        var temp = path
        temp.append(position)
        if let t = title{
            if let p = price{
                if let s = subtitle{
                    Firebase.shared.saveMenuItem(title: t, subtitle: s, price: p, path: temp)
                }
                else{
                    Firebase.shared.saveMenuItem(title: t, price: p, path: temp)
                }
                layer.borderColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
                return
            }
        }
        layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
    
    func textFields() -> [UITextField]{
        var all = [UITextField]()
        for subview in subviews{
            if subview is UITextField{
                all.append(subview as! UITextField)
            }
            if subview is SearchBar{
                all.append((subview as! SearchBar).input)
            }
        }
        return all
    }
    
    @objc func updateTitle(sender: UITextField){
        if let bar = sender.superview?.superview as? SearchBar{
            if !bar.check(){
                title = ""
                return
            }
        }
        if let text = sender.text{
            title = text
        }
    }
    
    @objc func updateSubitle(sender: UITextField){
        if let bar = sender.superview?.superview as? SearchBar{
            if !bar.check(){
                subtitle = ""
                return
            }
        }
        if let text = sender.text{
            subtitle = text
        }
    }
    
    func update(_ minY: CGFloat, _ position: Int){
        frame = CGRect(x: 20, y: 20 + minY, width: frame.width, height: frame.height)
        self.position = position
        
        if let _ = Settings.shared.home?.container?.pages.first(where: {$0 is PageFoodMenu}){
            
            self.frame = CGRect(x: 10, y: 20 + minY, width: self.frame.width, height: self.frame.height)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

