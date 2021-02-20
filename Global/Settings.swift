//
//  Settings.swift
//  Kaktus
//
//  Created by Karl Cridland on 11/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseAnalytics

class Settings {
    
    public static let shared = Settings()
    var home: ViewController?
    
    private var uid: String?
    private var name = String()

    private let defaults = UserDefaults.standard
    var token: String?
    
    var friends = [String]()
    var blocked = [String]()
    
    var notifications = [UserNotif]()
    
    var distance = 20.0
    
    let fontName = "BanglaSangamMN-Bold"
    let font = UIFont(name: "BanglaSangamMN-Bold", size: 15)
    var upper_bound = CGFloat(0.0)
    var lower_bound = CGFloat(0.0)
    
    var profiles = [String: Profile]()
    var events = [String:[String:Event]]()
    
    var sb: SButton?
    var ca: ConfirmAction?
    var regForm: Register?
    var fullscreen: FullScreen?
    
    var latest: Date?
    var latestUID: String?
    
    var taken = [String]()
    
    var unread = [String]()
    
    var r: Register?
    
    private init(){
    }
    
    func signIn(_ email: String, _ password: String){
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            if let _ = error{
                if let register = Settings.shared.regForm{
                    print(register.throwError(.failedSignIn))
                }
            }
            else{
                guard let strongSelf = self else { return }
                
                if let auth = Auth.auth().currentUser{
                    strongSelf.uid = auth.uid
                    strongSelf.defaults.set(email.lowercased(), forKey: "email")
                    strongSelf.defaults.set(password, forKey: "password")
                    strongSelf.defaults.set(password.encrypt(), forKey: "enctypted")
                    Settings.shared.home?.viewDidLoad()
                    Firebase.shared.storeProfile(auth.uid, with: {}, completion: {})
                    if let token = strongSelf.token{
                        Firebase.shared.addToken(token)
                    }
                    strongSelf.regForm = nil
                }
            }
        }
    }
    
    func decrypt() -> String?{
        if let password = defaults.value(forKey: "enctypted") as? String{
            return password
        }
        return nil
    }
    
    func deleteAccount(){
        Firebase.shared.deleteUser()
    }
    
    func finishDelete(){
        let user = Auth.auth().currentUser
        user?.delete { error in
          if let error = error {
            print(error)
          } else {
            self.signOut(true)
          }
        }
    }
    
    func email() -> String?{
        if let email = defaults.value(forKey: "email") as? String{
            return email
        }
        return nil
    }
    
    func signOut(_ tokens: Bool){
        if tokens{
            if let token = self.token{
                Firebase.shared.removeToken(token)
            }
        }
        uid = nil
        defaults.set(nil, forKey: "email")
        defaults.set(nil, forKey: "password")
        do{
            try Auth.auth().signOut()
            Settings.shared.home?.viewDidLoad()
            UIApplication.shared.applicationIconBadgeNumber = 0
            events.removeAll()
            friends.removeAll()
            notifications.removeAll()
            profiles.removeAll()
        }
        catch{
//            print()
        }
    }
    
    func register(email: String, password: String, username: String, name: String){
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let _ = error{
                if let register = self.regForm{
                    if (register.throwError(.emailInUse)){
                        self.uid = nil
                        self.defaults.set(nil, forKey: "email")
                        self.defaults.set(nil, forKey: "password")
                    }
                }
            }
            else{
                self.signIn(email, password)
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
                    if self.isSignedIn(){
                        Firebase.shared.createUser(uid: Settings.shared.get().uid, username: username, name: name)
                        Settings.shared.home?.viewDidLoad()
                        timer.invalidate()
                        if let user = Auth.auth().currentUser {
                            let changeRequest = user.createProfileChangeRequest()
                            changeRequest.displayName = name
                            changeRequest.commitChanges { error in
                                if let _ = error{
                                }
                            }
                        }
                        self.taken.removeAll()
                    }
                })
            }
        }
    }
    
    func register(email: String, password: String, name: String, address: String){
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let _ = error{
                if let register = self.regForm{
                    if (register.throwError(.emailInUse)){
                        self.uid = nil
                        self.defaults.set(nil, forKey: "email")
                        self.defaults.set(nil, forKey: "password")
                    }
                }
            }
            else{
                self.signIn(email, password)
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
                    if self.isSignedIn(){
                        Firebase.shared.createUser(uid: Settings.shared.get().uid, title: name, address: address)
                        Settings.shared.home?.viewDidLoad()
                        timer.invalidate()
                        if let user = Auth.auth().currentUser {
                            let changeRequest = user.createProfileChangeRequest()
                            changeRequest.displayName = name
                            changeRequest.commitChanges { error in
                                if let _ = error{
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
    func resetPassword(_ reset: ResetPassword){
        Auth.auth().sendPasswordReset(withEmail: reset.emailForm.text(), completion: { error in
            if let _ = error{
                return
            }
            else{
                reset.emailSent()
            }
        })
    }
    
    func messageUpdate(){
        if let container = home?.container{
            for message in container.messenger.messages{
                message.backgroundColor = .clear
                if unread.contains(message.uid){
                    message.unread()
                }
            }
            if unread.count > 0{
                container.a.isHidden = false
                return
            }
            container.a.isHidden = true
        }
    }
    
    func set(_ n: String){
        if let user = Auth.auth().currentUser {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = n
            changeRequest.commitChanges { _ in
            }
        }
    }
    
    func lastSignIn() -> Cred?{
        if let email = defaults.value(forKey: "email") as? String{
            if let password = defaults.value(forKey: "password") as? String{
                return Cred(email: email, password: password)
            }
        }
        return nil
    }
    
    func isSignedIn() -> Bool{
        if let auth = Auth.auth().currentUser{
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
                self.tryPassword()
            })
            self.uid = auth.uid
            return true
        }
        return false
    }
    
    func tryPassword(){
        if let email = Auth.auth().currentUser?.email{
            if let password = defaults.value(forKey: "password") as? String{
                Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
                    guard let strongSelf = self else { return }
                    if let _ = error{
                        strongSelf.signOut(false)
                        return
                    }
                }
            }
        }
    }
    
    func get() -> User{
        if let uid = self.uid{
            return User(name: name, uid: uid)
        }
        signOut(false)
        return User(name: "", uid: "")
    }
    
    func getProfile(_ uid: String) -> Profile?{
        if let p = profiles[uid]{
            return p
        }
        return nil
    }
    
    func getUID(_ username: String) -> String?{
        for key in profiles.keys{
            if let profile = profiles[key]{
                if profile.username?.lowercased() == username.lowercased(){
                    return profile.uid
                }
            }
        }
        return nil
    }
    
    struct User{
        let name: String
        let uid: String
    }
    
    struct Cred{
        let email: String
        let password: String
    }
    
}
