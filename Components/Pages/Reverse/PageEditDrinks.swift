//
//  PageEditDrinks.swift
//  Been There
//
//  Created by Karl Cridland on 18/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageEditDrinks: PageReverse, UIScrollViewDelegate {
    
    var drinks = [String:[String:[String:Drink]]]()
    let search = SearchBar(frame: CGRect(x: 10, y: 10, width: UIScreen.main.bounds.width-20, height: 30), placeholder: "search", type: .search)
    
    init(){
        super .init(title: "edit drinks")
        Firebase.shared.getDrinkList(self)
        scroll.delegate = self
        scroll.frame = CGRect(x: 0, y: 50, width: frame.width, height: frame.height-50)
        addSubview(search)
        search.input.addTarget(self, action: #selector(query), for: .allEditingEvents)
        search.clear.addTarget(self, action: #selector(query), for: .touchUpInside)
    }
    
    @objc func query(){
        if search.text().count > 0{
            display(search.text().lowercased())
        }
        else{
            display(nil)
        }
    }
    
    override func disappear() {
        super.disappear()
        drinks.removeAll()
    }
    
    func display(_ query: String?) {
        var h = CGFloat(0.0)
        scroll.removeAll()
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
                        if let q = query{
                            if (result.name.lowercased().folding(options: .diacriticInsensitive, locale: .current).match(q) > 0 || String(type).contains(q) || String(sort).contains(q)){
                                let view = result.display()
                                view.frame = CGRect(x: 0, y: h, width: view.frame.width, height: view.frame.height)
                                scroll.addSubview(view)
                                h += view.frame.height
                                countA += 1
                                countB += 1
                            }
                        }
                        else{
                            let view = result.display()
                            view.frame = CGRect(x: 0, y: h, width: view.frame.width, height: view.frame.height)
                            scroll.addSubview(view)
                            h += view.frame.height
                            countA += 1
                            countB += 1
                        }
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
        if scroll.isTracking{
            UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
