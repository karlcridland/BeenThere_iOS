//
//  PageTaggedList.swift
//  Been There
//
//  Created by Karl Cridland on 16/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageTaggedList: PageProfileList{
    
    let event: WidgetEvent
    
    init(event: WidgetEvent) {
        self.event = event
        super .init(title: "tagged")
        Firebase.shared.getTagged(self)
        
    }
    
    override func display() {
        super.display()
        if results.count < full{
            Firebase.shared.getTagged(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
