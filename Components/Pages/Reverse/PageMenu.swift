//
//  PageMenu.swift
//  Kaktus
//
//  Created by Karl Cridland on 12/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageMenu: PageReverse {
    
    let createPost = MenuButton(title: "create post", position: 1)
    let reviewTags = MenuButton(title: "review tags", position: 2)
    let settings = MenuButton(title: "settings", position: 3)
    let privacy = MenuButton(title: "privacy policy", position: 4)
    let terms = MenuButton(title: "terms & conditions", position: 5)
    
    init() {
        super .init(title: "menu")
        
        for button in [createPost,reviewTags,settings,privacy,terms]{
            scroll.addSubview(button)
        }
        
        scroll.contentSize = CGSize(width: scroll.frame.width, height: terms.frame.maxY+20)
        
        createPost.addTarget(self, action: #selector(createPostPage), for: .touchUpInside)
        reviewTags.addTarget(self, action: #selector(openTagReviewer), for: .touchUpInside)
        settings.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        privacy.addTarget(self, action: #selector(openPrivacy), for: .touchUpInside)
        terms.addTarget(self, action: #selector(openTerms), for: .touchUpInside)
        
        if let profile = Settings.shared.getProfile(Settings.shared.get().uid){
            if profile.isBusiness(){
                let business = MenuButton(title: "business", position: 5)
                let magnify = MenuButton(title: "magnify", position: 6)
                let menu = MenuButton(title: "menus", position: 7)
                let drinks = MenuButton(title: "drinks", position: 8)
                let open = MenuButton(title: "opening hours", position: 9)
                let extra = MenuButton(title: "extra info", position: 10)
                
                business.layer.borderWidth = 0
                for button in [business,menu,drinks,open,extra,magnify]{
                    scroll.addSubview(button)
                }
                menu.addTarget(self, action: #selector(openMenuEdit), for: .touchUpInside)
                drinks.addTarget(self, action: #selector(openDrinksEdit), for: .touchUpInside)
                open.addTarget(self, action: #selector(openBusinessEdit), for: .touchUpInside)
                extra.addTarget(self, action: #selector(openExtraInfo), for: .touchUpInside)
                magnify.addTarget(self, action: #selector(openMagnify), for: .touchUpInside)
                
                reviewTags.removeFromSuperview()
                settings.update(2)
                privacy.update(3)
                terms.update(4)
                
                scroll.contentSize = CGSize(width: scroll.frame.width, height: extra.frame.maxY+20)
            }
        }
    }
    
    @objc func openPrivacy(){
        if let url = URL(string: "https://been-there.co.uk/privacy-policy.html") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func openTerms(){
        if let url = URL(string: "https://been-there.co.uk/terms-conditions.html") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func createPostPage(){
        Settings.shared.home?.container?.append(PageCreatePost())
    }
    
    @objc func openTagReviewer(){
        Settings.shared.home?.container?.append(PageSortTagged())
    }
    
    @objc func openSettings(){
        Settings.shared.home?.container?.append(PageSettings())
    }
    
    @objc func openMenuEdit(){
        Settings.shared.home?.container?.append(PageEditMenu())
    }
    
    @objc func openDrinksEdit(){
        Settings.shared.home?.container?.append(PageEditDrinks())
    }
    
    @objc func openBusinessEdit(){
        Settings.shared.home?.container?.append(PageEditBusiness())
    }
    
    @objc func openExtraInfo(){
        Settings.shared.home?.container?.append(PageEditInfo())
    }
    
    @objc func openMagnify(){
        Settings.shared.home?.container?.append(PageMagnify(managed: true))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MenuButton: UIButton {
    
    init(title: String, position: Int) {
        super .init(frame: CGRect(x: 20, y: 20 + (CGFloat(position-1) * 60), width: UIScreen.main.bounds.width-40, height: 40))
        if frame.width > 350{
            frame = CGRect(x: UIScreen.main.bounds.width/2-175, y: frame.minY, width: 350, height: 40)
        }
        setTitle(title, for: .normal)
        titleLabel!.font = Settings.shared.font
        layer.cornerRadius = 5
        layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        layer.borderWidth = 1.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ position: Int){
        frame = CGRect(x: 20, y: 20 + (CGFloat(position-1) * 60), width: UIScreen.main.bounds.width-40, height: 40)
        if frame.width > 350{
            frame = CGRect(x: UIScreen.main.bounds.width/2-175, y: frame.minY, width: 350, height: 40)
        }
    }
}
