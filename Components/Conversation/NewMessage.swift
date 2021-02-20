//
//  NewMessage.swift
//  Been There
//
//  Created by Karl Cridland on 05/10/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class NewMessage: UIView{
    
    var scroll: UIScrollView?
    let input = SearchBar(frame: CGRect(x: 5, y: 5, width: UIScreen.main.bounds.width-50, height: 30), placeholder: "new message", type: .search)
    let uid: String
    var submit = UIButton()
    
    init(uid: String) {
        self.uid = uid
        super .init(frame: CGRect(x: 0, y: UIScreen.main.bounds.height-Settings.shared.lower_bound-Settings.shared.upper_bound-80, width: UIScreen.main.bounds.width, height: 40+Settings.shared.lower_bound))
        input.backgroundColor = .white
        
        addSubview(input)
        input.input.addTarget(self, action: #selector(keyboardResigned), for: .editingDidEndOnExit)
        
        backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        submit = UIButton(frame: CGRect(x: frame.width-40, y: 5, width: 30, height: 30))
        submit.setImage(UIImage(named: "logo-clear"), for: .normal)
        addSubview(submit)
        
        submit.addTarget(self, action: #selector(click), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
            self.input.input.becomeFirstResponder()
        })
    }
    
    @objc func click(){
        if input.check(){
            Firebase.shared.stopTyping(uid: uid)
            Firebase.shared.newMessage(uid: uid, message: input.text()+" ")
            input.clearInput()
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let height = keyboardFrame.cgRectValue.height
            UIView.animate(withDuration: 0.1, animations: {
                self.frame = CGRect(x: 0, y: UIScreen.main.bounds.height-Settings.shared.upper_bound-80-height, width: UIScreen.main.bounds.width, height: 40+Settings.shared.lower_bound)
                if let scroll = self.scroll{
                    scroll.frame = CGRect(x: 0, y: 0, width: scroll.frame.width, height: UIScreen.main.bounds.height-Settings.shared.upper_bound-40-height)
                    Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false, block: { _ in
                        if scroll.contentSize.height > scroll.frame.height{
                            scroll.contentOffset = CGPoint(x: 0, y: scroll.contentSize.height-scroll.frame.height)
                        }
                    })
                }
            })
        }
    }
    
    @objc func keyboardResigned(){
        UIView.animate(withDuration: 0.2, animations: {
            self.frame = CGRect(x: 0, y: UIScreen.main.bounds.height-Settings.shared.lower_bound-Settings.shared.upper_bound-80, width: UIScreen.main.bounds.width, height: 40+Settings.shared.lower_bound)
            if let scroll = self.scroll{
                scroll.frame = CGRect(x: 0, y: 0, width: scroll.frame.width, height: UIScreen.main.bounds.height-Settings.shared.upper_bound-40)
            }
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

