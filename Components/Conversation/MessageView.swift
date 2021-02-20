//
//  MessageView.swift
//  Been There
//
//  Created by Karl Cridland on 05/10/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class MessageView: LinkText{
    let m: String
    let me: Bool
    var timer: Timer?
    
    
    init(frame: CGRect, message: String, me: Bool) {
        self.m = message
        self.me = me
        super .init(frame: frame, textContainer: nil)

        self.text = message
        self.overrideColor = .black
        self.addLinks()
        self.layer.cornerRadius = 5
        
        self.isSelectable = false
    }
    
    func ghost(){
        textAlignment = .center
        backgroundColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
        let colors = [#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1),#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1),#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1),#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1),#colorLiteral(red: 1, green: 0.5212053061, blue: 1, alpha: 1),#colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)]
        var i = 0
        font = UIFont(name: Settings.shared.font!.fontName, size: 14)
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true, block: { timer in
            UIView.animate(withDuration: 1.5, animations: {
                self.backgroundColor = colors[i%colors.count]
            })
            if self.timer == nil{
                self.timer = timer
            }
            i += 1
        })
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        if let timer = self.timer{
            timer.invalidate()
        }
    }
    
    override func addLinks(){
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
        font = UIFont(name: Settings.shared.font!.fontName, size: 12)
        frame = CGRect(x: frame.minX, y: frame.minY, width: contentSize.width, height: contentSize.height)
        
        if Int(self.contentSize.height / self.font!.lineHeight) - 1 <= 1{
            frame = CGRect(x: frame.minX, y: frame.minY, width: m.width(font: font!)+20, height: contentSize.height)
            var x = false
            while Int(self.contentSize.height / self.font!.lineHeight) - 1 > 1{
                x = true
                frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width+5, height: contentSize.height)
            }
            if x{
                frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width+10, height: contentSize.height)
            }
        }
        if me{
            frame = CGRect(x: UIScreen.main.bounds.width-frame.width-5, y: frame.minY, width: frame.width, height: frame.height)
        }
        self.accessibilityFrame = self.frame
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
