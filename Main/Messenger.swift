//
//  Messenger.swift
//  Been There
//
//  Created by Karl Cridland on 27/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class Messenger: HomePage {
    
    var messages = [MessageHeader]()
    
    let search = SearchBar(frame: CGRect(x: 10, y: 10, width: UIScreen.main.bounds.width-20, height: 30), placeholder: "search", type: .search)
    let scroll: UIScrollView
    
    init() {
        let buf = Settings.shared.upper_bound+90
        self.scroll = UIScrollView(frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-buf-50))
        super .init(frame: CGRect(x: UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-buf))
        addSubview(search)
        addSubview(scroll)
        
        Firebase.shared.getMessages(self)
        
        search.input.addTarget(self, action: #selector(refine), for: .allEditingEvents)
        search.clear.addTarget(self, action: #selector(refine), for: .touchUpInside)
    }
    
    @objc func refine(sender: UITextField){
        update(sender.text!)
    }
    
    func update(_ query: String?){
        var i = 0
        scroll.removeAll()
        var temp = [String]()
        for message in messages.sorted(by: {$0.latest > $1.latest}){
            if query == nil || search.text().count == 0{
                message.frame = CGRect(x: 10, y: 80*CGFloat(i)+5, width: message.frame.width, height: message.frame.height)
                scroll.addSubview(message)
                temp.append(message.uid)
                i += 1
            }
            else{
                if let profile = Settings.shared.getProfile(message.uid){
                    if profile.name.match(query!) > 0{
                        message.frame = CGRect(x: 10, y: 80*CGFloat(i)+5, width: message.frame.width, height: message.frame.height)
                        self.scroll.addSubview(message)
                        temp.append(message.uid)
                        i += 1
                    }
                }
                else{
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
                        if let profile = Settings.shared.getProfile(message.uid){
                            if profile.name.match(query!) > 0{
                                message.frame = CGRect(x: 10, y: 80*CGFloat(i)+5, width: message.frame.width, height: message.frame.height)
                                self.scroll.addSubview(message)
                                temp.append(message.uid)
                                i += 1
                                self.scroll.contentSize = CGSize(width: self.scroll.frame.width, height: 80*CGFloat(i))
                            }
                        }
                    })
                }
            }
        }
        if let q = query{
            for friend in Settings.shared.friends{
                if !temp.contains(friend){
                    if let profile = Settings.shared.getProfile(friend){
                        if profile.name.match(q) > 0.0{
                            let new = MessageHeader(uid: friend, message: "new message", latest: Date())
                            new.frame = CGRect(x: 10, y: 80*CGFloat(i)+5, width: new.frame.width, height: new.frame.height)
                            self.scroll.addSubview(new)
                            i += 1
                        }
                    }
                }
            }
        }
        self.scroll.contentSize = CGSize(width: self.scroll.frame.width, height: 80*CGFloat(i))
    }
    
    @objc func addNew(){
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MessageHeader: UIView{
    
    let uid: String
    let title = UILabel(frame: CGRect(x: 80, y: 0, width: UIScreen.main.bounds.width-80, height: 40))
    let contents = UILabel(frame: CGRect(x: 80, y: 27, width: UIScreen.main.bounds.width-80, height: 40))
    var latest: Date
    
    var messages = [Message]()
    
    init(uid: String, message: String, latest: Date) {
        self.uid = uid
        self.latest = latest
        super .init(frame: CGRect(x: 10, y: 5, width: UIScreen.main.bounds.width-20, height: 70))
        layer.cornerRadius = 10
        contents.text = message
        addSubview(contents)
        
        let pic = ProfileImage(frame: CGRect(x: 5, y: 5, width: 60, height: 60), uid: uid)
        pic.layer.borderWidth = 2.3
        pic.layer.borderColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 0)
        addSubview(pic)
        
        getName()
        addSubview(title)
        
        title.font = Settings.shared.font
        contents.font = Settings.shared.font
        contents.increase(-2)
        
        self.isHidden = true
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        addSubview(button)
        button.addTarget(self, action: #selector(openConvo), for: .touchUpInside)
        
        if Settings.shared.unread.contains(uid){
            unread()
        }
    }
    
    func unread(){
        backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    }
    
    func online(){
        for subview in subviews{
            if subview is ProfileImage{
                subview.layer.borderColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
            }
        }
    }
    
    func offline(){
        for subview in subviews{
            if subview is ProfileImage{
                subview.layer.borderColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 0)
            }
        }
    }
    
    func getName(){
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
            if let name = Settings.shared.getProfile(self.uid)?.name{
                self.title.text = name
                self.isHidden = false
            }
            else{
                self.getName()
            }
        })
    }
    
    func updateMessage(_ message: String, _ latest: Date){
        contents.text = message
        self.latest = latest
    }
    
    @objc func openConvo(){
        if let name = Settings.shared.getProfile(uid)?.name{
            let page = PageConversation(title: name, uid: uid, header: self)
            Settings.shared.home?.container?.append(page)
            backgroundColor = .clear
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
