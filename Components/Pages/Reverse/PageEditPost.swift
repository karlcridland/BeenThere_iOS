//
//  PageEditPost.swift
//  Been There
//
//  Created by Karl Cridland on 17/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageEditPost: PageCreatePost {
    
    let event: WidgetEvent
    
    init(_ event: WidgetEvent){
        self.event = event
        super .init()
        
        name.input.text = event.subtitle.text
        caption.input.text = event.caption.text
        name.denullify()
        caption.denullify()
        
        question.isHidden = true
        check.isHidden = true
        if let p = (event as? WidgetUpcoming)?.poster{
            click()
            
            poster.isHidden = false
            poster.setImage(p.image, for: .normal)
            camera.isHidden = false
            date.isHidden = false
            let dateBlock = UIView(frame: date.frame)
            scroll.addSubview(dateBlock)
            dateBlock.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 0.4174068921)
            poster.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            poster.contentMode = .scaleAspectFill
            
            for a in [poster,camera,date,dateBlock]{
                a.center = CGPoint(x: a.center.x, y: a.center.y-35)
            }
            
            let d = event.event.date
            date.goTo(d.get(.day), d.get(.month), y: d.get(.year))
            
        }
        caption.input.becomeFirstResponder()
        name.input.resignFirstResponder()
    }
    
    override func submit(){
        
        if !check.isChecked{
            if let image = poster.imageView?.image{
                if (name.check() && caption.check() && date.laterDate()){
                    Firebase.shared.createEvent(date: event.event.date.datetime(), title: name.text(), caption: caption.text(), poster: image)
                    Settings.shared.home?.container?.removeAllPages()
                }
            }
            else{
                poster.layer.borderColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
            }
        }
        else{
            if (name.check() && caption.check()){
                Firebase.shared.createEvent(date: event.event.date.datetime(), title: name.text(), caption: caption.text(), poster: nil)
                Settings.shared.home?.container?.removeAllPages()
            }
        }
        event.subtitle.text = name.input.text
        event.caption.text = caption.input.text
        if let p = (event as? WidgetUpcoming)?.poster{
            p.image = poster.imageView?.image
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
