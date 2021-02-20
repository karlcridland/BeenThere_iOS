//
//  PageCreatePost.swift
//  Been There
//
//  Created by Karl Cridland on 13/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageCreatePost: PageReverse {
    
    let name = SearchBar(frame: CGRect(x: 10, y: 10, width: UIScreen.main.bounds.width-20, height: 30), placeholder: "title", type: .search)
    let caption = SearchBar(frame: CGRect(x: 10, y: 50, width: UIScreen.main.bounds.width-20, height: 30), placeholder: "caption", type: .caption)
    let question = UILabel(frame: CGRect(x: 10, y: 90, width: UIScreen.main.bounds.width-70, height: 30))
    let check = CButton(frame: CGRect(x: UIScreen.main.bounds.width-30, y: 95, width: 20, height: 20))
    let date = DatePicker(frame: CGRect(x: 10, y: 125, width: UIScreen.main.bounds.width-20, height: 30), maxYear: Int(Calendar.current.component(.year, from: Date()))+5)
    
    let camera = UIImageView()
    let poster = UIButton()
    
    init(){
        super .init(title: "create post")
        scroll.addSubview(name)
        scroll.addSubview(caption)
        scroll.addSubview(question)
        scroll.addSubview(check)
        scroll.addSubview(date)
        scroll.addSubview(camera)
        scroll.addSubview(poster)
        
        question.text = "is this for an upcoming event?"
        question.textColor = .white
        question.font = Settings.shared.font
        
        check.addTarget(self, action: #selector(click), for: .touchUpInside)
        click()
        
        for form in [name,caption]{
            form.input.addTarget(self, action: #selector(returnScroll), for: .primaryActionTriggered)
        }
        
        poster.addTarget(self, action: #selector(posterClicked), for: .touchUpInside)
        poster.frame = CGRect(x: 10, y: 165, width: UIScreen.main.bounds.width-20, height: UIScreen.main.bounds.width-20)
        poster.layer.borderWidth = 2
        poster.layer.cornerRadius = 4
        poster.clipsToBounds = true
        poster.contentMode = .scaleAspectFill
        
        camera.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        camera.image = UIImage(named: "camera")
        camera.center = poster.center
        
    }
    
    @objc func click(){
        name.input.resignFirstResponder()
        caption.input.resignFirstResponder()
        if check.isChecked{
            poster.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            date.isHidden = false
            camera.isHidden = false
            poster.isHidden = false
        }
        else{
            date.isHidden = true
            camera.isHidden = true
            poster.isHidden = true
            if !(self is PageEditPost){
                name.input.becomeFirstResponder()
            }
        }
    }
    
    @objc func posterClicked(){
        let upload = PageUpload(page: self)
        Settings.shared.home?.container?.append(upload)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            scroll.frame = CGRect(x: 0, y: 0, width: scroll.frame.width, height: self.frame.height-keyboardRectangle.height)
        }
    }
    
    @objc func returnScroll(){
        UIView.animate(withDuration: 0.1, animations: {
            self.scroll.contentOffset = CGPoint(x: 0, y: 0)
            let buf = Settings.shared.upper_bound+40
            self.scroll.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-buf)
        })
    }
    
    func submit(){
        if check.isChecked{
            if let image = poster.imageView?.image{
                if (name.check() && caption.check() && date.laterDate()){
                    Firebase.shared.createEvent(date: date.toString(), title: name.text(), caption: caption.text(), poster: image)
                    Settings.shared.home?.container?.removeAllPages()
                }
            }
            else{
                poster.layer.borderColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
            }
        }
        else{
            if (name.check() && caption.check()){
                Firebase.shared.createEvent(date: DateTime.shared.get(), title: name.text(), caption: caption.text(), poster: nil)
                Settings.shared.home?.container?.removeAllPages()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
