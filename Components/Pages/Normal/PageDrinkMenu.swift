//
//  PageDrinkMenu.swift
//  Been There
//
//  Created by Karl Cridland on 20/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageDrinkMenu: Page, UIScrollViewDelegate{
    
    let uid:String
    var drinks = [String:[String:[String:Drink]]]()
    
    init(uid: String) {
        self.uid = uid
        super .init(title: "drinks menu")
        Firebase.shared.getDrinkPrices(self)
        scroll.delegate = self
    }
    
    func display() {
        var h = CGFloat(0.0)
        scroll.removeAll()
        var alt = false
        for sort in drinks.keys.sorted(){
            var countA = 0
            let sortB = DrinkBanner(title: sort, sub: false, first: false)
            sortB.frame = CGRect(x: 0, y: h, width: sortB.frame.width, height: sortB.frame.height)
            sortB.min = h
            for type in drinks[sort]!.keys.sorted(){
                var countB = 0
                let typeB = DrinkBanner(title: type, sub: true, first: countA == 0)
                typeB.frame = CGRect(x: 0, y: h+20, width: typeB.frame.width, height: typeB.frame.height)
                if countA != 0{
                    typeB.frame = CGRect(x: 0, y: h, width: typeB.frame.width, height: typeB.frame.height)
                }
                typeB.min = h + 20
                for drink in drinks[sort]![type]!.keys.sorted(){
                    if let result = drinks[sort]![type]![drink]{
                        alt = !alt
                        result.alt = alt
                        let view = result.display()
                        view.frame = CGRect(x: 0, y: h, width: view.frame.width, height: view.frame.height)
                        scroll.addSubview(view)
                        h += view.frame.height
                        countA += 1
                        countB += 1
                    }
                    
                }
                typeB.max = h
                if String(type) != "nil" && countB > 0{
                    scroll.addSubview(typeB)
                }
                else{
                    sortB.max = 20
                }
            }
            sortB.max = sortB.max + h - 20
            if countA > 0{
                scroll.addSubview(sortB)
            }
        }
        scroll.contentSize = CGSize(width: scroll.frame.width, height: h)
        
        for subview in scroll.subviews{
            if subview is DateBanner{
                scroll.bringSubviewToFront(subview)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for subview in scroll.subviews{
            if let banner = subview as? DrinkBanner{
                banner.inView()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
