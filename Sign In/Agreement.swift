//
//  Agreement.swift
//  Kaktus
//
//  Created by Karl Cridland on 12/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class Agreement: UIView {
    
    let packet: UserPacket?
    let check = CButton(frame: CGRect(x: 30, y: UIScreen.main.bounds.height-Settings.shared.lower_bound-120, width: 20, height: 20))
    let confirm = UILabel(frame: CGRect(x: 70, y: UIScreen.main.bounds.height-Settings.shared.lower_bound-140, width: UIScreen.main.bounds.width-80, height: 60))
    let submit = UIButton(frame: CGRect(x: 40, y: UIScreen.main.bounds.height-Settings.shared.lower_bound-70, width: UIScreen.main.bounds.width-80, height: 30))
    
    init(packet: UserPacket){
        self.packet = packet
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform.identity
        })
        
        backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        
        addSubview(check)
        addSubview(confirm)
        confirm.text = "I confirm I have read both the EULA and the Terms & Conditions and agree to follow them while using Been-There"
        confirm.font = Settings.shared.font
        confirm.increase(-2)
        confirm.textColor = .white
        confirm.numberOfLines = 0
        
        submit.setTitle("confirm", for: .normal)
        submit.titleLabel?.font = Settings.shared.font
        submit.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 0.7)
        submit.layer.cornerRadius = 4.0
        addSubview(submit)
        
        submit.addTarget(self, action: #selector(submitForm), for: .touchUpInside)
        becomeFirstResponder()
        
        let title = UILabel(frame: CGRect(x: 0, y: Settings.shared.upper_bound+10, width: frame.width, height: 30))
        title.text = "End User Licence Agreement"
        title.textAlignment = .center
        title.textColor = .white
        title.font = Settings.shared.font
        addSubview(title)
        
        let box = UITextView(frame: CGRect(x: 10, y: 100, width: frame.width-20, height: frame.height-350))
        box.backgroundColor = .clear
        addSubview(box)
        box.textColor = .white
        box.font = UIFont(name: Settings.shared.fontName, size: Settings.shared.font!.pointSize-2)
        if let eula = String().readFile("EULA", "txt"){
            box.text = eula
        }
        let f = Settings.shared.font
        
        let terms = UIButton(frame: CGRect(x: 20, y: frame.height-240, width: frame.width-40, height: 30))
        terms.setTitle("Terms & Conditions", for: .normal)
        terms.contentHorizontalAlignment = .left
        terms.setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: .normal)
        terms.titleLabel?.font = f
        terms.addTarget(self, action: #selector(openTerms), for: .touchUpInside)
        addSubview(terms)
        
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = .dark
        }
    }
    
    @objc func openTerms(){
        if let url = URL(string: "https://been-there.co.uk/terms-conditions.html") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func submitForm(){
        if check.isChecked{
            if let user = packet{
                if user.isBusiness(){
                    Settings.shared.register(email: user.email!, password: user.password!, name: user.name!, address: user.address!)
                }
                else{
                    Settings.shared.register(email: user.email!, password: user.password!, username: user.username!, name: user.name!)
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class UserPacket{
    
    var name: String?
    var username: String?
    var password: String?
    var email: String?
    var address: String?
    
    init(name: String, username: String, password: String, email: String) {
        self.name = name
        self.username = username
        self.password = password
        self.email = email
    }
    
    init(name: String, address: String, password: String, email: String) {
        self.name = name
        self.address = address
        self.password = password
        self.email = email
    }
    
    func isBusiness() -> Bool{
        return address != nil
    }
}
