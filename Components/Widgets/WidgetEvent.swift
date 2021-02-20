//
//  WidgetEvent.swift
//  Been There
//
//  Created by Karl Cridland on 13/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class WidgetEvent: Widget, UIScrollViewDelegate {
    
    let event: Event
    let caption = LinkText(frame: CGRect(x: 5, y: 25, width: UIScreen.main.bounds.width-15, height: 70))
    var isLoaded = false
    
    let like = UIButton(frame: CGRect(x: UIScreen.main.bounds.width-50, y: 150, width: 40, height: 40))
    let comment = UIButton(frame: CGRect(x: UIScreen.main.bounds.width-50, y: 200, width: 40, height: 40))
    let camera = UIButton(frame: CGRect(x: UIScreen.main.bounds.width-50, y: 250, width: 40, height: 40))
    let tagged = UIButton(frame: CGRect(x: UIScreen.main.bounds.width-50, y: 300, width: 40, height: 40))
    
    var liked = false
    var commented = false
    var pictured = false
    var isTagged = false
    
    var hasClicked = false
    
    let reload = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width-60, height: 50))
    
    init(event: Event){
        self.event = event
        super .init(title: event.name, frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height-Settings.shared.upper_bound-60)/2 - 25))
        let sb = SButton(frame: CGRect(x: UIScreen.main.bounds.width-50, y: 90, width: 40, height: 40), source: self)
        addSubview(sb)
        sb.setTitle("•••", for: .normal)
        
        tagged.frame = CGRect(x: UIScreen.main.bounds.width-50, y: frame.height-50, width: 40, height: 40)
        comment.center = sb.center.midPoint(tagged.center)
        like.center = sb.center.midPoint(comment.center)
        camera.center = comment.center.midPoint(tagged.center)
        
        let date = UILabel(frame: CGRect(x: frame.width-150, y: name.frame.minY+2, width: 140, height: name.frame.height))
        date.text = event.date.dmy()
        date.font = Settings.shared.font
        date.increase(-2)
        date.textColor = .white
        date.textAlignment = .right
        addSubview(date)
        
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.delegate = self
        scroll.addSubview(reload)
        reload.color = .white
        reload.startAnimating()
        
        scroll.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2965539384)
        scroll.layer.cornerRadius = 8
        reload.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width-60, height: frame.height-90)
        scroll.addSubview(reload)
        
    }
    
    @objc func upload(){
        Settings.shared.home?.container?.append(PageUpload(event: self))
    }
    
    func load(){
        if !isLoaded{
            Firebase.shared.getEvent(self)
            scroll.frame = CGRect(x: 5, y: 90, width: UIScreen.main.bounds.width-60, height: frame.height-100)
            
            like.setImage(UIImage(named: "heart"), for: .normal)
            like.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            comment.setImage(UIImage(named: "comment"), for: .normal)
            comment.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            camera.setImage(UIImage(named: "camera"), for: .normal)
            camera.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            tagged.setImage(UIImage(named: "tag"), for: .normal)
            tagged.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
            addSubview(scroll)
            addSubview(name)
            addSubview(subtitle)
            addSubview(caption)
            addSubview(like)
            addSubview(comment)
            addSubview(camera)
            addSubview(tagged)
            
            caption.increaseSize(-2)
            
            like.addTarget(self, action: #selector(likePost), for: .touchUpInside)
            camera.addTarget(self, action: #selector(upload), for: .touchUpInside)
            tagged.addTarget(self, action: #selector(seeTagged), for: .touchUpInside)
            comment.addTarget(self, action: #selector(openComments), for: .touchUpInside)
        }
        if let profile = Settings.shared.getProfile(event.uid){
            name.text = profile.name
        }
        isLoaded = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        reload.startAnimating()
        let generator = UIImpactFeedbackGenerator(style: .light)
        if (scroll.contentOffset.y < -50) && (!hasClicked) && scroll.isDragging{
            update()
            hasClicked = true
            generator.impactOccurred()
        }
        if scroll.contentOffset.y+scroll.frame.height > scroll.contentSize.height + 50{
            if let container = Settings.shared.home?.container{
                if let _ = container.pages.last as? PageEvent{
                    return
                }
                generator.impactOccurred()
                container.append(PageEvent(date: DateTime.shared.get(date: event.date), uid: event.uid, event: event))
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        hasClicked = false
    }
    
    func update(){
        var left = CGFloat(0.0)
        var right = CGFloat(0.0)
        for subview in scroll.subviews{
            if subview.tag != -1{
                subview.removeFromSuperview()
            }
        }
        scroll.addSubview(reload)
        reload.startAnimating()
        for thumbnail in event.gallery.sorted(by: {$0.likes > $1.likes}){
            if thumbnail.isLoaded{
                reload.frame = CGRect(x: 0, y: -50, width: UIScreen.main.bounds.width-60, height: 50)
                let aspect = (thumbnail.image?.size.width)!/(thumbnail.image?.size.height)!
                let height = (scroll.frame.width/2)/(aspect)
                scroll.addSubview(thumbnail)
                
                if left <= right{
                    thumbnail.frame = CGRect(x: 0, y: left, width: scroll.frame.width/2, height: height)
                    left = thumbnail.frame.maxY
                }
                else{
                    thumbnail.frame = CGRect(x: scroll.frame.width/2, y: right, width: scroll.frame.width/2, height: height)
                    right = thumbnail.frame.maxY
                }
                
                thumbnail.reposition()
            }
        }
        if let profile = Settings.shared.getProfile(event.uid){
            name.text = profile.name
        }
        scroll.contentSize = CGSize(width: scroll.frame.width, height: [[left,right].max()! + 10, scroll.frame.height + 1].max()!)
    }
    
    func refreshIcons(){
        ultimatum(like, "heart", liked)
        ultimatum(comment, "comment", commented)
        ultimatum(camera, "camera", pictured)
        ultimatum(tagged, "tag", isTagged)
    }
    
    private func ultimatum(_ button: UIButton, _ ref: String, _ condition: Bool){
        if !condition{
            button.setImage(UIImage(named: ref), for: .normal)
        }
        else{
            button.setImage(UIImage(named: "\(ref)-highlight"), for: .normal)
        }
    }
    
    @objc private func likePost(){
        Firebase.shared.likePost(self)
        liked = true
        refreshIcons()
    }
    
    @objc func seeTagged(){
        let page = PageTaggedList(event: self)
        Settings.shared.home?.container?.append(page)
    }
    
    @objc func openComments(){
        let page = PageComments(self)
        Settings.shared.home?.container?.append(page)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
