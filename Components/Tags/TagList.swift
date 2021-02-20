//
//  TagList.swift
//  Been There
//
//  Created by Karl Cridland on 14/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class TagList: UIView{
    
    let point: CGPoint
    let scroll: UIScrollView
    let pad: TagPad
    
    init(frame: CGRect, point: CGPoint, pad: TagPad) {
        self.point = point
        self.scroll = UIScrollView(frame: CGRect(x: 0, y: 20, width: frame.width, height: frame.height-20))
        self.pad = pad
        super .init(frame: frame)
        isHidden = true
        backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0.85)
        
        var temp = Settings.shared.friends
        temp.append(Settings.shared.get().uid)
        var i = 0
        for friend in temp.sorted(by: {Settings.shared.getProfile($0)!.name < Settings.shared.getProfile($1)!.name}){
            if !(pad.page?.tagButton.tags.contains(where: {$0.uid == friend}))! && !onScreen(friend){
                if let profile = Settings.shared.getProfile(friend){
                    if !profile.isBusiness(){
                        let button = UIButton(frame: CGRect(x: 10, y: 10+CGFloat(i)*35, width: frame.width-20, height: 30))
                        button.titleLabel?.font = Settings.shared.font
                        button.setTitleColor(.black, for: .normal)
                        button.setTitle(profile.name, for: .normal)
                        button.accessibilityLabel = friend
                        button.addTarget(self, action: #selector(pickUser), for: .touchUpInside)
                        
                        let arrow = UIImageView(frame: CGRect(x: frame.width-25, y: 15+CGFloat(i)*35, width: 20, height: 20))
                        arrow.image = UIImage(named: "arrow")
                        
                        scroll.addSubview(arrow)
                        scroll.addSubview(button)
                        i += 1
                    }
                }
            }
        }
        scroll.contentSize = CGSize(width: frame.width, height: 10+CGFloat(i)*35)
        addSubview(scroll)
        let c = center
        
        if scroll.contentSize.height < scroll.frame.height{
            self.scroll.frame = CGRect(x: self.scroll.frame.minX, y: self.scroll.frame.minY, width: self.scroll.frame.width, height: self.scroll.contentSize.height)
            self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: 20+self.scroll.contentSize.height)
            self.center = c
        }
        self.isHidden = false
        
        let q = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 30))
        q.font = Settings.shared.font
        q.text = "choose a tag:"
        q.textColor = .black
        q.textAlignment = .center
        addSubview(q)
        
        layer.cornerRadius = 4
        layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        layer.borderWidth = 2.0
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
            self.bringSubviewToFront(q)
        })
    }
    
    func onScreen(_ uid: String) -> Bool{
        for subview in subviews{
            if let t = subview as? Tagger{
                if t.uid == uid{
                    return true
                }
            }
        }
        return false
    }
    
    @objc func pickUser(sender: UIButton){
        let uid = sender.accessibilityLabel!
        pad.append(Tagger(point: point, uid: uid, new: true))
        removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
