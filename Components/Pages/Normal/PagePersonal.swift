//
//  PagePersonal.swift
//  Kaktus
//
//  Created by Karl Cridland on 12/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PagePersonal: PageProfile, UIScrollViewDelegate {
    
    let bio: String
    var pictures = [Int:[Int:[TaggedImage]]]()
    
    init(uid: String, title: String, name: String, bio: String) {
        self.bio = bio
        super .init(uid: uid, title: title, name: name)
        scroll.frame = CGRect(x: 0, y: 150, width: UIScreen.main.bounds.width, height: frame.height-150)
        Firebase.shared.getTagged(self)
        scroll.delegate = self
    }
    
    func sortPictures(){
        var h = CGFloat(0.0)
        for year in pictures.keys.sorted().reversed(){
            for month in pictures[year]!.keys.sorted().reversed(){
                let banner = DateBanner(month: month, year: year)
                scroll.addSubview(banner)
                banner.min = h
                for picture in pictures[year]![month]!{
                    if let size = picture.image?.size{
                        let height = UIScreen.main.bounds.width/(size.width/size.height)
                        picture.frame = CGRect(x: 0, y: h, width: UIScreen.main.bounds.width, height: height)
                        scroll.addSubview(picture)
                        let button = UIButton(frame: picture.frame)
                        button.accessibilityElements = [picture]
                        scroll.addSubview(button)
                        button.addTarget(self, action: #selector(clickedPic), for: .touchUpInside)
                        h += height
                    }
                }
                banner.max = h
            }
        }
        scroll.contentSize = CGSize(width: UIScreen.main.bounds.width, height: h)
        
        for subview in scroll.subviews{
            if subview is DateBanner{
                scroll.bringSubviewToFront(subview)
            }
        }
    }
    
    @objc func clickedPic(sender: UIButton){
        if let picture = sender.accessibilityElements![0] as? TaggedImage{
            if let image = picture.image{
                let _ = FullScreen(image: image, tags: [], host: picture.host, event: picture.event, uid: picture.uid, pic: picture.picture)
            }
        }
    }
    
    override func edit(){
        super.edit()
        UIView.animate(withDuration: 0.4, animations: {
            if let ban = self.banner{
                ban.desc.isEditable = true
                ban.desc.isUserInteractionEnabled = true
                ban.desc.backgroundColor = .white
                ban.desc.textColor = .black
                ban.desc.layer.cornerRadius = 5
                ban.desc.frame = CGRect(x: 105, y: 30, width: UIScreen.main.bounds.width-115, height: 70)
                ban.desc.becomeFirstResponder()
                ban.desc.addLinks()
                
                let editButton = UIButton(frame: ban.desc.frame)
                ban.desc.addSubview(editButton)
                editButton.addTarget(self, action: #selector(self.editDesc), for: .touchUpInside)
            }
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for subview in scroll.subviews{
            if let banner = subview as? DateBanner{
                if banner.min + scroll.contentOffset.y > 0{
                    banner.frame = CGRect(x: 0, y: banner.min + scroll.contentOffset.y, width: banner.frame.width, height: banner.frame.height)
                }
                else{
                    banner.frame = CGRect(x: 0, y: banner.min, width: banner.frame.width, height: banner.frame.height)
                }
                if banner.min + scroll.contentOffset.y > banner.max{
                    banner.frame = CGRect(x: 0, y: banner.max - banner.frame.height, width: banner.frame.width, height: banner.frame.height)
                }
                
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DateBanner: UIView {
    
    var min = CGFloat(0.0)
    var max = CGFloat(0.0)
    
    init(month: Int, year: Int){
        super .init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20))
        backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 0.1527985873)
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: frame.width-20, height: frame.height))
        let months = ["January","February","March","April","May","June","July","August","September","October","November","December"]
        label.text = "\(months[month-1]) \(year)"
        label.textColor = .white
        label.font = Settings.shared.font
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
