//
//  WidgetUpcoming.swift
//  Been There
//
//  Created by Karl Cridland on 14/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class WidgetUpcoming: WidgetEvent {
    
    let poster = UIImageView()
    var hasLoaded = false
    
    override init(event: Event) {
        super .init(event: event)
    }
    
    override func load() {
        super.load()
        if hasLoaded{
            poster.frame = CGRect(x: 0, y: 0, width: scroll.frame.width, height: scroll.frame.height)
            poster.contentMode = .scaleAspectFill
            scroll.addSubview(poster)
            let button = UIButton(frame: poster.frame)
            button.addTarget(self, action: #selector(enlarge), for: .touchUpInside)
            button.tag = -1
            scroll.addSubview(button)
        }
        else{
            Firebase.shared.getUpcoming(self)
        }
        camera.alpha = 0.4
        tagged.alpha = 0.4
        
        caption.frame = CGRect(x: 5, y: 40, width: UIScreen.main.bounds.width-15, height: 50)
    }
    
    @objc func enlarge(){
        if let img = poster.image{
            let _ = FullScreen(image: img, tags: [], host: event.uid, event: event.date.datetime(), uid: nil, pic: nil)
        }
    }
    
    override func upload() {}
    
    override func seeTagged(){}
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
