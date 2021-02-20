//
//  NewComment.swift
//  Been There
//
//  Created by Karl Cridland on 23/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class NewComment: UIView, UITextViewDelegate{
    
    let block = UIView()
    let textBox = LinkText()
    var wordCount = UILabel()
    let page: PageComments
    var lower = Settings.shared.lower_bound
    
    init(page: PageComments) {
        self.page = page
        var width = UIScreen.main.bounds.width-100
        if width > 300{
            width = 300
        }
        super .init(frame: CGRect(x: (UIScreen.main.bounds.width-width)/2, y: 150, width: width, height: 130))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        backgroundColor = .white
        layer.cornerRadius = 10
        
        
        block.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.block.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.block.alpha = 0.0
        self.alpha = 0.2
        
        UIView.animate(withDuration: 0.2, animations: {
            self.block.alpha = 1.0
            self.alpha = 1.0
        })
        
        if let view = Settings.shared.home?.view{
            view.addSubview(block)
            view.addSubview(self)
        }
        
        let submit = UIButton(frame: CGRect(x: frame.width-50, y: frame.height-40, width: 40, height: 40))
        submit.setImage(UIImage(named: "logo-clear"), for: .normal)
        addSubview(submit)
        submit.addTarget(self, action: #selector(clicked), for: .touchUpInside)
        
        wordCount = UILabel(frame: CGRect(x: frame.width-160, y: frame.height-30, width: 100, height: 20))
        wordCount.text = "0/140"
        wordCount.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        wordCount.textAlignment = .right
        wordCount.font = Settings.shared.font
        addSubview(wordCount)
        
        textBox.frame = CGRect(x: 5, y: 5, width: frame.width-10, height: frame.height-45)
        textBox.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        textBox.layer.cornerRadius = 5
        textBox.textColor = .black
        textBox.isEditable = true
        textBox.isUserInteractionEnabled = true
        addSubview(textBox)
        textBox.becomeFirstResponder()
        
        let cancel = UIButton(frame: CGRect(x: 5, y: frame.height-30, width: 80, height: 20))
        cancel.setTitle("cancel", for: .normal)
        cancel.setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), for: .normal)
        addSubview(cancel)
        cancel.titleLabel!.font = Settings.shared.font
        cancel.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(moving)))
        
        
        textBox.delegate = self
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textBox.textViewDidChange(textView)
        didType(sender: textBox)
    }
    
    @objc func didType(sender: LinkText){
        wordCount.text = "\(sender.text.count)/140"
        if sender.text.count > 140{
            wordCount.textColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        }
        else{
            wordCount.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.lower = UIScreen.main.bounds.height-keyboardRectangle.height
        }
    }
    
    @objc func moving(_ gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: self)
        let view = gesture.view!
        var x = view.center.x + translation.x
        var y = view.center.y + translation.y
        
        if x - view.frame.width/2 < 0{
            x = view.frame.width/2
        }
        
        if x + view.frame.width/2 > UIScreen.main.bounds.width{
            x = UIScreen.main.bounds.width - view.frame.width/2
        }
        
        if y - view.frame.height/2 < Settings.shared.upper_bound{
            y = Settings.shared.upper_bound + view.frame.height/2
        }
        
        if y + view.frame.height/2 > lower{
            y = lower - view.frame.height/2
        }
        
        view.center = CGPoint(x: x, y: y)
        gesture.setTranslation(CGPoint.zero, in: self)
        
        
        if gesture.state == .began{
            UIView.animate(withDuration: 0.2, animations: {
                view.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            })
        }
        
        if gesture.state == .ended{
            UIView.animate(withDuration: 0.2, animations: {
                view.transform = CGAffineTransform.identity
            })
        }
    }

    @objc func clicked(){
        if textBox.text.count <= 140 && textBox.text.count > 0{
            Firebase.shared.sendComment(page, textBox.text)
            close()
        }
    }
    
    @objc func close(){
        UIView.animate(withDuration: 0.2, animations: {
            self.block.alpha = 0.0
            self.alpha = 0.0
        })
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { _ in
            self.block.removeFromSuperview()
            self.removeFromSuperview()
        })
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

