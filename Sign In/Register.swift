//
//  Register.swift
//  Kaktus
//
//  Created by Karl Cridland on 11/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class Register: UIView {
    
    var state = formState.signin
    
    var email: SearchBar?
    var password: SearchBar?
    var confirm: SearchBar?
    var username: SearchBar?
    var name: SearchBar?
    var address: SearchBar?
    var business: SearchBar?
//    var date: DatePicker?
    var date: CButton?
    var dobTitle: UILabel?
    var forget = UIButton()
    
    let submitButton = UIButton()
    let leftTrigger = Trigger(left: true, frame: CGRect(x: 0, y: 90, width: 30, height: 120))
    let rightTrigger = Trigger(left: false, frame: CGRect(x: UIScreen.main.bounds.width-30, y: 90, width: 30, height: 120))
    
    let scroll = UIScrollView(frame: CGRect(x: 0, y: 200, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-200))
    var keyboardHeight = CGFloat(0.0)

    let background: UIImageView
    
    let load = UIActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.width/2 - 100, y: 200, width: 200, height: 200))
    
    let errorMessage = UILabel()
    
    let attract = UIView()
    
    init() {
        background = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        super .init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        addSubview(background)
        if scroll.frame.width > 400{
            scroll.frame = CGRect(x: frame.width/2 - 200, y: 200, width: 400, height: UIScreen.main.bounds.height-200)
        }
        errorMessage.frame = CGRect(x: scroll.frame.minX+40, y: 200, width: scroll.frame.width-80, height: 30)
        errorMessage.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)
        errorMessage.layer.cornerRadius = 4
        errorMessage.layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        errorMessage.layer.borderWidth = 1
        errorMessage.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        errorMessage.clipsToBounds = true
        errorMessage.isHidden = true
        errorMessage.font = Settings.shared.font
        errorMessage.textAlignment = .center
        errorMessage.increase(-2)
        addSubview(errorMessage)
        organise()
        background.image = UIImage(named: "beach")
        background.contentMode = .scaleAspectFill
        for trigger in [leftTrigger,rightTrigger]{
            addSubview(trigger)
            trigger.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 0.7)
        }
        let logo = UIImageView(frame: CGRect(x: UIScreen.main.bounds.width/2 - 50, y: 100, width: 100, height: 100))
        logo.image = UIImage(named: "logo-clear")
        addSubview(logo)
        
        rightTrigger.addTarget(self, action: #selector(rightTriggered), for: .touchUpInside)
        leftTrigger.addTarget(self, action: #selector(leftTriggered), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.titleLabel?.font = Settings.shared.font
        submitButton.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 0.7)
        submitButton.layer.cornerRadius = 4.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        addSubview(scroll)
        addSubview(forget)
        addSubview(load)
        
        if let cred = Settings.shared.lastSignIn(){
            email?.input.text = cred.email
            email?.denullify()
            email?.input.textColor = email?.textColor
            
            password?.input.isSecureTextEntry = true
            password?.input.text = cred.password
            password?.denullify()
            password?.input.textColor = password?.textColor
            
            submit()
        }
        Settings.shared.r = self
    }
    
    @objc func requestPasswordReset(){
        if let e = email?.text(){
            let _ = ResetPassword(email: e)
        }
    }
    
    func startLoading(){
        for a in [email,password,confirm,username,name,address,business]{
            a?.isUserInteractionEnabled = false
            a?.alpha = 0.5
        }
        addSubview(load)
        load.startAnimating()
    }
    
    func stopLoading(){
        for a in [email,password,confirm,username,name,address,business]{
            a?.isUserInteractionEnabled = true
            a?.alpha = 1.0
        }
        load.stopAnimating()
        load.removeFromSuperview()
    }
    
    func organise(){
        for form in [email,password,confirm,username,name,address,business,submitButton,date,dobTitle]{
            if let search = form{
                search.removeFromSuperview()
            }
        }
        forget.removeFromSuperview()
        attract.removeFromSuperview()
        switch state {
            case .signin:
                
                leftTrigger.hide()
                rightTrigger.show()
                
                email = SearchBar(frame: CGRect(x: 40, y: 50, width: scroll.frame.width-80, height: 30), placeholder: "email", type: .email)
                email?.input.textContentType = .emailAddress
                email?.textChanged()
                scroll.addSubview(email!)
                
                password = SearchBar(frame: CGRect(x: 40, y: 100, width: scroll.frame.width-80, height: 30), placeholder: "password", type: .password)
                password?.input.textContentType = .password
                password?.textChanged()
                scroll.addSubview(password!)
                
                submitButton.frame = CGRect(x: 40, y: 150, width: scroll.frame.width-80, height: 30)
                submitButton.setTitle("continue", for: .normal)
                scroll.addSubview(submitButton)
                
                scroll.contentSize = CGSize(width: scroll.frame.width-80, height: 240)
                
                leftTrigger.hide()
                rightTrigger.setTitle("register", for: .normal)
                
                forget = UIButton(frame: CGRect(x: submitButton.frame.minX+scroll.frame.minX, y: frame.height-100, width: submitButton.frame.width, height: 30))
                forget.setTitle("forgotten password?", for: .normal)
                forget.titleLabel!.font = Settings.shared.font
                
                forget.addTarget(self, action: #selector(requestPasswordReset), for: .touchUpInside)
                addSubview(forget)
                
                addReturn()
                break
                
            case .register:
                
                Firebase.shared.usernameDownload()
                
                leftTrigger.show()
                leftTrigger.setTitle("back", for: .normal)
                rightTrigger.show()
                rightTrigger.setTitle("business", for: .normal)
                
                name = SearchBar(frame: CGRect(x: 40, y: 50, width: scroll.frame.width-80, height: 30), placeholder: "name", type: .search)
                name?.textChanged()
                scroll.addSubview(name!)
                
                username = SearchBar(frame: CGRect(x: 40, y: 100, width: scroll.frame.width-80, height: 30), placeholder: "username", type: .username)
                username?.textChanged()
                scroll.addSubview(username!)
                
                email = SearchBar(frame: CGRect(x: 40, y: 150, width: scroll.frame.width-80, height: 30), placeholder: "email", type: .email)
                email?.textChanged()
                scroll.addSubview(email!)
                
                password = SearchBar(frame: CGRect(x: 40, y: 200, width: scroll.frame.width-80, height: 30), placeholder: "password", type: .password)
                password?.textChanged()
                scroll.addSubview(password!)
                
                confirm = SearchBar(frame: CGRect(x: 40, y: 250, width: scroll.frame.width-80, height: 30), placeholder: "confirm", type: .password)
                confirm?.textChanged()
                scroll.addSubview(confirm!)
                
                dobTitle = UILabel(frame: CGRect(x: 40, y: 300, width: scroll.frame.width-80, height: 34))
                dobTitle?.text = "         i am aged 18+"
                dobTitle?.textColor = .white
                dobTitle?.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 0.7)
                dobTitle?.font = Settings.shared.font
                scroll.addSubview(dobTitle!)
                dobTitle?.layer.cornerRadius = 4
                dobTitle?.clipsToBounds = true
                
//                date = DatePicker(frame: CGRect(x: 40, y: 330, width: scroll.frame.width-80, height: 30), maxYear: nil)
                date = CButton(frame: CGRect(x: 46, y: 306, width: 22, height: 22))
                date!.layer.cornerRadius = 4.0
                scroll.addSubview(date!)
                
                submitButton.frame = CGRect(x: 40, y: 350, width: scroll.frame.width-80, height: 30)
                submitButton.setTitle("create", for: .normal)
                scroll.addSubview(submitButton)
                
                scroll.contentSize = CGSize(width: scroll.frame.width-80, height: 430)
                
                addReturn()
                
                popup()
                break
                
            case .business:
                
                leftTrigger.show()
                leftTrigger.setTitle("back", for: .normal)
                rightTrigger.hide()
                
                name = SearchBar(frame: CGRect(x: 40, y: 50, width: scroll.frame.width-80, height: 30), placeholder: "business title", type: .search)
                name?.textChanged()
                scroll.addSubview(name!)
                
                address = SearchBar(frame: CGRect(x: 40, y: 100, width: scroll.frame.width-80, height: 30), placeholder: "address", type: .search)
                address?.textChanged()
                scroll.addSubview(address!)
                
                email = SearchBar(frame: CGRect(x: 40, y: 150, width: scroll.frame.width-80, height: 30), placeholder: "email", type: .email)
                email?.textChanged()
                scroll.addSubview(email!)
                
                password = SearchBar(frame: CGRect(x: 40, y: 200, width: scroll.frame.width-80, height: 30), placeholder: "password", type: .password)
                password?.textChanged()
                scroll.addSubview(password!)
                
                confirm = SearchBar(frame: CGRect(x: 40, y: 250, width: scroll.frame.width-80, height: 30), placeholder: "confirm", type: .password)
                confirm?.textChanged()
                scroll.addSubview(confirm!)
                
                submitButton.frame = CGRect(x: 40, y: 300, width: scroll.frame.width-80, height: 30)
                submitButton.setTitle("create", for: .normal)
                scroll.addSubview(submitButton)
                
                scroll.contentSize = CGSize(width: scroll.frame.width-80, height: 350)
                
                addReturn()
                break
        }
        bringSubviewToFront(errorMessage)
        bringSubviewToFront(forget)
    }
    
    func popup(){
        let r = rightTrigger.frame
        attract.frame = CGRect(x: r.minX - 120, y: r.minY + 65, width: 110, height: 50)
        attract.removeAll()
        addSubview(attract)
        
        let dumbyarrow = UIImageView(frame: CGRect(x: 50, y: -40, width: 55, height: 40))
        dumbyarrow.image = UIImage(named: "dumbyarrow")
        attract.addSubview(dumbyarrow)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 110, height: 50))
        attract.addSubview(label)
        label.text = "bar or restaurant? you need this one!"
        label.numberOfLines = 0
        label.font = Settings.shared.font
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.increase(-3)
        UIView.animate(withDuration: 0.3, animations: {
            label.transform = CGAffineTransform(scaleX: 2, y: 2)
        })
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            UIView.animate(withDuration: 0.3, animations: {
                label.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            })
        })
        
    }
    
    func addReturn(){
        for form in [email,password,confirm,username,name,address,business]{
            form?.input.addTarget(self, action: #selector(returnScroll), for: .primaryActionTriggered)
            form?.input.addTarget(self, action: #selector(clearError), for: .editingDidEnd)
        }
    }
    
    @objc func clearError(){
        errorMessage.isHidden = true
    }
    
    @objc func rightTriggered(){
        returnScroll()
        switch state {
        case .signin:
            state = .register
            organise()
            break
            
        case .register:
            state = .business
            organise()
            break
            
        default:
            break
        }
    }
    
    @objc func leftTriggered(){
        returnScroll()
        switch state {
        case .register:
            state = .signin
            organise()
            break
            
        case .business:
            state = .register
            organise()
            break
            
        default:
            break
        }
    }
    
    func check() -> Bool{
        switch state {
        case .signin:
            for a in [email,password]{
                if let form = a{
                    if form.text().count == 0{
                        return throwError(.fieldEmpty)
                    }
                }
            }
            if email!.check(){
                if password!.check(){
                    return true
                }
                else{
                    return throwError(.passwordBad)
                }
            }
            else{
                return throwError(.emailInvalid)
            }
        case .register:
            for a in [username, name, email, password, confirm, date]{
                if let form = a as? SearchBar{
                    if form.text().count == 0{
                        return throwError(.fieldEmpty)
                    }
                }
            }
            if username!.text().count >= 4 && username!.text().count <= 10{
                if !username!.text().isBadWord(){
                    if username!.check(){
                        if email!.check(){
                            if password!.check(){
                                if (password!.text() == confirm!.text()){
                                    if date!.isChecked{
                                        return name!.check()
                                    }
                                    return throwError(.tooYoung)
                                }
                                return throwError(.passwordsDifferent)
                            }
                            return throwError(.passwordBad)
                        }
                        return throwError(.emailInvalid)
                    }
                    return throwError(.usernameTaken)
                }
                return throwError(.nameOffensive)
            }
            return throwError(.usernameLength)
        case .business:
            for a in [name,address,email,password,confirm]{
                if let form = a{
                    if form.text().count == 0{
                        return throwError(.fieldEmpty)
                    }
                }
            }
            if !name!.text().isBadWord(){
                if password!.check(){
                    if email!.check(){
                        if (password!.text() == confirm!.text()){
                            return (name!.check() && address!.check())
                        }
                        return throwError(.passwordsDifferent)
                    }
                    return throwError(.emailInvalid)
                }
                return throwError(.passwordBad)
            }
            return throwError(.nameOffensive)
        }
    }
    
    @objc func submit(){
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
        startLoading()
        returnScroll()
        if check(){
            switch state {
            case .signin:
                Settings.shared.signIn(email!.text(), password!.text())
                break
            case .register:
                let eula = Agreement(packet: UserPacket(name: name!.text(), username: username!.text(), password: password!.text(), email: email!.text()))
                addSubview(eula)
                break
            case .business:
                let eula = Agreement(packet: UserPacket(name: name!.text(), address: address!.text(), password: password!.text(), email: email!.text()))
                addSubview(eula)
                break
            }
            for a in  [email,password,confirm,username,name,address,business]{
                a?.input.resignFirstResponder()
            }
        }
        else{
            stopLoading()
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            scroll.frame = CGRect(x: scroll.frame.minX, y: 200, width: scroll.frame.width, height: UIScreen.main.bounds.height-200-keyboardRectangle.height)
        }
    }
    
    @objc func returnScroll(){
        UIView.animate(withDuration: 0.1, animations: {
            self.scroll.contentOffset = CGPoint(x: 0, y: 0)
            self.scroll.frame = CGRect(x: self.scroll.frame.minX, y: 200, width: self.scroll.frame.width, height: UIScreen.main.bounds.height-200)
        })
    }
    
    func throwError(_ code: registerErrors) -> Bool{
        stopLoading()
        errorMessage.isHidden = false
        subviews.first(where: {$0 is Agreement})?.removeFromSuperview()
        errorHeight(30)
        errorMessage.numberOfLines = 0
        switch code {
        case .emailInUse:
            Firebase.shared.usernameDownload()
            errorMessage.text = "email address already in use"
            break
        case .passwordBad:
            errorMessage.text = "password must be 7 letters min and contain a capital and a digit"
            errorHeight(60)
            break
        case .passwordsDifferent:
            errorMessage.text = "passwords don't match"
            break
        case .usernameTaken:
            errorMessage.text = "username already in use"
            break
        case .usernameLength:
            errorMessage.text = "username must be between 4 and 10 letters long"
            errorHeight(60)
            break
        case .nameOffensive:
            errorMessage.text = "cannot contain offensive words"
            break
        case .tooYoung:
            errorMessage.text = "must be at least 18 years to use this app"
            break
        case .fieldEmpty:
            errorMessage.text = "all fields must be filled"
            break
        case .failedSignIn:
            errorMessage.text = "email or password incorrect"
            break
        case .emailInvalid:
            errorMessage.text = "email is invalid"
            break
        }
        return false
    }
    
    private func errorHeight(_ height: CGFloat){
        UIView.animate(withDuration: 0.2, animations: {
            self.errorMessage.frame = CGRect(x: self.errorMessage.frame.minX, y: 215-(height/2), width: self.errorMessage.frame.width, height: height)
        })
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        Settings.shared.r = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

enum formState{
    case signin
    case register
    case business
}

class Trigger: UIButton{
    
    private let left: Bool
    private let original: CGRect
    private let label = UILabel()
    private let cheeky = UIButton()
    
    init(left: Bool, frame: CGRect) {
        self.left = left
        self.original = frame
        super .init(frame: frame)
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        layer.cornerRadius = 4.0
        
        label.frame = CGRect(x: 0, y: 0, width: 120, height: 30)
        label.font = Settings.shared.font
        label.textAlignment = .center
        label.textColor = .white
        addSubview(label)
        cheeky.frame = CGRect(x: 0, y: 0, width: 30, height: 120)
        addSubview(cheeky)
        
        if left{
            label.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        }
        else{
            label.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        }
        label.center = cheeky.center
    }
    
    override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        cheeky.addTarget(target, action: action, for: controlEvents)
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        label.text = title!
    }
    
    func hide(){
        UIView.animate(withDuration: 0.1, animations: {
            if self.left{
                self.transform = CGAffineTransform(translationX: -100, y: 0)
            }
            else{
                self.transform = CGAffineTransform(translationX: 100, y: 0)
            }
        })
    }
    
    func show(){
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform.identity
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum registerErrors{
    case passwordsDifferent
    case passwordBad
    case usernameTaken
    case usernameLength
    case emailInUse
    case emailInvalid
    case tooYoung
    case nameOffensive
    case fieldEmpty
    case failedSignIn
}
