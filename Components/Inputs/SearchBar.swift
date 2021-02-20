//
//  SearchBar.swift
//  Solution
//
//  Created by Karl Cridland on 12/12/2019.
//  Copyright © 2019 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class SearchBar: UIView {
    
    let input: UITextField
    let clear: UIButton
    private let width: CGFloat
    private let background: UIView
    private let placeholder: String?
    private var nullified = false
    private let type: SearchType
    
    let textColor = #colorLiteral(red: 0.08182022721, green: 0.08184186369, blue: 0.08181738108, alpha: 1)
    
    init(frame: CGRect, placeholder: String?, type: SearchType){
        self.placeholder = placeholder
        self.type = type
        width = frame.width-70
        clear = UIButton(frame: CGRect(x: frame.width-60, y: 0, width: 60, height: frame.height))
        background = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        input = UITextField(frame: CGRect(x: 5, y: 0, width: frame.width-70, height: frame.height))
        super.init(frame: frame)
        input.text = ""
        background.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        background.layer.borderWidth = 1.0
        background.layer.cornerRadius = 4.0
        background.backgroundColor = .white
        background.addSubview(input)
        input.font = Settings.shared.font
        input.addTarget(self, action: #selector(textChanged), for: .allEditingEvents)
        input.addTarget(self, action: #selector(textStart), for: .editingDidBegin)
        input.addTarget(self, action: #selector(isEmptyOnExit), for: .editingDidEnd)
        
        clear.addTarget(self, action: #selector(clearInput), for: .touchUpInside)
        clear.setTitle("clear", for: .normal)
        clear.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
        clear.isHidden = true
        addSubview(background)
        addSubview(clear)
        input.addTarget(self, action: #selector(keyboardGone), for: .primaryActionTriggered)
        input.returnKeyType = UIReturnKeyType(rawValue: 9)!
        
        if let text = placeholder{
            input.text = text
            input.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            nullified = true
        }
        
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6965432363)
        layer.cornerRadius = 4.0
        
        input.isSecureTextEntry = false
    }
    
    @objc func textChanged(){
        background.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        if (type == .password) && (!nullified || text().count > 0){
            input.isSecureTextEntry = true
        }
        if (text().count > 0 && !nullified){
            input.textColor = textColor
            UIView.animate(withDuration: 0.2, animations: {
                self.background.frame = CGRect(x: 0, y: 0, width: self.frame.width-60, height: self.frame.height)
            })
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: {timer in
                if (self.input.text?.count == 0){
                    self.clear.isHidden = true
                }
                else{
                    self.clear.isHidden = false
                }
            })
        }
        else{
            UIView.animate(withDuration: 0.2, animations: {
                self.background.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            })
            if (input.text?.count == 0 || nullified){
                self.clear.isHidden = true
            }
            else{
                self.clear.isHidden = false
            }
        }
        if nullified{
            input.isSecureTextEntry = false
        }
        if type == .caption{
            addLinks(.black)
        }
    }
    
    @objc func keyboardGone(){
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    @objc func textStart(){
        if nullified || (type == .password && !isFirstResponder){
            input.text = ""
            nullified = false
            textChanged()
            input.becomeFirstResponder()
        }
    }
    
    func denullify(){
        nullified = false
        input.textColor = .black
    }
    
    @objc func clearInput(){
        input.text = ""
        nullified = false
        textChanged()
        input.becomeFirstResponder()
    }
    
    @objc func isEmptyOnExit(){
        if let p = placeholder{
            if input.text == ""{
                input.isSecureTextEntry = false
                nullified = true
                input.text = p
                input.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            }
        }
    }
    
    func text() -> String{
        if nullified{
            return ""
        }
        return input.text!
    }
    
    func check() -> Bool{
        if (nullified && text() == placeholder ){
            background.layer.borderColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
            return false
        }
        switch type {
        case .email:
            let first = text().split(separator: "@")
            if (first.count == 2){
                let second = String(first.last!).split(separator: ".")
                if (second.count > 1){
                    return true
                }
            }
            background.layer.borderColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
            return false
        case .password:
            if (((text().hasUpper()) && (text().hasDigit())) && (text().count > 7)){
                return true
            }
            background.layer.borderColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
            return false
        case .search:
            return text().count > 0
        case .username:
            return !Settings.shared.taken.contains(text().lowercased())
        case .caption:
            return true
        }
    }
    
    func addLinks(_ color: UIColor){
        let attributedString = NSMutableAttributedString.init(string: input.text!)
        let range = (input.text! as NSString).range(of: String(input.text!))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        self.input.attributedText = attributedString
        for word in input.text!.split(separator: " "){
            if ((String(word).first! == "@") && (String(word).count > 1) && (String(word).charCount("@") == 1)){
                let range = (input.text! as NSString).range(of: String(word))
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemBlue, range: range)
                self.input.attributedText = attributedString
                Firebase.shared.storeProfileFromUsername(String(word),false)
            }
        }
        input.font = Settings.shared.font
    }
    
    func registerForm() -> Register?{
        if let register = Settings.shared.home?.view.subviews.first(where: {$0 is Register}) as? Register{
            return register
        }
        return nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum SearchType{
    case search
    case email
    case password
    case username
    case caption
}
