//
//  SButton.swift
//  waitt
//
//  Created by Karl Cridland on 25/05/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class SButton: UIButton {
    
    var source: Any
    private var backdrop: UIButton?
    
    init(frame: CGRect, source: Any) {
        self.source = source
        super .init(frame: frame)
        addTarget(self, action: #selector(clicked), for: .touchUpInside)
    }
    
    @objc func clicked(){
        if let _ = Settings.shared.sb{
        }
        else{
            backdrop = UIButton(frame: UIScreen.main.bounds)
            backdrop!.addTarget(self, action: #selector(remove), for: .touchUpInside)
            Settings.shared.sb = self
            Settings.shared.home?.view.addSubview(backdrop!)
            var buttons = [UIButton]()
            let cancel = UIButton()
            cancel.setTitle("Cancel", for: .normal)
            
            let profile = UIButton()
            profile.setTitle("View Profile", for: .normal)
            profile.setTitleColor(.black, for: .normal)
            profile.addTarget(self, action: #selector(viewProfile), for: .touchUpInside)
            
            let follow = UIButton()
            follow.setTitle("Follow", for: .normal)
            follow.setTitleColor(.black, for: .normal)
            follow.addTarget(self, action: #selector(followProfile), for: .touchUpInside)
            
            let unfollow = UIButton()
            unfollow.setTitle("Unfollow", for: .normal)
            unfollow.setTitleColor(.black, for: .normal)
            unfollow.addTarget(self, action: #selector(unfollowProfile), for: .touchUpInside)
            
            let info = UIButton()
            info.setTitle("More Information", for: .normal)
            info.setTitleColor(.black, for: .normal)
            info.addTarget(self, action: #selector(moreInfo), for: .touchUpInside)
            
            let photo = UIButton()
            photo.setTitle("Add Photo", for: .normal)
            photo.setTitleColor(.black, for: .normal)
            photo.addTarget(self, action: #selector(addPhoto), for: .touchUpInside)
            
            let dphoto = UIButton()
            dphoto.setTitle("Delete Photo", for: .normal)
            dphoto.setTitleColor(.black, for: .normal)
            dphoto.addTarget(self, action: #selector(deletePhoto), for: .touchUpInside)
            
            let report = UIButton()
            report.setTitle("Report", for: .normal)
            report.setTitleColor(.black, for: .normal)
            report.addTarget(self, action: #selector(reportProfile), for: .touchUpInside)
            
            let block = UIButton()
            block.setTitle("Block", for: .normal)
            block.setTitleColor(.black, for: .normal)
            block.addTarget(self, action: #selector(blockProfile), for: .touchUpInside)
            
            let unblock = UIButton()
            unblock.setTitle("Unblock", for: .normal)
            unblock.setTitleColor(.black, for: .normal)
            unblock.addTarget(self, action: #selector(unblockProfile), for: .touchUpInside)
            
            let editP = UIButton()
            editP.setTitle("Edit Profile", for: .normal)
            editP.setTitleColor(.black, for: .normal)
            editP.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
            
            let editT = UIButton()
            editT.setTitle("Edit Event", for: .normal)
            editT.setTitleColor(.black, for: .normal)
            editT.addTarget(self, action: #selector(editText), for: .touchUpInside)
            
            let deleteE = UIButton()
            deleteE.setTitle("Delete Event", for: .normal)
            deleteE.setTitleColor(.black, for: .normal)
            deleteE.addTarget(self, action: #selector(deleteEvent), for: .touchUpInside)
            
            var uid: String?
            switch source {
            case is WidgetEvent:
                uid = (source as! WidgetEvent).event.uid
                
                if let c = Settings.shared.home?.container?.topPage(){
                    if c != uid!{
                        buttons.append(profile)
                    }
                }
                else{
                    buttons.append(profile)
                }
                
                buttons.append(editT)
                
                if !(source is WidgetUpcoming){
                    photo.accessibilityHint = (source as! WidgetEvent).event.date.datetime()
                    buttons.append(photo)
                }
                        
                buttons.append(report)
                
                if !Settings.shared.blocked.contains(uid!){
                    buttons.append(block)
                }
                else{
                    buttons.append(unblock)
                }
                
                buttons.append(deleteE)
                deleteE.accessibilityHint = (source as! WidgetEvent).event.date.datetime()
                
            case is PagePersonal:
                uid = (source as! PageProfile).uid
                if !Settings.shared.friends.contains(uid!){
                    buttons.append(follow)
                }
                else{
                    buttons.append(unfollow)
                }
                
                buttons.append(report)
                
                if !Settings.shared.blocked.contains(uid!){
                    buttons.append(block)
                }
                else{
                    buttons.append(unblock)
                }
                
                buttons.append(editP)
                
            case is PageBusiness:
                uid = (source as! PageBusiness).uid

                if !Settings.shared.friends.contains(uid!){
                    buttons.append(follow)
                }
                else{
                    buttons.append(unfollow)
                }
                
                buttons.append(report)
                
                if !Settings.shared.blocked.contains(uid!){
                    buttons.append(block)
                }
                else{
                    buttons.append(unblock)
                }
                
                buttons.append(editP)
                
//            case is PageEvent:
//
//                uid = (source as! PageEvent).uid
//                buttons.append(profile)
//
//                if !(source is WidgetUpcoming){
//                    photo.accessibilityHint = (source as! PageEvent).source!.event()
//                    buttons.append(photo)
//                }
//
//                buttons.append(report)
//                buttons.append(block)
                
//            case is Gallery:
//                uid = (source as! Gallery).items[(source as! Gallery).current().tag].author
//
//                buttons.append(profile)
//
//                if !UserInfo.shared.friends.contains(uid!){
//                    buttons.append(follow)
//                }
//                else{
//                    buttons.append(unfollow)
//                }
//
//                buttons.append(dphoto)
//
//                buttons.append(report)
                
            default:
                break
            }
            
            if let id = uid{
                var temp = [UIButton]()
                for b in buttons{
                    b.accessibilityLabel = uid!
                    if id == Settings.shared.get().uid{
                        if !((b == block) || (b == report) || (b == follow)){
                            temp.append(b)
                        }
                    }
                    else{
                        if !((b == editT) || (b == editP) || (b == dphoto) || (b == deleteE)){
                            temp.append(b)
                        }
                    }
                }
                buttons = temp
            }
            
            buttons.append(cancel)
            cancel.setTitleColor(.red, for: .normal)
            cancel.addTarget(self, action: #selector(remove), for: .touchUpInside)
            let view = UIView(frame: CGRect(x: 0, y: backdrop!.frame.height, width: backdrop!.frame.width, height: CGFloat(buttons.count)*(55)+100))
            backdrop?.addSubview(view)
            self.backdrop!.backgroundColor = .clear
            UIView.animate(withDuration: 0.2, animations: {
                view.transform = CGAffineTransform(translationX: 0, y: -(CGFloat(buttons.count)*(55)+Settings.shared.lower_bound))
                if let _ = Settings.shared.fullscreen{
                    self.backdrop!.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0)
                }
                else{
                    self.backdrop!.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.4)
                }
            })
            var i = 0
            for button in buttons{
                button.frame = CGRect(x: 5, y: CGFloat(i)*55 + 5, width: backdrop!.frame.width-10, height: 50)
                button.backgroundColor = .white
                button.layer.cornerRadius = 5
                button.titleLabel?.font = UIFont(name: "BanglaSangamMN-Bold", size: 14)
                view.addSubview(button)
                i += 1
            }
        }
    }
    
    @objc func remove(){
        Settings.shared.sb = nil
        UIView.animate(withDuration: 0.2, animations: {
            for subview in self.backdrop!.subviews{
                subview.transform = CGAffineTransform.identity
                self.backdrop!.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1).withAlphaComponent(0)
            }
        })
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { _ in
            self.backdrop?.removeFromSuperview()
        })
    }
    
    @objc func exit(){
        Settings.shared.home?.container?.banner?.leftClicked()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func exitGal(){
//        if let g = Settings.shared.gallery{
//            g.remove()
//        }
    }
    
    @objc func viewProfile(sender: UIButton){
        let uid = sender.accessibilityLabel!
        Firebase.shared.getPage(uid)
        remove()
        exitGal()
    }
    
    @objc func followProfile(sender: UIButton){
        let uid = sender.accessibilityLabel!
        Firebase.shared.follow(uid)
        remove()
    }
    
    @objc func unfollowProfile(sender: UIButton){
        let uid = sender.accessibilityLabel!
        Firebase.shared.unfollow(uid)
        remove()
    }
    
    @objc func moreInfo(sender: UIButton){
//        let uid = sender.accessibilityLabel!
        remove()
    }
    
    @objc func addPhoto(sender: UIButton){
        if source is WidgetEvent{
            let src = source as! WidgetEvent
            src.upload()
            remove()
        }
    }
    
    @objc func deletePhoto(sender: UIButton){
//        var events = [WidgetEvent]()
//        if let gal = source as? Gallery{
//            let item = gal.items[gal.current().tag]
//            let formatter = DateFormatter()
//            formatter.dateFormat = "dd:MM:yy hh:mm:ss"
//            let time =  formatter.string(from: item.time)
//            Firebase.shared.deletePhoto(gal.id,time)
//            exitGal()
//            if let event = UserInfo.shared.events.first(where: {$0.id == gal.id}){
//                events.append(event)
//                event.items.removeAll(where: {$0.time == time.datetime()})
//                event.update()
//                Firebase.shared.refreshEvent(event)
//            }
//            if let w = gal.items[gal.current().tag].widget as? WidgetEvent{
//                events.append(w)
//                w.items.removeAll(where: {$0.time == time.datetime()})
//                Firebase.shared.refreshEvent(w)
//                w.update()
//                if let page = w.superview as? PageProfile{
//                    page.update()
//                }
//                if let home = w.superview as? Home{
//                    home.update()
//                }
//            }
//        }
//        for event in events{
//            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
//                Firebase.shared.refreshEvent(event)
//            })
//        }
//        remove()
    }
    
    @objc func blockProfile(sender: UIButton){
        let uid = sender.accessibilityLabel!
        Firebase.shared.block(uid)
        remove()
        exitPage()
    }
    
    @objc func unblockProfile(sender: UIButton){
        let uid = sender.accessibilityLabel!
        Firebase.shared.unblock(uid)
        remove()
    }
    
    @objc func editProfile(sender: UIButton){
        (source as! PageProfile).edit()
        remove()
        if let banner = Settings.shared.home?.container?.banner{
            banner.submit.isHidden = false
            banner.sb.isHidden = true
        }
    }
    
    @objc func editText(sender: UIButton){
        remove()
        if let event = source as? WidgetEvent{
            let page = PageEditPost(event)
            Settings.shared.home?.container?.append(page)
        }
    }
    
    @objc func reportProfile(sender: UIButton){
        let uid = sender.accessibilityLabel!
        Firebase.shared.report(uid)
        remove()
        exitPage()
        if let event = source as? WidgetEvent{
            let _ = Report(uid: uid, event: event.event.date.datetime(), host: event.event.uid)
            return
        }
        let _ = Report(uid: uid, event: nil, host: nil)
    }
    
    @objc func deleteEvent(sender: UIButton){
        if let e = source as? WidgetEvent{
            let _ = ConfirmAction(title: "delete this event", with: {
                Firebase.shared.deleteEvent(e)
            })
        }
        remove()
    }
    
    func exitPage(){
        if (Settings.shared.home?.container?.pages.count)! > 0{
            Settings.shared.home?.container?.banner?.leftClicked()
        }
    }
}

