//
//  Thumbnail.swift
//  Been There
//
//  Created by Karl Cridland on 15/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class Thumbnail: UIImageView {
    
    let uid: String
    let date: String
    let event: String
    let host: String
    var isLoaded = false
    var likes = 0
    var liked = false
    
    var page: PageEvent?
    var widget: WidgetEvent?
    var heart: UIButton?
    
    init(uid: String, date: String, event: String, host: String) {
        self.uid = uid
        self.date = date
        self.event = event
        self.host = host
        super .init(frame: .zero)
        if image == nil{
            var i = 0
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: {timer in
                Firebase.shared.loadThumbnail(thumbnail: self, event: self.event, host: self.host)
                if (i == 10) || (self.image != nil){
                    timer.invalidate()
                }
                i += 1
                
            })
        }
        
    }
    
    func prompt(){
        if let event = widget{
            event.update()
        }
        if let p = self.page{
            p.display()
        }
    }
    
    func reposition(){
        if let s = superview{
            let fullscreen = UIButton(frame: self.frame)
            s.addSubview(fullscreen)
            fullscreen.addTarget(self, action: #selector(enlarge), for: .touchUpInside)
            heart = UIButton(frame: CGRect(x: frame.minX+5, y: frame.minY+frame.height-25, width: 20, height: 20))
            heart!.addTarget(self, action: #selector(likePhoto), for: .touchUpInside)
            s.addSubview(heart!)
            heart!.setImage(UIImage(named: "heart"), for: .normal)
            if liked{
                heart!.setImage(UIImage(named: "heart-highlight"), for: .normal)
            }
        }
    }
    
    @objc func enlarge(){
        if let img = image{
            let _ = FullScreen(image: img, tags: [], host: host, event: event, uid: uid, pic: date)
        }
    }
    
    @objc func likePhoto(sender: UIButton){
        Firebase.shared.likePhoto(self)
        liked = true
        reposition()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
