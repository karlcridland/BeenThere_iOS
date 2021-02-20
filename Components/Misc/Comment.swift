//
//  Comment.swift
//  Been There
//
//  Created by Karl Cridland on 23/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class Comment: UIView{
    
    let date: Date
    var text: LinkText?
    
    init(uid: String, comment: String, date: String){
        self.date = date.datetime()!
        super .init(frame: CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width-20, height: 100))
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { timer in
            if let profile = Settings.shared.getProfile(uid){
                timer.invalidate()
                
                let title = UILabel(frame: CGRect(x: 5, y: 5, width: self.frame.width/2+20, height: 20))
                let timeStamp = UILabel(frame: CGRect(x: self.frame.width/2+35, y: 5, width: self.frame.width/2-40, height: 20))
                title.text = profile.name
                title.font = Settings.shared.font
                title.increase(-1)
                timeStamp.text = date.datetime()!.dmy()
                timeStamp.font = Settings.shared.font
                timeStamp.textAlignment = .right
                timeStamp.increase(-1)
                
                self.addSubview(title)
                self.addSubview(timeStamp)
                
                let pic = ProfileImage(frame: CGRect(x: 5, y: 30, width: 50, height: 50), uid: uid)
                self.addSubview(pic)
                pic.addLink()
                
                self.text = LinkText(frame: CGRect(x: 60, y: 30, width: self.frame.width-65, height: self.frame.height))
                if let text = self.text{
                    text.text = comment
                    text.font = UIFont(name: text.font!.fontName, size: text.font!.pointSize-1)
                    text.backgroundColor = .white
                    text.overrideColor = .black
                    text.addLinks()
                    text.layer.cornerRadius = 5
                    self.addSubview(text)
                    
                    if (text.contentSize.height < 60){
                        text.frame = CGRect(x: 60, y: 30, width: self.frame.width-65, height: 60)
                    }
                    else{
                        text.frame = CGRect(x: 60, y: 30, width: self.frame.width-65, height: [text.contentSize.height,CGFloat(120)].min()!)
                    }
                    self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: text.frame.maxY+5)
                }
            }
            else{
                Firebase.shared.storeProfile(uid, with: {}, completion: {})
            }
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
