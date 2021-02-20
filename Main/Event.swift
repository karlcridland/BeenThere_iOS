//
//  Event.swift
//  Kaktus
//
//  Created by Karl Cridland on 12/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class Event {
    
    let name: String
    let date: Date
    let uid: String
    var magnified = false
    var gallery = [Thumbnail]()
    var likes = 0
    
    var tal = false
    
    init(name: String, date: Date, uid: String) {
        self.name = name
        self.date = date
        self.uid = uid
    }
    
    init(takeALook: String) {
        self.uid = takeALook
        self.date = Date()
        self.name = ""
        tal = true
    }
    
    func copy() -> [Thumbnail]{
        var temp = [Thumbnail]()
        for t in gallery{
            let new = Thumbnail(uid: t.uid, date: t.date, event: t.event, host: t.host)
            new.image = t.image
            new.isLoaded = true
            new.liked = t.liked
            temp.append(new)
        }
        return temp
    }
    
    static func ==(left: Event, right: Event) -> Bool {
        return ((left.uid == right.uid) && (left.date == right.date))
    }
    
    static func !=(left: Event, right: Event) -> Bool {
        return !(left == right)
    }
    
    static func >(left: Event, right: Event) -> Bool {
        return (left.date > right.date)
    }
    
    static func <(left: Event, right: Event) -> Bool {
        return (left.date < right.date)
    }
    
    static func >=(left: Event, right: Event) -> Bool {
        return !(left < right)
    }
    
    static func <=(left: Event, right: Event) -> Bool {
        return !(left > right)
    }
    
}
