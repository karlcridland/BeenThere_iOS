//
//  PageSettings.swift
//  Been There
//
//  Created by Karl Cridland on 13/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageSettings: PageReverse {
    
    let rangeTitle = MenuButton(title: "search range", position: 1)
    let range = UISlider(frame: CGRect(x: 20, y: 85, width: UIScreen.main.bounds.width-100, height: 30))
    let distance = UILabel(frame: CGRect(x: UIScreen.main.bounds.width-80, y: 85, width: 70, height: 30))
    let social = MenuButton(title: "social", position: 3)
    let share = MenuButton(title: "share", position: 4)
    let details = MenuButton(title: "update details", position: 6)
    let account = MenuButton(title: "account", position: 5)
    let password = MenuButton(title: "change password", position: 7)
    let delete = MenuButton(title: "delete account", position: 8)
    
    init(){
        super .init(title: "settings")
        scroll.addSubview(rangeTitle)
        rangeTitle.layer.borderWidth = 0
        scroll.addSubview(range)
        scroll.addSubview(distance)
        distance.textAlignment = .right
        distance.font = Settings.shared.font
        range.addTarget(self, action: #selector(sliding), for: .allEvents)
        range.addTarget(self, action: #selector(slid), for: .primaryActionTriggered)
        Firebase.shared.getRange(self)
        scroll.addSubview(social)
        social.layer.borderWidth = 0
        scroll.addSubview(share)
        share.addTarget(self, action: #selector(shared), for: .touchUpInside)
        scroll.addSubview(details)
        details.addTarget(self, action: #selector(editBasic), for: .touchUpInside)
        scroll.addSubview(account)
        account.layer.borderWidth = 0
        scroll.addSubview(password)
        password.addTarget(self, action: #selector(resetPassword), for: .touchUpInside)
        scroll.addSubview(delete)
        delete.addTarget(self, action: #selector(deleteAccount), for: .touchUpInside)
    }
    
    @objc func resetPassword(){
        if let email = Settings.shared.email(){
            let p = ResetPassword(email: email)
            p.emailForm.input.resignFirstResponder()
            p.emailForm.input.isUserInteractionEnabled = false
            p.click()
        }
    }
    
    @objc func editBasic(){
        Settings.shared.home?.container?.append(PageEditBasic())
    }
    
    @objc func deleteAccount(){
        let _ = DeleteAccount()
    }
    
    @objc func sliding(){
        let d = Int(100*(range.value*95.0/100.0)+5)
        distance.text = "\(d) km"
    }
    
    @objc func slid(){
        let d = Int(100*(range.value*95.0/100.0)+5)
        Settings.shared.distance = Double(d)
        Firebase.shared.updateRange(d)
    }
    
    func slideStart(_ position: Int){
        range.value = (Float(position - 5)/95)
        distance.text = "\(position) km"
    }
    
    @objc func shared(){
        
        var text  = ""
        if let profile = Settings.shared.getProfile(Settings.shared.get().uid){
            if profile.isBusiness(){
                text = "Come find us on Been-There, search for \(profile.name) com.been-there://?\(Settings.shared.get().uid)"
            }
            else{
                text = "Come join me on Been-There, I'm on there as @\(profile.username!) com.been-there://?\(Settings.shared.get().uid)"
            }
        }

        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = Settings.shared.home?.view // so that iPads won't crash

        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop ]

        // present the view controller
        if let home = Settings.shared.home{
            home.present(activityViewController, animated: true, completion: nil)
        }
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

