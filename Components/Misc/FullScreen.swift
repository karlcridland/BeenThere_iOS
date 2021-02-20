//
//  FullScreen.swift
//  Been There
//
//  Created by Karl Cridland on 17/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class FullScreen: UIImageView {
    
    let host: String
    let event: String
    let uid: String?
    let pic: String?
    var info: FullScreenInfo?
    let block = UIView()
    var scale = CGFloat(1.0)
    
    var canExit = true
    
    init(image: UIImage, tags: [Tagger], host: String, event: String, uid: String?, pic: String?) {
        self.host = host
        self.event = event
        self.uid = uid
        self.pic = pic
        super .init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        contentMode = .scaleAspectFit
        
        block.frame = frame
        if let home = Settings.shared.home?.view{
            home.addSubview(block)
            home.addSubview(self)
        }
        self.image = image
        
        self.block.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.9)
        self.block.alpha = 0.0
        self.alpha = 0.2
        UIView.animate(withDuration: 0.2, animations: {
            self.block.alpha = 1.0
            self.alpha = 1.0
        })
        info = FullScreenInfo(self)
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: {_ in
            if let s = self.superview{
                s.addSubview(self.info!)
            }
        })
        
        let move = UIPanGestureRecognizer(target: self, action: #selector(moving))
        block.addGestureRecognizer(move)
        let zoom =  UIPinchGestureRecognizer(target: self, action: #selector(zooming))
        block.addGestureRecognizer(zoom)
        Settings.shared.fullscreen = self
        if let home = Settings.shared.home{
            move.delegate = home
            zoom.delegate = home
        }
    }
    
    @objc func moving(_ gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: self)
        self.center = CGPoint(x: self.center.x + translation.x*scale, y: self.center.y + translation.y*scale)
        gesture.setTranslation(CGPoint.zero, in: self)
        
        if gesture.state == .ended{
            if (self.center.y > UIScreen.main.bounds.height/2 && canExit){
                exit()
            }
            else{
                UIView.animate(withDuration: 0.1, animations: {
                    self.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
                    if let inf = self.info{
                        for tag in inf.tags{
                            tag.center = tag.accessibilityActivationPoint
                        }
                    }
                })
            }
        }
        if let inf = info{
            for tag in inf.tags{
                let point = tag.accessibilityActivationPoint
                tag.center = CGPoint(x: point.x + (self.center.x - UIScreen.main.bounds.width/2), y: point.y + (self.center.y - UIScreen.main.bounds.height/2))
            }
        }
    }
    
    @objc func zooming(_ gesture: UIPinchGestureRecognizer){
        
        if info!.tagsShown{
            info?.showTags()
        }
        
        if gesture.scale > 1 && gesture.scale < 3.2{
            self.transform = CGAffineTransform(scaleX: gesture.scale, y: gesture.scale)
            scale = gesture.scale*1.5
        }
        
        if gesture.scale > 1.1{
            canExit = false
        }
        if gesture.state == .ended{
            canExit = true
            scale = 1
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            })
        }
        
    }
    
    @objc func exit(){
        let time = 0.2
        UIView.animate(withDuration: time, animations: {
            self.block.alpha = 0.0
            self.alpha = 0.0
        })
        Timer.scheduledTimer(withTimeInterval: time, repeats: false, block: { _ in
            self.block.removeFromSuperview()
            self.removeFromSuperview()
        })
        Settings.shared.fullscreen = nil
        if let inf = info{
            inf.exit()
        }
        info?.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FullScreenInfo: UIView{
    
    let fullscreen: FullScreen
    var isTagged = false
    var hasLiked = false
    var tags = [Tagger]()
    var caption = LinkText()

    let tagButton = UIButton(frame: CGRect(x: 50, y: Settings.shared.upper_bound+75, width: 30, height: 30))
    var tagsShown = false
    let likeButton = UIButton(frame: CGRect(x: 10, y: Settings.shared.upper_bound+75, width: 30, height: 30))
    
    init(_ fullscreen: FullScreen) {
        self.fullscreen = fullscreen
        super .init(frame: CGRect(x: 0, y: Settings.shared.upper_bound, width: UIScreen.main.bounds.width, height: 100))
        
        if fullscreen.uid != nil{
            Firebase.shared.fullscreenExtra(self)
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { _ in
            if let view = Settings.shared.home?.view{
                view.addSubview(self.tagButton)
                view.addSubview(self.likeButton)
                view.addSubview(self.caption)
            }
        })
        
        let host = UILabel(frame: CGRect(x: 10, y: 10, width: UIScreen.main.bounds.width-50, height: 20))
        if let profile = Settings.shared.getProfile(fullscreen.host){
            host.text = "\(profile.name)"
        }
        host.font = Settings.shared.font
        addSubview(host)
        let eventTitle = UILabel(frame: CGRect(x: 10, y: 30, width: UIScreen.main.bounds.width-50, height: 20))
        if let event = Settings.shared.events[fullscreen.host]?[fullscreen.event]{
            eventTitle.text = "\(event.name)"
        }
        eventTitle.font = Settings.shared.font
        addSubview(eventTitle)
        if let uid = fullscreen.uid{
            let tagger = UILabel(frame: CGRect(x: 35, y: 50, width: UIScreen.main.bounds.width-50, height: 20))
            if let profile = Settings.shared.getProfile(uid){
                tagger.text = "\(profile.name)"
            }
            tagger.font = Settings.shared.font
            addSubview(tagger)
            let camera = UIImageView(frame: CGRect(x: 10, y: 50, width: 20, height: 20))
            camera.image = UIImage(named: "camera")
            addSubview(camera)
            if uid == Settings.shared.get().uid{
                camera.image = UIImage(named: "camera-highlight")
            }
        }
    }
    
    func update(){
        if tags.count > 0{
            for tag in tags{
                tag.accessibilityActivationPoint = tag.center
                if let view = Settings.shared.home?.view{
                    view.addSubview(tag)
                }
            }
            tagButton.addTarget(self, action: #selector(showTags), for: .touchUpInside)
            tagButton.setImage(UIImage(named: "tag"), for: .normal)
            if isTagged{
                tagButton.setImage(UIImage(named: "tag-highlight"), for: .normal)
            }
        }
        likeButton.addTarget(self, action: #selector(likePhoto), for: .touchUpInside)
        likeButton.setImage(UIImage(named: "heart"), for: .normal)
        if hasLiked{
            likeButton.setImage(UIImage(named: "heart-highlight"), for: .normal)
        }
        
        if caption.text!.count > 0{
            caption.frame = CGRect(x: 5, y: UIScreen.main.bounds.height-200, width: UIScreen.main.bounds.width-10, height: 190)
        }
    }
    
    @objc func likePhoto(){
        Firebase.shared.likePhoto(fullscreen.host, event: fullscreen.event, uid: fullscreen.uid!, picture: fullscreen.pic!)
        hasLiked = true
        update()
    }
    
    @objc func showTags(){
        if tagsDownloaded(){
            tagsShown = !tagsShown
            for tag in tags{
                if tagsShown{
                    tag.show()
                    tag.center = CGPoint(x: tag.center.x+17, y: tag.center.y)
                }
                else{
                    tag.hide()
                }
            }
        }
        else{
            for tag in tags{
                Firebase.shared.storeProfile(tag.uid, with: {}, completion: {})
            }
        }
    }
    
    func tagsDownloaded() -> Bool{
        for tag in tags{
            if Settings.shared.getProfile(tag.uid) == nil{
                return false
            }
        }
        return true
    }
    
    func exit(){
        tagButton.removeFromSuperview()
        likeButton.removeFromSuperview()
        caption.removeFromSuperview()
        for tag in tags{
            tag.hide()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
