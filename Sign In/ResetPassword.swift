//
//  ResetPassword.swift
//  Been There
//
//  Created by Karl Cridland on 24/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class ResetPassword: FocusView {
    
    let emailForm: SearchBar
    
    init(email: String){
        self.emailForm = SearchBar(frame: CGRect(x: 10, y: 40, width: 280, height: 30), placeholder: "email", type: .email)
        super .init(width: 300, height: 120)
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 30))
        title.text = "send reset password to:"
        addSubview(title)
        title.textAlignment = .center
        title.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        title.font = Settings.shared.font
        
        center = CGPoint(x: center.x, y: 300)
        
        addSubview(emailForm)
        emailForm.input.text = email
        emailForm.denullify()
        
        let cancel = UIButton(frame: CGRect(x: 0, y: frame.height-40, width: 80, height: 40))
        cancel.setTitle("cancel", for: .normal)
        cancel.titleLabel?.font = Settings.shared.font
        cancel.setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), for: .normal)
        cancel.addTarget(self, action: #selector(exit), for: .touchUpInside)
        addSubview(cancel)
        
        let submit = UIButton(frame: CGRect(x: frame.width-50, y: frame.height-37, width: 35, height: 35))
        submit.setImage(UIImage(named: "logo-clear"), for: .normal)
        addSubview(submit)
        submit.addTarget(self, action: #selector(click), for: .touchUpInside)
        
        emailForm.input.becomeFirstResponder()
        
    }
    
    @objc func click(){
        if emailForm.check(){
            Settings.shared.resetPassword(self)
        }
    }
    
    func emailSent(){
        for subview in subviews{
            UIView.animate(withDuration: 0.1, animations: {
                subview.alpha = 0
            })
        }
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
            let title = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 120))
            title.text = "email sent"
            self.addSubview(title)
            title.textAlignment = .center
            title.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            title.font = Settings.shared.font
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in
                self.exit()
            })
        })
    }
    
    @objc func exit(){
        removeFromSuperview()
        emailForm.input.resignFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
