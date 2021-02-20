//
//  LinkText.swift
//  waitt
//
//  Created by Karl Cridland on 25/05/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class LinkText: UITextView, UITextViewDelegate{
    
    var keyboardHeight: CGFloat?
    var extra: (() -> Void)?
    var overrideColor: UIColor?
    var overrideFont: UIFont?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        
        super .init(frame: frame, textContainer: textContainer)
        textAlignment = .center
        textAlignment = .left
        delegate = self
        isEditable = false
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        font = Settings.shared.font
        backgroundColor = .clear
        textColor = .white
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            
        }
    }
    
    @objc func tapped(recognizer: UITapGestureRecognizer){
        if !isEditable{
            let location: CGPoint = recognizer.location(in: self)
            let position: CGPoint = CGPoint(x: location.x, y: location.y)

            let tapPosition: UITextPosition = self.closestPosition(to: position)!
            
            guard let textRange: UITextRange = self.tokenizer.rangeEnclosingPosition(tapPosition, with: UITextGranularity.word, inDirection: UITextDirection(rawValue: 1)) else {
                return
            }
            let a = Int(self.offset(from: self.beginningOfDocument, to: textRange.start))-1
            
            if a > 0{
                if let position = self.text.charIndex(index: a){
                    if (position == "@"){
                        
                        let username: String = (self.text(in: textRange) ?? "").lowercased()
                        if let user = Settings.shared.getUID(username){
                            Firebase.shared.getPage(user)
                        }
                        else{
                            Firebase.shared.storeProfileFromUsername(username,true)
                        }
                    }
                }
            }
            else if a == 0{
                if (self.text.charIndex(index: 0)! == "@"){
                    
                    let username: String = (self.text(in: textRange) ?? "").lowercased()
                    if let user = Settings.shared.getUID(username){
                        Firebase.shared.getPage(user)
                    }
                    else{
                        Firebase.shared.storeProfileFromUsername(username,true)
                    }
                }
            }
            self.selectedTextRange = self.textRange(from: self.beginningOfDocument, to: self.beginningOfDocument)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        addLinks()
        if let p = pos(){
            let arbitraryValue: Int = p
            if let newPosition = self.position(from: self.beginningOfDocument, offset: arbitraryValue) {
                self.selectedTextRange = self.textRange(from: newPosition, to: newPosition)
            }
        }
        if let action = extra{
            action()
        }
    }
    
    func increase(_ by: CGFloat){
        font = Settings.shared.font
        font = UIFont(name: font!.fontName, size: font!.pointSize+by)
    }
    
    func addLinks(){
        let attributedString = NSMutableAttributedString.init(string: text!)
        let range = (text! as NSString).range(of: String(text!))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: range)
        if isEditable{
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: range)
        }
        if let color = overrideColor{
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
        self.attributedText = attributedString
        for word in text!.split(separator: " "){
            if ((String(word).first! == "@") && (String(word).count > 1) && (String(word).charCount("@") == 1)){
                let range = (text! as NSString).range(of: String(word))
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemBlue, range: range)
                self.attributedText = attributedString
                Firebase.shared.storeProfileFromUsername(String(word),false)
            }
        }
        if let o = overrideFont{
            font = o
        }
        else{
            font = Settings.shared.font
        }
    }
    
    func resize(){
        frame = CGRect(x: frame.minX, y: frame.minY, width: contentSize.width, height: contentSize.height)
        addLinks()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
