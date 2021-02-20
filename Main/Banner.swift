//
//  Banner.swift
//  Kaktus
//
//  Created by Karl Cridland on 12/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class Banner: UIView{
    
    let title = UILabel()
    let left = UIButton()
    let right = UIButton()
    
    var held = false
    var stopMenu = false
    
    var nCount = Int()
    
    var menu = UIImageView(image: UIImage(named: "menu"))
    var back = UIImageView(image: UIImage(named: "back"))
    var search = UIImageView(image: UIImage(named: "search"))
    var profile = UIImageView(image: UIImage(named: "profile"))
    var submit = UIImageView(image: UIImage(named: "logo-clear"))
    var notifications = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    var sb = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    var plus = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    var so = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    var info = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    let a = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 7))
    
    let container: Container
    
    init(_ container: Container) {
        self.container = container
        super .init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Settings.shared.upper_bound+40))
        
        title.frame = CGRect(x: UIScreen.main.bounds.width/2 - 100, y: Settings.shared.upper_bound, width: 200, height: 30)
        title.font = UIFont(name: Settings.shared.fontName, size: 20)
        title.textAlignment = .center
        title.textColor = .white
        addSubview(title)
        sb.text = "•••"
        sb.textColor = .white
        
        plus.text = "+"
        so.text = "sign out"
        info.text = "i"
        info.textAlignment = .center
        so.font = Settings.shared.font
        so.textAlignment = .right
        
        left.frame = CGRect(x: 0, y: Settings.shared.upper_bound, width: 80, height: 40)
        right.frame = CGRect(x: UIScreen.main.bounds.width-80, y: Settings.shared.upper_bound, width: 80, height: 40)
        
        func adjust(_ views: [UIView], frame: CGRect){
            for i in 0 ..< views.count{
                views[i].frame = frame
            }
        }
        
        adjust([menu,back], frame: CGRect(x: 0, y: Settings.shared.upper_bound-5, width: 50, height: 40))
        adjust([submit,search,profile,sb,plus,so,info], frame: CGRect(x: UIScreen.main.bounds.width-50, y: Settings.shared.upper_bound-5, width: 50, height: 40))
        addSubview(info)
        
        for a in [submit,menu,search,back,profile,notifications,sb,so,plus,left,right]{
            addSubview(a)
            if (a is UIImageView) && (a != submit){
                let b = a as! UIImageView
                b.invert()
                b.contentMode = .scaleAspectFit
                b.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            }
        }
        
        plus.center = CGPoint(x: plus.center.x + 17, y: plus.center.y - 2)
        so.center = CGPoint(x: plus.center.x - 20, y: plus.center.y + 2)
        info.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        info.center = CGPoint(x: plus.center.x - 20, y: plus.center.y + 2)
        so.frame = CGRect(x: so.frame.minX-60, y: so.frame.minY, width: so.frame.width+50, height: so.frame.height)
        plus.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        
        notifications.center = search.center
        notifications.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        notifications.layer.borderWidth = 2
        notifications.layer.cornerRadius = 10
        notifications.textColor = .white
        notifications.textAlignment = .center
        notifications.font = Settings.shared.font
        notifications.clipsToBounds = true
        notifications.accessibilityFrame = notifications.frame
        
        submit.center = CGPoint(x: submit.center.x-5, y: submit.center.y+2)
        submit.transform = CGAffineTransform(scaleX: 0.8, y: 1.0)
        
        left.addTarget(self, action: #selector(leftHeld), for: .touchDown)
        left.addTarget(self, action: #selector(leftClicked), for: .touchUpInside)
        right.addTarget(self, action: #selector(rightClicked), for: .touchUpInside)
        
        clipsToBounds = false
        back.isHidden = true
        profile.isHidden = true
        
        a.layer.cornerRadius = 3.5
        a.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        a.center = CGPoint(x: menu.center.x+11, y: menu.center.y-7)
        a.isHidden = true
        addSubview(a)
        
        info.font = Settings.shared.font
        info.layer.cornerRadius = 10
        info.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        info.layer.borderWidth = 1.5
    }
    
    func updateNotifications(_ i: Int){
        nCount = i
        if let _ = container.pages.last as? PageConversation{
            return
        }
        switch i {
        case 0:
            notifications.text = ""
            notifications.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        default:
            notifications.text = String(i)
            notifications.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        }
        let width = notifications.text!.width(font: notifications.font)
        if width > 12{
            notifications.frame = CGRect(x: notifications.frame.maxX-width-10, y: notifications.frame.minY, width: width+10, height: 20)
        }
        else{
            notifications.frame = notifications.accessibilityFrame
        }
        if container.pages.count == 0{
            if i > 0{
                a.isHidden = false
            }
        }
    }
    
    @objc func leftHeld(){
        held = true
        var i = 0
        if !back.isHidden{
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
                if i == 10{
                    self.stopMenu = true
                    self.container.removeAllPages()
                    timer.invalidate()
                }
                if !self.held{
                    timer.invalidate()
                }
                i += 1
            })
        }
    }
    
    @objc func leftClicked(){
        held = false
        switch container.pages.last {
        
        case nil:
            if !stopMenu{
                if Settings.shared.profiles.keys.contains(Settings.shared.get().uid){
                    container.append(PageMenu())
                }
            }
            break
            
        case is PageEditMenu:
            if let page = container.pages.last as? PageEditMenu{
                if page.path.count == 0{
                    container.remove()
                    page.saveAll()
                }
                else{
                    page.back()
                }
            }
            break
            
        case is PageFoodMenu:
            if let page = container.pages.last as? PageFoodMenu{
                if page.path.count == 0{
                    container.remove()
                }
                else{
                    page.back()
                }
            }
            break
            
        default:
            container.remove()
        }
        stopMenu = false
    }
    
    @objc func rightClicked(){
        switch container.pages.last {
        
        case nil:
            container.append(PageSearch())
            break
            
        case is PageSearch:
            Firebase.shared.getPage(Settings.shared.get().uid)
            break
            
        case is PageMenu:
            Settings.shared.home?.container?.append(PageNotification())
            break
            
        case is PageCreatePost:
            (container.pages.last as! PageCreatePost).submit()
            break
            
        case is PageSettings:
            let _ = ConfirmAction(title: "sign out", with: {
                Settings.shared.signOut(true)
            })
            break
            
        case is PageEditMenu:
            UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
            if let page = container.pages.last as? PageEditMenu{
                page.addNew()
            }
            break
            
        case is PageEditDrinks:
            UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
            let _ = MissedDrink()
            break
            
        case is PageEditBasic:
            if let page = container.pages.last as?PageEditBasic{
                page.update()
            }
            break
            
        case is PageMagnifyManage:
            container.append(PageMagnify(managed: false))
            break
            
        case is PageUpload:
            if let page = container.pages.last as? PageUpload{
                switch page.type {
                case .event:
                    page.submitEvent()
                    break
                case .profile:
                    if let p = penultimate() as? PageProfile{
                        if let image = page.button.imageView!.image{
                            if p.target == nil{
                                p.banner!.pic.image = image
                            }
                            container.remove()
                            sb.isHidden = true
                            submit.isHidden = false
                        }
                    }
                    break
                default:
                    break
                }
            }
            break
            
        case is PageProfile:
            if let page = container.pages.last as? PageProfile{
                if page.isEditing{
                    page.finishEdit()
                    sb.isHidden = false
                    submit.isHidden = true
                }
                else{
                    let spb = SButton(frame: .zero, source: page)
                    spb.clicked()
                }
            }
            break
            
        case is PageComments:
            if let page = container.pages.last as? PageComments{
                page.newComment()
            }
            break
            
        case is PageFoodMenu:
            let _ = Allergens()
            break
            
        default:
            print("right - standard page")
        }
    }
    
    func penultimate() -> Page?{
        if container.pages.count > 1{
            return container.pages[container.pages.count-2]
        }
        return nil
    }
    
    func hideButtons(){
        for a in [back,profile,search,menu,submit,notifications,sb,so,plus,info]{
            a.isHidden = true
        }
    }
    
    func update(){
        a.isHidden = true
        for subview in container.subviews{
            if subview.tag == -1{
                subview.removeFromSuperview()
            }
        }
        hideButtons()
        if let p  = container.pages.last{
            title.text = p.title
            back.isHidden = false
        }
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
        switch container.pages.last {
        
        case nil:
            if nCount > 0{
                a.isHidden = false
            }
            title.text = container.currentTitle()
            search.isHidden = false
            menu.isHidden = false
            break
            
        case is PageConversation:
            notifications.isHidden = false
            notifications.text = ""
            if let page = container.pages.last as? PageConversation{
                page.newMessage.input.input.becomeFirstResponder()
                Firebase.shared.removeMessageNotifications(page.uid)
            }
            break
            
        case is PageSearch:
            (container.pages.last as! PageSearch).search.input.becomeFirstResponder()
            profile.isHidden = false
            break
            
        case is PageCreatePost:
            submit.isHidden = false
            (container.pages.last as! PageCreatePost).name.input.becomeFirstResponder()
            break
            
        case is PageUpload:
            submit.isHidden = false
            break
            
        case is PageComments:
            plus.isHidden = false
            break
            
        case is PageMenu:
            updateNotifications(nCount)
            notifications.isHidden = false
            break
            
        case is PageSettings:
            so.isHidden = false
            so.text = "sign out"
            break
            
        case is PageMagnifyManage:
            so.isHidden = false
            so.text = "manage"
            break
            
        case is PageEditMenu:
            plus.isHidden = false
            break
            
        case is PageEditDrinks:
            plus.isHidden = false
            break
            
        case is PageEditInfo:
            if let page = container.pages.last as? PageEditInfo{
                page.box.becomeFirstResponder()
            }
            break
            
        case is PageEditBasic:
            so.text = "save"
            so.isHidden = false
            break
            
        case is PageProfile:
            sb.isHidden = false
            submit.isHidden = true
            break
            
        case is PageFoodMenu:
            info.isHidden = false
            break
            
        default:
            break
        }
        hideRest()
    }
    
    func hideRest(){
        if let pages = Settings.shared.home?.container?.pages{
            for i in 0 ..< pages.count{
                if i < pages.count - 2{
                    pages[i].isHidden = true
                    pages[i].background.isHidden = true
                }
                else{
                    pages[i].isHidden = false
                    pages[i].background.isHidden = false
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
