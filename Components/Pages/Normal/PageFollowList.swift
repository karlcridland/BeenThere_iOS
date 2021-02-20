//
//  PageFollowList.swift
//  Been There
//
//  Created by Karl Cridland on 18/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageFollowList: PageProfileList, UIScrollViewDelegate {
    
    let uid: String
    var results2 = [Profile]()
    var full2 = 0
    let dir: dir
    var hasLoaded = false
    let scroll1 = UIScrollView(), scroll2 = UIScrollView()
    
    var removed = false
    
    init(uid: String, dir: dir) {
        self.uid = uid
        self.dir = dir
        super .init(title: Settings.shared.getProfile(uid)!.name)
        Firebase.shared.getFollowPage(self)
        scroll.isPagingEnabled = true
        scroll.delegate = self
        scroll1.frame = CGRect(x: 0, y: 0, width: scroll.frame.width, height: scroll.frame.height)
        scroll2.frame = CGRect(x: scroll.frame.width, y: 0, width: scroll.frame.width, height: scroll.frame.height)
        scroll.addSubview(scroll1)
        scroll.addSubview(scroll2)
        scroll.showsVerticalScrollIndicator = false
    }
    
    override func display() {
        
        if !hasLoaded{
            scroll.contentSize = CGSize(width: UIScreen.main.bounds.width*2, height: 0)
            if dir == .right{
                scroll.contentOffset = CGPoint(x: UIScreen.main.bounds.width, y: 0)
            }
        }
        
        var h = CGFloat(0.0)
        scroll1.removeAll()
        for result in results{
            let view = result.display()
            view.frame = CGRect(x: 0, y: h, width: view.frame.width, height: view.frame.height)
            scroll1.addSubview(view)
            h += view.frame.height
        }
        scroll1.contentSize = CGSize(width: UIScreen.main.bounds.width, height: h)
        
        scroll2.removeAll()
        var g = CGFloat(0.0)
        for result in results2{
            let view = result.display()
            view.frame = CGRect(x: 0, y: g, width: view.frame.width, height: view.frame.height)
            scroll2.addSubview(view)
            g += view.frame.height
        }
        scroll2.contentSize = CGSize(width: UIScreen.main.bounds.width, height: g)
        
        hasLoaded = true
        
        if results.count != full || results2.count != full2{
            Firebase.shared.getFollowPage(self)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !removed{
            if scroll.contentOffset.x > UIScreen.main.bounds.width/2{
                Settings.shared.home?.container?.banner?.title.text = "following"
            }
            else{
                Settings.shared.home?.container?.banner?.title.text = "followers"
            }
            if scroll.contentOffset.x <= 0{
                if scroll.frame.minX < UIScreen.main.bounds.width/4{
                    center = CGPoint(x: UIScreen.main.bounds.width/2 - scroll.contentOffset.x*2, y: center.y)
                    scroll1.center = CGPoint(x: UIScreen.main.bounds.width/2 + scroll.contentOffset.x, y: scroll1.center.y)
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if center.x > UIScreen.main.bounds.width/2 + 50{
            Settings.shared.home?.container?.remove()
            removed = true
        }
        else{
            let buf = Settings.shared.upper_bound+40
            frame = CGRect(x: 0, y: buf, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-buf)
            scroll1.center = CGPoint(x: UIScreen.main.bounds.width/2, y: scroll1.center.y)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if removed{
            Settings.shared.home?.container?.refresh()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum dir{
    case left
    case right
}
