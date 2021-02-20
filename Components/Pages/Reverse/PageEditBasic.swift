//
//  PageEditBasic.swift
//  Been There
//
//  Created by Karl Cridland on 24/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageEditBasic: PageReverse{
    
    let name = SearchBar(frame: CGRect(x: 110, y: 20, width: UIScreen.main.bounds.width-120, height: 30), placeholder: "name", type: .search)
    let username = SearchBar(frame: CGRect(x: 110, y: 70, width: UIScreen.main.bounds.width-120, height: 30), placeholder: "username", type: .username)
    let address = SearchBar(frame: CGRect(x: 110, y: 70, width: UIScreen.main.bounds.width-120, height: 30), placeholder: "address", type: .search)
    
    init(){
        super .init(title: "edit info")
        scroll.addSubview(name)
        scroll.addSubview(username)
        
        let n = UILabel(frame: CGRect(x: 10, y: 20, width: 90, height: 30))
        let u = UILabel(frame: CGRect(x: 10, y: 70, width: 90, height: 30))
        n.text = "name:"
        u.text = "username:"
        n.font = Settings.shared.font
        u.font = Settings.shared.font
        scroll.addSubview(n)
        scroll.addSubview(u)
        
        if let profile = Settings.shared.getProfile(Settings.shared.get().uid){
            name.input.text = profile.name
            username.input.text = profile.username
            name.denullify()
            username.denullify()
            
            if profile.isBusiness(){
                username.removeFromSuperview()
                u.text = "address:"
                scroll.addSubview(address)
                Firebase.shared.getAddress(self)
            }
        }
        username.textChanged()
        name.input.becomeFirstResponder()
    }
    
    func update(){
        if name.text().count == 0{
            failure(type: .empty)
            return
        }
        if let profile = Settings.shared.getProfile(Settings.shared.get().uid){
            if profile.isBusiness(){
                if address.text().count == 0{
                    failure(type: .empty)
                    return
                }
                Firebase.shared.updateAddress(self)
                return
            }
            if username.text().count == 0{
                failure(type: .empty)
                return
            }
            Firebase.shared.updateUsername(self)
        }
    }
    
    func success(){
        popup("successful update")
    }
    
    func failure(type: FailedUpdate){
        switch type {
        case .empty:
            popup("all fields need to be filled")
            break
        case .usernameTaken:
            popup("username taken")
            break
        case .network:
            popup("network error")
            break
        }
    }
    
    func popup(_ text: String){
        for subview in scroll.subviews{
            if subview.tag == -1{
                subview.removeFromSuperview()
            }
        }
        
        let s = UILabel(frame: CGRect(x: 10, y: 120, width: frame.width-20, height: 30))
        s.tag = -1
        scroll.addSubview(s)
        s.textAlignment = .center
        s.text = text
        s.font = Settings.shared.font
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { _ in
            s.removeFromSuperview()
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

enum FailedUpdate{
    case usernameTaken
    case empty
    case network
}
