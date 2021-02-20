//
//  PageBusiness.swift
//  Been There
//
//  Created by Karl Cridland on 14/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageBusiness: PageProfile {
    
    let takealook: FeedContainerExpandable
    let container: FeedContainerExpandable
    
    private var isExpanded = false
    private var cooldown = false
    private var first = true
    
    let height = (UIScreen.main.bounds.height-Settings.shared.upper_bound-40)/2 - 25
    
    init(uid: String, title: String, address: String) {
        self.container = FeedContainerExpandable(type: .business)
        self.takealook = FeedContainerExpandable(type: .takelook)
        super .init(uid: uid, title: title, name: address)
        addSubview(takealook)
        addSubview(container)
        scroll.removeFromSuperview()
        
        Firebase.shared.getEvents(self)
        
        self.takealook.cover.addTarget(self, action: #selector(expand), for: .touchUpInside)
        self.container.cover.addTarget(self, action: #selector(expand), for: .touchUpInside)
        
        expand()
        
        takealook.events.append(Event(takeALook: uid))
        takealook.update()
        container.update()
        
        if let talscroll = takealook.scroll as? TALScrollView{
            talscroll.uid = uid
        }
        if Settings.shared.get().uid == uid{
            let upload = UIButton(frame: CGRect(x: frame.width-50, y: height - 50, width: 35, height: 35))
            takealook.addSubview(upload)
            upload.setImage(UIImage(named: "camera"), for: .normal)
            upload.addTarget(self, action: #selector(updateTarget), for: .touchUpInside)
        }
    }
    
    @objc func updateTarget(){
        if let page = Settings.shared.home?.container?.pages.last(where: {($0 is PageBusiness) && ($0 as! PageBusiness).uid == Settings.shared.get().uid}) as? PageBusiness{
            page.target = takealook
            let pageUpload = PageUpload(page: page)
            Settings.shared.home?.container?.append(pageUpload)
        }
    }
    
    @objc func expand(){
        if cooldown || (container.events.count == 0 && !first){
            return
        }
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            if self.container.events.count == 0{
                self.container.cover.setTitle("no posts yet", for: .normal)
                self.container.cover.titleLabel?.font = Settings.shared.font
            }
        })
        
        isExpanded = !isExpanded
        
        let small = frame.height - height - 150
        
        if isExpanded{
            takealook.expand(height: height, y: 150, bigger: true)
            container.expand(height: small, y: 150 + height, bigger: false)
        }
        else{
            takealook.expand(height: small, y: 150, bigger: false)
            container.expand(height: height, y: 150 + small, bigger: true)
        }
        cooldown = true
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
            self.cooldown = false
        })
        
        first = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
