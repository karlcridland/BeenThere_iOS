//
//  PageEvent.swift
//  Been There
//
//  Created by Karl Cridland on 14/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageEvent: Page {
    
    let date: Date
    let event: Event?
    let uid: String
    var gallery = [Thumbnail]()
    
    init(date: String, uid: String, event: Event?) {
        self.event = event
        self.uid = uid
        self.date = date.datetime()!
        
        super .init(title: Settings.shared.getProfile(uid)!.name)
        
        let name = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50))
        name.text = event?.name
        addSubview(name)
        name.font = Settings.shared.font
        name.numberOfLines = 0
        name.textAlignment = .center
        name.increase(1)
        name.backgroundColor = backgroundColor?.withAlphaComponent(0.4)
        
        clipsToBounds = true
        scroll.clipsToBounds = false
        scroll.frame = CGRect(x: 0, y: 50, width: frame.width, height: frame.height-50)
        if let e = event{
            gallery = e.copy()
        }
        else{
            if let e = Settings.shared.events[uid]?[date]{
                gallery = e.copy()
                Firebase.shared.getEventTitle(uid,date,name)
            }
        }
        Firebase.shared.getEvent(self)
        display()
    }
    
    func display(){
        var left = CGFloat(0.0)
        var right = CGFloat(0.0)
        for subview in scroll.subviews{
            if subview.tag != -1{
                subview.removeFromSuperview()
            }
        }
        for thumbnail in gallery.sorted(by: {$0.likes > $1.likes}){
            if thumbnail.isLoaded{
                if let width = (thumbnail.image?.size.width){
                    if let height = (thumbnail.image?.size.height){
                        let aspect = width/height
                        let height = (scroll.frame.width/2)/(aspect)
                        scroll.addSubview(thumbnail)
                        
                        if left <= right{
                            thumbnail.frame = CGRect(x: 0, y: left, width: scroll.frame.width/2, height: height)
                            left = thumbnail.frame.maxY
                        }
                        else{
                            thumbnail.frame = CGRect(x: scroll.frame.width/2, y: right, width: scroll.frame.width/2, height: height)
                            right = thumbnail.frame.maxY
                        }
                        
                        thumbnail.reposition()
                    }
                }
            }
        }
        scroll.contentSize = CGSize(width: scroll.frame.width, height: [[left,right].max()! + 10, scroll.frame.height + 1].max()!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
