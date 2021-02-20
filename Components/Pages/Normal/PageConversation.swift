//
//  PageConversation.swift
//  Been There
//
//  Created by Karl Cridland on 28/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class PageConversation: Page, UIScrollViewDelegate {
    
    let uid: String
    var header: MessageHeader?
    var messages = [Message]()
    var offsetted = false
    let newMessage: NewMessage
    var start: CGFloat?
    var isTyping = false
    
    var loaded = false
    
    init(title: String, uid: String, header: MessageHeader?) {
        self.uid = uid
        self.header = header
        self.newMessage = NewMessage(uid: uid)
        super .init(title: title)
        
        if let header = self.header{
            messages = header.messages
            loaded = true
            update(opened: false)
        }
        
        Firebase.shared.getMessages(self)
        addSubview(newMessage)
        newMessage.scroll = scroll
        scroll.delegate = self
        newMessage.input.input.addTarget(self, action: #selector(typing), for: .allEditingEvents)
        newMessage.input.clear.addTarget(self, action: #selector(typing), for: .touchUpInside)
        newMessage.submit.addTarget(self, action: #selector(typing), for: .touchUpInside)
    }
    
    @objc func typing(){
        if newMessage.input.text().count == 0{
            Firebase.shared.stopTyping(uid: uid)
            return
        }
        Firebase.shared.startTyping(uid: uid)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let start = self.start{
            if start - scrollView.contentOffset.y > 1{
                newMessage.keyboardResigned()
                UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        else{
            if scrollView.isTracking{
                start = scrollView.contentOffset.y
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        start = nil
    }
    
    func update(){
        update(opened: true)
    }
    
    func update(opened: Bool){
        if !loaded{
            return
        }
        var h = CGFloat(0.0)
        var latest: String?
        scroll.removeAll()
        messages.removeAll(where: {$0.ghost == true})
        if let header = self.header{
            header.messages = messages
        }
        if isTyping{
            let ghost = Message(uid: uid, message: "•••", time: Date(timeIntervalSinceNow: 3600))
            ghost.ghost = true
            messages.append(ghost)
        }
        for message in messages.sorted(by: {$0.time < $1.time}){
            if message.uid == Settings.shared.get().uid{
                let m = MessageView(frame: CGRect(x: 10, y: h, width: frame.width-100, height: 80), message: message.message, me: true)
                m.backgroundColor = #colorLiteral(red: 0.5278930068, green: 0.7731922269, blue: 0.913644731, alpha: 1)
                let timestamp = message.timestamp()
                timestamp.frame = CGRect(x: scroll.frame.width + 10, y: m.frame.maxY - 30, width: 100, height: 30)
                timestamp.accessibilityFrame = timestamp.frame
                scroll.addSubview(timestamp)
                scroll.addSubview(m)
                h += m.frame.height + 5
            }
            else{
                let m = MessageView(frame: CGRect(x: 60, y: h, width: frame.width-70, height: 80), message: message.message, me: false)
                if message.ghost{
                    m.ghost()
                }
                m.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                let timestamp = message.timestamp()
                timestamp.frame = CGRect(x: scroll.frame.width + 10, y: m.frame.maxY - 30, width: 100, height: 30)
                timestamp.accessibilityFrame = timestamp.frame
                scroll.addSubview(timestamp)
                scroll.addSubview(m)
                if let l = latest{
                    if l != message.uid{
                        let pic = ProfileImage(frame: CGRect(x: 10, y: h, width: 40, height: 40), uid: message.uid)
                        let button = UIButton(frame: pic.frame)
                        button.addTarget(self, action: #selector(openLink), for: .touchUpInside)
                        scroll.addSubview(pic)
                        scroll.addSubview(button)
                        pic.accessibilityFrame = pic.frame
                    }
                }
                else{
                    let pic = ProfileImage(frame: CGRect(x: 10, y: h, width: 40, height: 40), uid: message.uid)
                    let button = UIButton(frame: pic.frame)
                    button.addTarget(self, action: #selector(openLink), for: .touchUpInside)
                    scroll.addSubview(pic)
                    scroll.addSubview(button)
                    pic.addLink()
                    pic.accessibilityFrame = pic.frame
                }
                h += m.frame.height + 5
            }
            latest = message.uid
        }
        scroll.contentSize = CGSize(width: scroll.frame.width, height: h + 50)
        if opened{
            UIView.animate(withDuration: 0.1, animations: {
                if self.scroll.contentSize.height <  self.scroll.frame.height{
                    self.scroll.contentOffset = CGPoint(x: 0, y: 0)
                }
                else{
                    self.scroll.contentOffset = CGPoint(x: 0, y: self.scroll.contentSize.height - self.scroll.frame.height)
                }
            })
        }
        else{
            if self.scroll.contentSize.height <  self.scroll.frame.height{
                self.scroll.contentOffset = CGPoint(x: 0, y: 0)
            }
            else{
                self.scroll.contentOffset = CGPoint(x: 0, y: self.scroll.contentSize.height - self.scroll.frame.height)
            }
        }
        Firebase.shared.removeMessageNotifications(uid)
    }
    
    @objc func openLink(){
        Firebase.shared.getPage(uid)
    }
    
    @objc override func moving(_ gesture: UIPanGestureRecognizer){
        
        // Overrides what happens when the page is moved, main difference is when swiped to the left the messages will move
        // and display the time.
        
        let translation = gesture.translation(in: self)
        let frame = gesture.view!
        let buf = Settings.shared.upper_bound+40
        
        
        if (frame.frame.minX + translation.x >= 0) && (!offsetted){
            if (frame.frame.minX + translation.x >= 5) && (!offsetted){
                newMessage.keyboardResigned()
                UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            var percentage = (100-(frame.frame.minX*frame.frame.width/800))/100
            if percentage < 0{
                percentage = 0
            }
            self.background.backgroundColor = self.background.backgroundColor?.withAlphaComponent(0.8*percentage)
            frame.center = CGPoint(x: frame.center.x + translation.x, y: frame.center.y)
            UIView.animate(withDuration: 0.1, animations: {
                gesture.setTranslation(CGPoint.zero, in: self)
            })
        }
        else{
            offsetted = true
            for subview in scroll.subviews{
                if (subview.frame.minX + translation.x > -40 && subview.frame.minX <= subview.accessibilityFrame.minX){

                    subview.center = CGPoint(x: subview.center.x + translation.x, y: subview.center.y)
                    gesture.setTranslation(CGPoint.zero, in: self)
                    if subview.frame.maxX < subview.accessibilityFrame.maxX-90{
                        subview.frame = CGRect(x: subview.accessibilityFrame.minX-90, y: subview.frame.minY, width: subview.frame.width, height: subview.frame.height)
                    }
                    if subview.frame.maxX > subview.accessibilityFrame.maxX{
                        subview.frame = CGRect(x: subview.accessibilityFrame.minX, y: subview.frame.minY, width: subview.frame.width, height: subview.frame.height)
                    }
                }
            }
        }
        
        // When a user stops touching the screen.
        
        if (gesture.state == .ended){
            offsetted = false
            
            // Checks if the page is slid far enough over to be removed.
            
            if (frame.frame.minX > frame.frame.width/4){
                
                // Remove page.
                
                self.background.removeFromSuperview()
                if let home = Settings.shared.home{
                    home.container?.remove()
                }
            }
            else{
                
                // Will reset page to initial position.
                
                cancelDisappear()
                
                UIView.animate(withDuration: 0.1, animations: {
                    
                    // Deals with the page itself.
                    
                    self.frame = CGRect(x: 0, y: buf, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-buf)
                    self.background.backgroundColor = self.background.backgroundColor?.withAlphaComponent(0.4)
                    
                    // Deals with the items on the page. Resets all the items on the screen to their original positions - bug found where the accessibility
                    // frame changes for the message views ???.
                    
                    for subview in self.scroll.subviews{
                        if let message = subview as? MessageView{
                            if message.me{
                                message.frame = CGRect(x: UIScreen.main.bounds.width-message.frame.width-10, y: message.frame.minY, width: message.frame.width, height: message.frame.height)
                            }
                            else{
                                message.frame = CGRect(x: 60, y: message.frame.minY, width: message.frame.width, height: message.frame.height)
                            }
                        }
                        else{
                            subview.frame = subview.accessibilityFrame
                        }
                    }
                })
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
