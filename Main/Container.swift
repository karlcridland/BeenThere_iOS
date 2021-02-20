//
//  Container.swift
//  Kaktus
//
//  Created by Karl Cridland on 12/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class Container: UIView{
    
    var banner: Banner?
    let feed: MainFeed
    
    var pages = [Page]()
    let scroll: UIScrollView
    
    let messenger = Messenger()
    let hot = WhatsHot()
    
    var focus: UIView?

    let fp = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    let wp = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    let mp = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    
    var tempM: UIButton?
    
    let a = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 7))
    
    init() {
        self.feed = MainFeed()
        self.scroll = UIScrollView(frame: CGRect(x: 0, y: Settings.shared.upper_bound+90, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-(Settings.shared.upper_bound+90)))
        super .init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        banner = Banner(self)
        addSubview(scroll)
        addSubview(banner!)
        scroll.addSubview(feed)
        scroll.addSubview(hot)
        scroll.addSubview(messenger)
        
        banner!.update()
        
        scroll.contentSize = CGSize(width: UIScreen.main.bounds.width*2, height: UIScreen.main.bounds.height-(Settings.shared.upper_bound+90))
        scroll.isScrollEnabled = false
        
        let f = UIButton(frame: CGRect(x: 0, y: Settings.shared.upper_bound+40, width: UIScreen.main.bounds.width/3, height: 50))
        fp.image = UIImage(named: "logo-clear")
        fp.center = CGPoint(x: f.center.x, y: f.center.y)
        fp.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        addSubview(fp)
        
        let w = UIButton(frame: CGRect(x: UIScreen.main.bounds.width/3, y: Settings.shared.upper_bound+40, width: UIScreen.main.bounds.width/3, height: 50))
        wp.image = UIImage(named: "flame")
        wp.center = w.center
        addSubview(wp)
        
        let m = UIButton(frame: CGRect(x: 2*UIScreen.main.bounds.width/3, y: Settings.shared.upper_bound+40, width: UIScreen.main.bounds.width/3, height: 50))
        mp.image = UIImage(named: "comment2")
        mp.center = m.center
        addSubview(mp)
        
        tempM = m
        
        var i = 0
        for a in [f,w,m]{
            a.addTarget(self, action: #selector(moveFocus), for: .touchUpInside)
            addSubview(a)
            a.tag = i
            i += 1
        }
        focus = feed
        feed.active = true
        
        feed.tag = 0
        hot.tag = 1
        messenger.tag = 2
        
        a.layer.cornerRadius = 3.5
        a.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        a.center = CGPoint(x: mp.center.x+14, y: mp.center.y-10)
        a.isHidden = true
        addSubview(a)
        
    }
    
    func openMessages(){
        if let m = tempM{
            moveFocus(sender: m)
        }
    }
    
    func currentTitle() -> String{
        if let focus = self.focus{
            switch focus.tag {
            case 1:
                return "what's hot?"
            case 2:
                return "messages"
            default:
                return "Been-There"
            }
        }
        return "Been-There"
    }
    
    @objc func moveFocus(sender: UIButton){
        
        func final(f: UIView){
            if let focus = self.focus{
                if focus.tag > sender.tag{
                    setFocus(f, .left)
                }
                if focus.tag < sender.tag{
                    setFocus(f, .right)
                }
            }
        }
        
        switch sender.tag{
        case 0:
            fp.image = UIImage(named: "logo-clear")
            wp.image = UIImage(named: "flame")
            mp.image = UIImage(named: "comment2")
            final(f: feed)
            feed.active = true
            break
        case 1:
            fp.image = UIImage(named: "logo-white")
            wp.image = UIImage(named: "flame-lit")
            mp.image = UIImage(named: "comment2")
            final(f: hot)
            hot.active = true
            break
        case 2:
            fp.image = UIImage(named: "logo-white")
            wp.image = UIImage(named: "flame")
            mp.image = UIImage(named: "comment2-lit")
            final(f: messenger)
            messenger.active = true
            break
        default:
            break
        }
    }
    
    func setFocus(_ newFocus: UIView, _ direction: Direction){
        
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
        
        for a in [feed,messenger,hot]{
            a.frame = CGRect(x: 2*UIScreen.main.bounds.width, y: 0, width: a.frame.width, height: a.frame.height)
        }
        
        if let focus = self.focus{
            switch direction {
            case .left:
                focus.frame = CGRect(x: UIScreen.main.bounds.width, y: 0, width: focus.frame.height, height: focus.frame.height)
                scroll.contentOffset = CGPoint(x: UIScreen.main.bounds.width, y: 0)
                newFocus.frame = CGRect(x: 0, y: 0, width: newFocus.frame.width, height: newFocus.frame.height)
                UIView.animate(withDuration: 0.2, animations: {
                    self.scroll.contentOffset = CGPoint(x: 0, y: 0)
                })
                break
            case .right:
                focus.frame = CGRect(x: 0, y: 0, width: focus.frame.height, height: focus.frame.height)
                scroll.contentOffset = CGPoint(x: 0, y: 0)
                newFocus.frame = CGRect(x: UIScreen.main.bounds.width, y: 0, width: newFocus.frame.width, height: newFocus.frame.height)
                UIView.animate(withDuration: 0.2, animations: {
                    self.scroll.contentOffset = CGPoint(x: UIScreen.main.bounds.width, y: 0)
                })
                break
            case .none:
                newFocus.frame = CGRect(x: 0, y: 0, width: newFocus.frame.width, height: newFocus.frame.height)
                scroll.contentOffset = CGPoint(x: 0, y: 0)
                break
            }
            
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { _ in
                self.banner?.title.text = self.currentTitle()
            })
        }
        
        focus = newFocus
        
    }
    
    func append(_ page: Page){
        pages.append(page)
        addSubview(page)
        banner!.update()
        if let fullscreen = Settings.shared.fullscreen{
            fullscreen.exit()
        }
        if let view = Settings.shared.home?.view{
            for subview in view.subviews{
                if !(subview is Container){
                    subview.removeFromSuperview()
                }
            }
        }
    }
    
    func remove(){
        if pages.count > 0{
            pages.last!.disappear()
            pages.removeLast()
        }
        banner!.update()
    }
    
    func refresh(){
        banner?.update()
    }
    
    func removeAllPages() {
        while pages.count > 0{
            remove()
        }
    }
    
    func topPage() -> String?{
        if let page = pages.last as? PageProfile{
            return page.uid
        }
        return nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


enum Direction{
    case left
    case right
    case none
}
