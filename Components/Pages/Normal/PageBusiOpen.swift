//
//  PageBusiOpen.swift
//  Been There
//
//  Created by Karl Cridland on 20/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageBusiOpen: Page {
    
    var hours = [String]()
    let uid: String
    
    init(uid: String) {
        self.uid = uid
        super .init(title: "opening hours")
        Firebase.shared.getBusinessOpenings(self)
    }
    
    func display(){
        var i = 0
        for day in ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]{
            let label = UILabel(frame: CGRect(x: 10, y: 20+CGFloat(i)*30, width: 100, height: 30))
            label.text = "\(day):"
            
            let open = UILabel(frame: CGRect(x: 120, y: 20+CGFloat(i)*30, width: (frame.width-120)/2, height: 30))
            open.textAlignment = .center
            open.text = hours[i]
            i += 1
            
            let close = UILabel(frame: CGRect(x: (frame.width)/2+60, y: 20+CGFloat(i-1)*30, width: (frame.width-120)/2, height: 30))
            close.textAlignment = .center
            close.text = hours[i]
            i += 1
            
            for text in [label,open,close]{
                text.font = Settings.shared.font
                scroll.addSubview(text)
            }
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
