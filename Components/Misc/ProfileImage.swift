//
//  ProfileImage.swift
//  Kaktus
//
//  Created by Karl Cridland on 12/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class ProfileImage: UIImageView {
    
    let uid: String
    init(frame: CGRect, uid: String) {
        self.uid = uid
        super .init(frame: frame)
        layer.cornerRadius = 5
        clipsToBounds = true
        self.image = UIImage(named: "placeholder")
        if let i = Settings.shared.getProfile(uid)?.image{
            self.image = i
        }
        else{
            if let profile = Settings.shared.getProfile(uid){
                if !profile.isLoading && profile.hasImage{
                    profile.isLoading = true
                    Firebase.shared.getProfileImage(profile)
                }
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
                    if let i = Settings.shared.getProfile(uid)?.image{
                        self.image = i
                        timer.invalidate()
                    }
                    if !profile.hasImage{
                        timer.invalidate()
                    }
                })
            }
        }
        contentMode = .scaleAspectFill
    }
    
    func addLink(){
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        addSubview(button)
        button.addTarget(self, action: #selector(openLink), for: .touchUpOutside)
    }
    
    @objc func openLink(){
        Firebase.shared.getPage(uid)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
