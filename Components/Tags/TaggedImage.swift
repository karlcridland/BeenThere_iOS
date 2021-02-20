//
//  TaggedImage.swift
//  Been There
//
//  Created by Karl Cridland on 16/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class TaggedImage: UIImageView {
    
    let uid, host, event, picture: String
    let page: PagePersonal?
    let taggedPage: PageSortTagged?
    let tags = [Tagger]()
    
    var hasLoaded = false
    
    init(uid: String, host: String, event: String, picture: String, page: PagePersonal) {
        self.uid = uid
        self.host = host
        self.event = event
        self.picture = picture
        self.page = page
        self.taggedPage = nil
        super .init(frame: .zero)
        
        Firebase.shared.getTaggedImage(self)
    }
    
    init(uid: String, host: String, event: String, picture: String, page: PageSortTagged) {
        self.uid = uid
        self.host = host
        self.event = event
        self.picture = picture
        self.page = nil
        self.taggedPage = page
        super .init(frame: .zero)
        
        Firebase.shared.getTaggedImage(self)
    }
    
    func prompt(){
        if let p = page{
            p.sortPictures()
        }
        if let t = taggedPage{
            t.sortPictures()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
