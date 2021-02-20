//
//  PageUpload.swift
//  Been There
//
//  Created by Karl Cridland on 14/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageUpload: Page {
    
    let button = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
    let imageView = UIImageView(frame: CGRect(x: UIScreen.main.bounds.width/2 - 15, y: UIScreen.main.bounds.width/2 - 15, width: 30, height: 30))
    let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
    let caption = SearchBar(frame: CGRect(x: 20, y: UIScreen.main.bounds.width+20, width: UIScreen.main.bounds.width-40, height: 30), placeholder: "caption", type: .search)
    let tagButton = TagButton(frame: CGRect(x: 20, y: UIScreen.main.bounds.width+60, width: (UIScreen.main.bounds.width-40)/2, height: 30))
    
    let pad = TagPad(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
    let load = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
    
    let event: WidgetEvent?
    let type: imageType
    var page: PageProfile?
    
    init(event: WidgetEvent){
        self.type = .event
        self.event = event
        super .init(title: "upload")
        standard()
        scroll.addSubview(caption)
        scroll.addSubview(tagButton)
        scroll.addSubview(pad)
        pad.isHidden = true
        
        scroll.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width+100)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        caption.input.addTarget(self, action: #selector(returnScroll), for: .primaryActionTriggered)
        
        tagButton.page = self
        pad.page = self
        
        caption.isHidden = true
        tagButton.isHidden = true
        
        button.imageView?.contentMode = .scaleAspectFit
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: {_ in
            if let show = self.tagButton.show{
                self.scroll.addSubview(show)
                show.frame = CGRect(x: (UIScreen.main.bounds.width)/2-20, y: UIScreen.main.bounds.width+60, width: (UIScreen.main.bounds.width)/2, height: 30)
            }
        })
    }
    
    init(page: PageProfile){
        self.type = .profile
        self.event = nil
        self.page = page
        super .init(title: "upload")
        standard()
        
        button.imageView?.contentMode = .scaleAspectFill
        
        isHidden = true
    }
    
    init(page: PageCreatePost){
        self.type = .poster
        self.event = nil
        super .init(title: "upload")
        standard()
        
        isHidden = true
    }
    
    func standard(){
        scroll.addSubview(view)
        scroll.addSubview(imageView)
        scroll.addSubview(button)
        scroll.bounces = false
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        imageView.image = UIImage(named: "camera")
        button.addTarget(self, action: #selector(addImage), for: .touchUpInside)
        
        addImage()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            UIView.animate(withDuration: 0.1, animations: {
                self.scroll.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height-keyboardRectangle.height)
                self.scroll.contentOffset = CGPoint(x: 0, y: self.scroll.contentSize.height - self.scroll.frame.height)
            })
        }
    }
    
    override func moving(_ gesture: UIPanGestureRecognizer) {
        super.moving(gesture)
        returnScroll()
    }
    
    @objc func returnScroll(){
        UIView.animate(withDuration: 0.1, animations: {
            self.scroll.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        })
    }
    
    @objc func addImage(){
        returnScroll()
        if let home = Settings.shared.home{
            home.present(home.pickerController, animated: true, completion: nil)
        }
    }
    
    func submitEvent(){
        
        startLoading()
        if let _ = button.imageView?.image{
            if let _ = page?.target{
                print("huh")
                return
            }
            Firebase.shared.upload(self)
            print(1)
        }
        else{
            stopLoading()
        }
    }
    
    func startLoading(){
        scroll.addSubview(load)
        load.startAnimating()
        load.backgroundColor = .white
    }
    
    func stopLoading(){
        load.stopAnimating()
        load.removeFromSuperview()
    }
    
    override func disappear() {
        super.disappear()
        load.stopAnimating()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum imageType{
    case profile
    case event
    case poster
}
