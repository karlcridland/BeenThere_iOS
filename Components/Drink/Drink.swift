//
//  Drink.swift
//  Been There
//
//  Created by Karl Cridland on 20/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class Drink{
    
    let name: String
    let sort: String
    let type: String
    var image: UIImage?
    var inStock = false
    var price: Int?
    
    var edit = true
    
    let priceInput = UIView()
    let pound = UITextField()
    let pence = UITextField()
    
    var hasDisplayed = false
    var alt = false
    
    init(name: String, sort: String, type: String){
        self.name = name
        self.sort = sort
        self.type = type
        var temp = name.lowercased().folding(options: .diacriticInsensitive, locale: .current)
        temp.removeAll(where: {$0 == " " || $0 == "'"})
        
        if let img = UIImage(named: temp){
            image = img
        }
        
        priceInput.addSubview(pound)
        priceInput.addSubview(pence)
        
        for field in [pound,pence]{
            field.backgroundColor = .white
            field.layer.cornerRadius = 2
            field.font = Settings.shared.font
            field.textColor = .black
            field.textAlignment = .center
            field.keyboardType = .numberPad
            field.addTarget(self, action: #selector(submit), for: .allEditingEvents)
        }
        
        let w2 = (UIScreen.main.bounds.width - 220-60)/2
        
        let currency = UILabel(frame: CGRect(x: 0, y: 10, width: 30, height: 30))
        currency.text = "£"
        
        let point = UILabel(frame: CGRect(x: 30+w2, y: 10, width: 30, height: 30))
        point.text = "•"
        
        for label in [currency,point]{
            label.font = Settings.shared.font
            label.textAlignment = .center
            priceInput.addSubview(label)
        }
        
        pound.frame = CGRect(x: 30, y: 10, width: w2, height: 30)
        pence.frame = CGRect(x: 60+w2, y: 10, width: w2, height: 30)
        
        pound.makePounds()
        pence.makeChange()
    }
    
    @objc func click(sender: UIButton){
        if edit{
            inStock = !inStock
            if let view = sender.superview{
                if inStock{
                    priceInput.isHidden = false
                    view.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                    if let scroll = view.superview as? UIScrollView{
                        UIView.animate(withDuration: 0.3, animations: {
                            scroll.contentOffset = CGPoint(x: 0, y: view.frame.minY)
                        })
                        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
                            self.pound.becomeFirstResponder()
                        })
                    }
                }
                else{
                    priceInput.isHidden = true
                    view.backgroundColor = .clear
                    if hasDisplayed{
                        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
                        let temp = price
                        price = nil
                        Firebase.shared.updateDrinkPrice(self)
                        price = temp
                    }
                }
            }
        }
    }
    
    func update(){
        if let p = price{
            pound.text = String(p/100)
            pence.text = String(p%100).setw("0", 2)
            
        }
    }
    
    @objc func submit(){
        if let pnd = Int(pound.text!){
            if let pnc = Int(pence.text!){
                price = (pnd*100)+pnc
                Firebase.shared.updateDrinkPrice(self)
            }
        }
    }
    
    func display() -> UIView{
        hasDisplayed = false
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
        let pic = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        view.addSubview(pic)
        if let img = image{
            pic.image = img
        }
        let desc = UILabel(frame: CGRect(x: 210, y: 5, width: UIScreen.main.bounds.width - 220, height: 40))
        desc.text = name
        desc.font = Settings.shared.font
        desc.increase(-2)
        desc.numberOfLines = 0
        view.addSubview(desc)
        
        if edit{
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
            view.addSubview(button)
            button.addTarget(self, action: #selector(click), for: .touchUpInside)
            
            priceInput.frame = CGRect(x: 210, y: 50, width: UIScreen.main.bounds.width - 220, height: 50)
            view.addSubview(priceInput)
            
            click(sender: button)
            click(sender: button)
        }
        else{
//            desc.frame = CGRect(x: 210, y: 20, width: UIScreen.main.bounds.width - 220, height: 50)
            desc.removeFromSuperview()
            let p = UITextView(frame: CGRect(x: 200, y: 0, width: UIScreen.main.bounds.width - 200, height: 100))
            p.backgroundColor = .clear
            
            p.text = "\(desc.text!)\n\n\(price!.price(currency: .GBP))"
            p.font = desc.font
            p.isUserInteractionEnabled = false
            view.addSubview(p)
            priceInput.isHidden = true
            if alt{
                view.backgroundColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 0.3392016267)
            }
        }
        
        hasDisplayed = true
        return view
    }
}
