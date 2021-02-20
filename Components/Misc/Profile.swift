//
//  Profile.swift
//  Kaktus
//
//  Created by Karl Cridland on 12/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class Profile{
    
    let uid: String
    var name: String
    var username: String?
    var distance: Double?
    
    var image: UIImage?
    
    var relevancy: Double?
    
    var drink: String?
    var price: Double?
    
    var context: String?
    
    var hasImage = true
    var isLoading = false
    
    init(uid: String, name: String, username: String){
        self.uid = uid
        self.name = name
        self.username = username
        Firebase.shared.getProfileImage(self)
        if uid == Settings.shared.get().uid{
            Settings.shared.set(name)
        }
    }
    
    init(uid: String, name: String, distance: Double?){
        self.uid = uid
        self.name = name
        self.distance = distance
        Firebase.shared.getProfileImage(self)
        if uid == Settings.shared.get().uid{
            Settings.shared.set(name)
        }
    }
    
    func isBusiness() -> Bool{
        return distance != nil
    }
    
    func display() -> ProfileDisplay{
        return ProfileDisplay(self)
    }
    
    func update(_ username: String){
        self.username = username
    }
    
    func updateName(_ name: String){
        self.name = name
    }
    
}

class ProfileDisplay: UIView{
    
    let profile: Profile
    
    let light = UIView(frame: CGRect(x: 81, y: 48, width: 4, height: 4))
    private var top = UILabel()
    private var bottom = UILabel()
    
    init(_ profile: Profile) {
        self.profile = profile
        super .init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80))
        
        let image = ProfileImage(frame: CGRect(x: 10, y: 10, width: 60, height: 60), uid: profile.uid)
        addSubview(image)
        image.layer.cornerRadius = 30
        
        top = UILabel(frame: CGRect(x: 80, y: 10, width: frame.width-90, height: 30))
        bottom = UILabel(frame: CGRect(x: 80, y: 35, width: frame.width-90, height: 30))
        
        addSubview(light)
        light.isHidden = true
        light.layer.cornerRadius = 2
        
        if profile.isBusiness(){
            top.text = profile.name
            if profile.distance! > 3{
                bottom.text = "\(profile.distance!) km away"
            }
            else{
                if profile.context == nil{
                    Firebase.shared.openYet(bottom,profile.uid,light)
                }
            }
        }
        else{
            top.text = profile.name
            bottom.text = "@\(profile.username!)"
        }
        
        if let context = profile.context{
            bottom.text = context
            profile.context = nil
        }
        
        for text in [top,bottom]{
            text.textColor = .white
            text.font = Settings.shared.font
            addSubview(text)
        }
        
        bottom.increase(-2)
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: 80))
        button.addTarget(self, action: #selector(clicked), for: .touchUpInside)
        addSubview(button)
    }
    
    @objc func clicked(){
        Firebase.shared.getPage(profile.uid)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
