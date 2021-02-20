//
//  PageNotification.swift
//  Been There
//
//  Created by Karl Cridland on 13/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageNotification: PageReverse, UIScrollViewDelegate {
    
    init(){
        super .init(title: "notifications")
        orderNotifications()
        place()
        scroll.frame = CGRect(x: 0, y: 0, width: scroll.frame.width, height: scroll.frame.height)
    }
    
    func orderNotifications(){
        Settings.shared.notifications.sort(by: {$0.time.datetime()! > $1.time.datetime()!})
    }
    
    func place(){
        orderNotifications()
        scroll.removeAll()
        var i = 0
        for n in Settings.shared.notifications{
            if let view = n.display(){
                view.frame = CGRect(x: 10, y: CGFloat(i)*100, width: view.frame.width, height: 90)
                scroll.addSubview(view)
                i += 1
            }
            else{
                Firebase.shared.storeProfile(n.uid, with: {
                    Firebase.shared.deleteNotification(uid: n.uid, time: n.time)
                }, completion: {})
            }
        }
        scroll.contentSize = CGSize(width: UIScreen.main.bounds.width, height: CGFloat(i)*100)
    }
    
    override func disappear() {
        super.disappear()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.tag = 1
        for subview in scroll.subviews{
            if subview.tag == -1{
                if let s = subview as? UIScrollView{
                    s.contentOffset = CGPoint(x: 100, y: 0)
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class UserNotif {
    
    let uid: String
    let time: String
    let type: notificationType
    let host: String?
    let event: String?
    var read = false
    
    init(uid: String, time: String, type: notificationType, host: String?, event: String?) {
        self.uid = uid
        self.time = time
        self.type = type
        self.host = host
        self.event = event
        
    }
    
    func display() -> UIView?{
        if let profile = Settings.shared.getProfile(uid){
            let width = UIScreen.main.bounds.width - 20
            let view = UIView(frame: CGRect(x: 10, y: 0, width: width, height: 90))
            view.layer.cornerRadius = 10
            view.tag = -1
            
            let title = UILabel(frame: CGRect(x: 85, y: 5, width: width-205, height: 20))
            title.text = profile.name
            view.addSubview(title)
            title.font = Settings.shared.font
            title.increase(-2.0)
            title.textColor = .white
            
            let context = UITextView(frame: CGRect(x: 80, y: 20, width: width-90, height: 70))
            view.addSubview(context)
            context.font = UIFont(name: Settings.shared.fontName, size: 12)
            context.textColor = .white
            context.backgroundColor = .clear
            
            let timestamp = UILabel(frame: CGRect(x: width-130, y: 5, width: 120, height: 20))
            view.addSubview(timestamp)
            timestamp.font = Settings.shared.font
            timestamp.textColor = .white
            timestamp.textAlignment = .right
            timestamp.increase(-2.0)
            timestamp.text = time.datetime()!.dmy()
            
            let pic = ProfileImage(frame: CGRect(x: 10, y: 10, width: 60, height: 60), uid: uid)
            view.addSubview(pic)
            
            switch type{
            case .follow:
                if let username = profile.username{
                    context.text = "@\(username) is now following you."
                }
                else{
                    context.text = "\(profile.name) is now following you."
                }
            case .tag:
                if let username = Settings.shared.getProfile(uid)?.username{
                    if let profile = Settings.shared.getProfile(host!){
                        context.text = "@\(username) has tagged you in a photo in \(profile.name)'s event."
                    }
                }
                else{
                    if let profile = Settings.shared.getProfile(host!){
                        context.text = "@\(profile.name) has tagged you in a photo in \(profile.name)'s event."
                    }
                }
                
            case .comment:
                if let username = profile.username{
                    context.text = "@\(username) commented on your post."
                }
                else{
                    context.text = "\(profile.name) commented on your post."
                }
                break
            case .like:
                if let username = profile.username{
                    context.text = "@\(username) liked your post."
                }
                else{
                    context.text = "\(profile.name) liked your post."
                }
                break
                
            default:
                break
            }
            
            if !read{
                view.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            }
            let button = UIButton(frame: view.frame)
            view.addSubview(button)
            button.addTarget(self, action: #selector(click), for: .touchUpInside)
            
            return view
        }
        return nil
    }
    
    @objc func click(sender: UIButton){
        read = true
        sender.superview?.backgroundColor = .clear
        Firebase.shared.denotify(uid: uid, host: host, time: time, event: event, type: type)
        switch type {
        case .follow:
            Settings.shared.home?.container?.removeAllPages()
            Firebase.shared.getPage(uid)
            break
        case .like:
            if let e = event{
                if let h = host{
                    Settings.shared.home?.container?.append(PageEvent(date: e, uid: h, event: nil))
                    break
                }
                Settings.shared.home?.container?.append(PageEvent(date: e, uid: Settings.shared.get().uid, event: nil))
                break
            }
        case .tag:
            Settings.shared.home?.container?.append(PageSortTagged())
            break
        case .comment:
            Settings.shared.home?.container?.append(PageEvent(date: time, uid: Settings.shared.get().uid, event: nil))
            break
        default:
            break
        }
    }
    
    @objc func delete(sender: UIButton){
        if let userNotif = sender.accessibilityElements![0] as? UserNotif{
            Firebase.shared.deleteNotification(uid: userNotif.uid, time: userNotif.time)
            Settings.shared.notifications.removeAll(where: {$0.uid == userNotif.uid && $0.time == userNotif.time})
            if let view = sender.superview{
                for subview in view.superview!.subviews{
                    if subview.center.y > view.center.y{
                        subview.center = CGPoint(x: subview.center.x, y: subview.center.y-100)
                    }
                }
                view.removeFromSuperview()
            }
        }
        
    }
    
}
