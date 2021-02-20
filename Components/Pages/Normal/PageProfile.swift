//
//  PageProfile.swift
//  Kaktus
//
//  Created by Karl Cridland on 12/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageProfile: Page {
    
    let uid: String
    let name: String
    var banner: PageBanner?
    var isEditing = false
    var target: FeedContainer?
    
    init(uid: String, title: String, name: String) {
        self.uid = uid
        self.name = name
        super .init(title: title)
        banner = PageBanner(self)
        addSubview(banner!)
    }
    
    override func disappear() {
        super.disappear()
        
    }
    
    func edit(){
        isEditing = true
        UIView.animate(withDuration: 0.4, animations: {
            if let ban = self.banner{
                ban.camera.isHidden = false
                ban.upload.isHidden = false
            }
        })
    }
    
    @objc func editDesc(sender: UIButton){
        if let desc = sender.superview{
            desc.becomeFirstResponder()
        }
    }
    
    func finishEdit(){
        isEditing = false
        UIView.animate(withDuration: 0.4, animations: {
            if let ban = self.banner{
                ban.desc.isEditable = false
                ban.desc.isUserInteractionEnabled = false
                ban.desc.backgroundColor = .clear
                ban.desc.textColor = .white
                ban.desc.frame = CGRect(x: 100, y: 30, width: UIScreen.main.bounds.width-120, height: 85)
                ban.desc.addLinks()
                
                for subview in ban.desc.subviews{
                    if subview is UIButton{
                        subview.removeFromSuperview()
                    }
                }
                
                ban.camera.isHidden = true
                ban.upload.isHidden = true
                if let text = ban.desc.text{
                    Firebase.shared.updateBio(text)
                }
                if let image = ban.pic.image{
                    Firebase.shared.updateProfilePic(image)
                }
            }
        })
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PageBanner: UIView{
    
    let page: PageProfile
    let followers = NButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width/2, height: 30), title: "follower", s: true)
    let following = NButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width/2, height: 30), title: "following", s: false)

    let pic: ProfileImage
    let desc = LinkText(frame: CGRect(x: 100, y: 30, width: UIScreen.main.bounds.width-120, height: 85))
    let info: BusinessScroll
    let upload = UIButton(frame: CGRect(x: 10, y: 10, width: 90, height: 90))
    let camera = UIImageView(frame: CGRect(x: 10, y: 10, width: 90, height: 90))
    
    init(_ page: PageProfile){
        self.page = page
        self.pic = ProfileImage(frame: CGRect(x: 10, y: 10, width: 90, height: 90), uid: page.uid)
        self.info = BusinessScroll(page: page)
        super .init(frame: CGRect(x: 0, y: 0, width: page.frame.width, height: 150))
        Firebase.shared.getPersonal(self)
        
        let title = UILabel(frame: CGRect(x: 105, y: 5, width: UIScreen.main.bounds.width-120, height: 30))
        followers.frame = CGRect(x: 10, y: 115, width: UIScreen.main.bounds.width/2-15, height: 25)
        following.frame = CGRect(x: UIScreen.main.bounds.width/2+5, y: 115, width: UIScreen.main.bounds.width/2-15, height: 25)
        
        followers.addTarget(self, action: #selector(getFollowers), for: .touchUpInside)
        following.addTarget(self, action: #selector(getFollowing), for: .touchUpInside)
        
        camera.image = UIImage(named: "camera")
        camera.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        
        camera.isHidden = true
        upload.isHidden = true
        upload.addTarget(self, action: #selector(uploadImage), for: .touchUpInside)
        
        title.text = page.name
        title.textColor = .white
        title.font = Settings.shared.font
        
        for a in [followers,following]{
            a.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            a.layer.cornerRadius = 3
        }
        
        backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        
        for a in [pic,camera,upload,title,desc,followers,following]{
            addSubview(a)
        }
        
        if (Settings.shared.getProfile(page.uid)?.isBusiness())!{
            title.removeFromSuperview()
            desc.removeFromSuperview()
//            address.text = (page as! PageBusiness).name.address()
//            address.numberOfLines = 0
//            address.font = title.font
//            address.textAlignment = .center
//            addSubview(address)
            addSubview(info)
            
            frame = CGRect(x: 0, y: 0, width: page.frame.width, height: 200)
            
        }
        else{
            desc.text = (page as! PagePersonal).bio
            desc.addLinks()
            desc.isEditable = false
        }
    }
    
    @objc func getFollowing(){
        let new = PageFollowList(uid: page.uid, dir: .right)
        Settings.shared.home?.container?.append(new)
        Settings.shared.home?.container?.banner?.title.text = "following"
    }
    
    @objc func getFollowers(){
        let new = PageFollowList(uid: page.uid, dir: .left)
        Settings.shared.home?.container?.append(new)
        Settings.shared.home?.container?.banner?.title.text = "followers"
    }
    
    @objc func uploadImage(){
        let pageUpload = PageUpload(page: page)
        Settings.shared.home?.container?.append(pageUpload)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BusinessScroll: UIScrollView, UIScrollViewDelegate{
    
    let food = UIButton()
    let drink = UIButton()
    let open = UIButton()
    let loc = UIButton()
    let info = UIButton()
    let message = UIButton()
    
    let page: PageProfile
    
    init(page: PageProfile) {
        self.page = page
        super .init(frame: CGRect(x: 110, y: 10, width: UIScreen.main.bounds.width-120, height: 100))
        Firebase.shared.getBusinessInfo(self)
        
        var i = 0
        for image in ["food","drink","opening","location","info","message"]{
            let view = UIView(frame: CGRect(x: 65*CGFloat(i), y: 15, width: 50, height: 50))
            let img = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            img.image = UIImage(named: image)
            img.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            view.addSubview(img)
            [food,drink,open,loc,info,message][i].frame = view.frame
            view.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            view.layer.cornerRadius = 25
            let label = UILabel(frame: CGRect(x: 65*CGFloat(i), y: 55, width: 50, height: 40))
            label.textAlignment = .center
            label.text = image
            label.numberOfLines = 0
            label.font = Settings.shared.font
            label.increase(-5)
            addSubview(label)
            addSubview(view)
            addSubview([food,drink,open,loc,info,message][i])
            i += 1
        }
        contentSize = CGSize(width: CGFloat(i)*65-10, height: 100)
        showsHorizontalScrollIndicator = false
        
        delegate = self
        
        food.addTarget(self, action: #selector(openFoodMenu), for: .touchUpInside)
        drink.addTarget(self, action: #selector(openDrinkMenu), for: .touchUpInside)
        open.addTarget(self, action: #selector(openBusiHours), for: .touchUpInside)
        loc.addTarget(self, action: #selector(openMap), for: .touchUpInside)
        info.addTarget(self, action: #selector(openExtra), for: .touchUpInside)
        message.addTarget(self, action: #selector(messageBusiness), for: .touchUpInside)
        
        if page.uid == Settings.shared.get().uid{
            contentSize = CGSize(width: CGFloat(i-1)*65-10, height: 100)
            for subview in subviews{
                if subview.frame.maxX > contentSize.width{
                    subview.removeFromSuperview()
                }
            }
        }
    }
    
    @objc func openFoodMenu(){
        Settings.shared.home?.container?.append(PageFoodMenu(uid: page.uid))
    }
    
    @objc func openDrinkMenu(){
        Settings.shared.home?.container?.append(PageDrinkMenu(uid: page.uid))
    }
    
    @objc func openBusiHours(){
        Settings.shared.home?.container?.append(PageBusiOpen(uid: page.uid))
    }
    
    @objc func openMap(){
        Settings.shared.home?.container?.append(PageAddress(uid: page.uid))
    }
    
    @objc func openExtra(){
        Settings.shared.home?.container?.append(PageExtraInfo(uid: page.uid))
    }
    
    @objc func messageBusiness(){
        if page.uid == Settings.shared.get().uid{
            return
        }
        let temp = Settings.shared.home?.container?.banner?.title.text
        Settings.shared.home?.container?.removeAllPages()
        Settings.shared.home?.container?.openMessages()
        MessageHeader(uid: page.uid, message: "", latest: Date()).openConvo()
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            if let _ = Settings.shared.home?.container?.pages.last as? PageConversation{
                Settings.shared.home?.container?.banner?.title.text = temp
            }
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
