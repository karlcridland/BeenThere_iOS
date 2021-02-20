//
//  Firebase.swift
//  Kaktus
//
//  Created by Karl Cridland on 11/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import CoreLocation

class Firebase {
    
    public static let shared = Firebase()
    private let picRef = Storage.storage().reference(forURL: "gs://beentheredonethat-karl.appspot.com/")

    var ref: DatabaseReference!
    let storageRef = Storage.storage().reference()
    
    private init(){
        ref = Database.database().reference()
    }
    
    func addToken(_ token: String){
        ref.child("users/notificationTokens/\(Settings.shared.get().uid)/\(token)/").setValue(true)
    }
    
    func removeToken(_ token: String){
        if Settings.shared.isSignedIn(){
            ref.child("users/notificationTokens/\(Settings.shared.get().uid)/\(token)/").removeValue()
        }
    }
    
    func countNotifications(){
        ref.child("notifications/new/\(Settings.shared.get().uid)/").observe(.value, with: {(snapshot) in
            var count = 0
            Settings.shared.unread.removeAll()
            for notification in snapshot.children.allObjects as! [DataSnapshot]{
                if let uid = notification.children.allObjects.first as? DataSnapshot{
                    if !Settings.shared.notifications.contains(where: {$0.uid == uid.key && $0.time == notification.key}){
                        self.storeProfile(uid.key, with: {}, completion: {})
                        
                        if let type = uid.children.allObjects.first as? DataSnapshot{
                            
                            switch notificationType(rawValue: type.key)!{
                            case .follow:
                                Settings.shared.notifications.append(UserNotif(uid: uid.key, time: notification.key, type: notificationType(rawValue: type.key)!, host: nil, event: nil))
                                count += 1
                                break
                            case .like:
                                if let host = type.children.allObjects.first as? DataSnapshot{
                                    if let event = host.value as? String{
                                        Settings.shared.notifications.append(UserNotif(uid: uid.key, time: notification.key, type: notificationType(rawValue: type.key)!, host: host.key, event: event))
                                        break
                                    }
                                }
                                let new = UserNotif(uid: uid.key, time: notification.key, type: notificationType(rawValue: type.key)!, host: nil, event: nil)
                                Settings.shared.notifications.append(new)
                                count += 1
                                break
                            case .message:
                                if !Settings.shared.unread.contains(uid.key){
                                    Settings.shared.unread.append(uid.key)
                                }
                                break
                            case .tag:
                                if let host = type.children.allObjects.first as? DataSnapshot{
                                    if let event = host.value as? String{
                                        Settings.shared.notifications.append(UserNotif(uid: uid.key, time: notification.key, type: notificationType(rawValue: type.key)!, host: host.key, event: event))
                                    }
                                }
                                count += 1
                                break
                            case .comment:
                                Settings.shared.notifications.append(UserNotif(uid: uid.key, time: notification.key, type: notificationType(rawValue: type.key)!, host: nil, event: nil))
                                count += 1
                                break
                            }
                        }
                    }
                }
            }
            Settings.shared.messageUpdate()
            if let banner = Settings.shared.home?.container?.banner{
                banner.updateNotifications(count)
                UIApplication.shared.applicationIconBadgeNumber = snapshot.all().count
            }
            if let page = Settings.shared.home?.container?.pages.last as? PageNotification{
                page.place()
            }
        })
        ref.child("notifications/read/\(Settings.shared.get().uid)/").observe(.value, with: {(snapshot) in
            for notification in snapshot.children.allObjects as! [DataSnapshot]{
                if let uid = notification.children.allObjects.first as? DataSnapshot{
                    if !Settings.shared.notifications.contains(where: {$0.uid == uid.key && $0.time == notification.key}){
                        self.storeProfile(uid.key, with: {}, completion: {})
                        if let type = uid.children.allObjects.first as? DataSnapshot{
                            
                            switch notificationType(rawValue: type.key)!{
                            case .follow:
                                let new = UserNotif(uid: uid.key, time: notification.key, type: notificationType(rawValue: type.key)!, host: nil, event: nil)
                                new.read = true
                                Settings.shared.notifications.append(new)
                                break
                            case .like:
                                if let host = type.children.allObjects.first as? DataSnapshot{
                                    if let event = host.value as? String{
                                        let new = UserNotif(uid: uid.key, time: notification.key, type: notificationType(rawValue: type.key)!, host: host.key, event: event)
                                        new.read = true
                                        Settings.shared.notifications.append(new)
                                        break
                                    }
                                }
                                let new = UserNotif(uid: uid.key, time: notification.key, type: notificationType(rawValue: type.key)!, host: nil, event: nil)
                                new.read = true
                                Settings.shared.notifications.append(new)
                                break
                            case .message:
                                break
                            case .tag:
                                if let host = type.children.allObjects.first as? DataSnapshot{
                                    if let event = host.value as? String{
                                        let new = UserNotif(uid: uid.key, time: notification.key, type: notificationType(rawValue: type.key)!, host: host.key, event: event)
                                        new.read = true
                                        Settings.shared.notifications.append(new)
                                    }
                                }
                                break
                            case .comment:
                                let new = UserNotif(uid: uid.key, time: notification.key, type: notificationType(rawValue: type.key)!, host: nil, event: nil)
                                new.read = true
                                Settings.shared.notifications.append(new)
                                break
                            }
                        }
                    }
                }
            }
            if let page = Settings.shared.home?.container?.pages.last as? PageNotification{
                page.place()
            }
        })
    }
    
    func getFollowing(){
        ref.child("users/range/\(Settings.shared.get().uid)/").observeSingleEvent(of: .value, with: {(snapshot) in
            if let value = snapshot.value as? Int{
                Settings.shared.distance = Double(value)
                self.magnifyPosts()
            }
        })
        
        ref.child("users/follows/following/\(Settings.shared.get().uid)").observe(.value, with: {(snapshot) in
            
            self.storeProfile(Settings.shared.get().uid, with: {}, completion: {})
            self.watchEvents(Settings.shared.get().uid)
            self.getLatest(Settings.shared.get().uid)
            
            for child in snapshot.children.allObjects as! [DataSnapshot]{
                self.storeProfile(child.key, with: {}, completion: {})
                self.watchEvents(child.key)
                Settings.shared.friends.append(child.key)
                self.getLatest(child.key)
            }
        })
    }
    
    private func getLatest(_ uid: String){
        self.ref.child("events/\(uid)/title").observe(.value, with: {(snapshot) in
            for event in snapshot.children.allObjects as! [DataSnapshot]{
                if let latest = Settings.shared.latest{
                    if let time = event.key.datetime(){
                        if latest < time{
                            Settings.shared.latest = time
                            Settings.shared.latestUID = uid
                        }
                    }
                }
            }
        })
    }
    
    func magnifyPosts(){
        func complete(uid: String, date: String, max: Int){
            let path = "magnify/\(Date().get(.year))/\(Date().get(.month))/\(Date().get(.day))/\(uid)/"
            self.ref.child(path).observeSingleEvent(of: .value, with: {(count) in
                if count.all().count < max{
                    self.ref.child("magnify/\(Date().get(.year))/\(Date().get(.month))/\(Date().get(.day))/\(uid)/\(Settings.shared.get().uid)/\(date)/").setValue(DateTime.shared.get())
                    self.ref.child("events/\(uid)/title/\(date)").observeSingleEvent(of: .value, with: {(final) in
                        if let value = final.value as? String{
                            self.addEvent(uid: uid, date: date, title: value, magnify: true)
                        }
                    })
                }
            })
        }
        
        ref.child("business/tier").observeSingleEvent(of: .value, with: {(snapshot) in
            for business in snapshot.all(){
                if let tier = business.value as? String{
                    self.ref.child("events/\(business.key)/magnify").observeSingleEvent(of: .value, with: { (ads) in
                        for ad in ads.all(){
                            self.ref.child("users/location/\(business.key)").observeSingleEvent(of: .value, with: { (coordinate) in
                                if tier == "silver" && coordinate.inRange(business.key){
                                    complete(uid: business.key, date: ad.key, max: 100)
                                }
                                if tier == "gold"{
                                    self.ref.child("users/magnifyRange/\(business.key)").observeSingleEvent(of: .value, with: {(range) in
                                        if let value = range.value as? Int{
                                            if coordinate.inRange(business.key, Double(value)){
                                                complete(uid: business.key, date: ad.key, max: 500)
                                            }
                                        }
                                        else{
                                            if coordinate.inRange(business.key, 20.0){
                                                complete(uid: business.key, date: ad.key, max: 500)
                                            }
                                        }
                                    })
                                }
                            })
                        }
                    })
                }
            }
        })
    }
    
    func watchEvents(_ uid: String){
        ref.child("events/\(uid)/title").observe(.value, with: {(snapshot) in
            for event in snapshot.children.allObjects as! [DataSnapshot]{
                if let title = event.value as? String{
                    self.addEvent(uid: uid, date: event.key, title: title)
                }
            }
        })
    }
    
    func notify(uid: String, host: String?, event: String?, type: notificationType){
        if uid == Settings.shared.get().uid{
            return
        }
        var link = ""
        let t = DateTime.shared.get()
        
        switch type {
        case .like:
            if let h = host{
                link = "notifications/new/\(uid)/\(t)/\(Settings.shared.get().uid)/\(type.rawValue)/\(h)"
                break
            }
            link = "notifications/new/\(uid)/\(t)/\(Settings.shared.get().uid)/\(type.rawValue)"
            break
        case .tag:
            link = "notifications/new/\(uid)/\(t)/\(Settings.shared.get().uid)/\(type.rawValue)/\(host!)"
            break
        case .follow:
            link = "notifications/new/\(uid)/\(t)/\(Settings.shared.get().uid)/\(type.rawValue)"
            break
        case .message:
            link = "notifications/new/\(uid)/\(t)/\(Settings.shared.get().uid)/\(type.rawValue)"
            break
        case .comment:
            link = "notifications/new/\(uid)/\(t)/\(Settings.shared.get().uid)/\(type.rawValue)"
            break
        }
        
        if event == nil{
            self.ref.child(link).setValue(true)
        }
        else{
            self.ref.child(link).setValue(event)
        }
    }
    
    func denotify(uid: String, host: String?, time: String, event: String?, type: notificationType){
        ref.child("notifications/read/\(Settings.shared.get().uid)/\(time)").observeSingleEvent(of: .value, with: {(snapshot) in
            if event == nil{
                self.ref.child("notifications/read/\(Settings.shared.get().uid)/\(time)/\(uid)/\(type.rawValue)/\(host ?? "")").setValue(true)
            }
            else{
                self.ref.child("notifications/read/\(Settings.shared.get().uid)/\(time)/\(uid)/\(type.rawValue)/\(host ?? "")").setValue(event)
            }
            self.ref.child("notifications/new/\(Settings.shared.get().uid)/\(time)/\(uid)").removeValue()
        })
    }
    
    func deleteNotification(uid: String, time: String){
        ref.child("notifications/read/\(Settings.shared.get().uid)/\(time)/\(uid)/").removeValue()
        ref.child("notifications/new/\(Settings.shared.get().uid)/\(time)/\(uid)/").removeValue()
    }
    
    func follow(_ uid: String){
        ref.child("users/follows/following/\(Settings.shared.get().uid)/\(uid)").setValue(DateTime.shared.get())
        ref.child("users/follows/followers/\(uid)/\(Settings.shared.get().uid)").setValue(DateTime.shared.get())
        notify(uid: uid, host: nil, event: nil, type: .follow)
    }
    
    func unfollow(_ uid: String){
        ref.child("users/follows/following/\(Settings.shared.get().uid)/\(uid)").removeValue()
        ref.child("users/follows/followers/\(uid)/\(Settings.shared.get().uid)").removeValue()
        Settings.shared.friends.removeAll(where: {$0 == uid})
    }
    
    func addEvent(uid: String, date: String, title: String, magnify: Bool){
        let event = Event(name: title, date: date.datetime()!, uid: uid)
        if magnify{
            event.magnified = true
        }
        if let usersEvents = Settings.shared.events[uid]{
            if !usersEvents.keys.contains(date){
                Settings.shared.events[uid]![date] = event
            }
            else{
                return
            }
        }
        else{
            Settings.shared.events[uid] = [date: event]
        }
        Settings.shared.home?.container?.feed.update()
    }
    
    func addEvent(uid: String, date: String, title: String){
        addEvent(uid: uid, date: date, title: title, magnify: false)
    }
    
    func getEvent(_ event: WidgetEvent){
        ref.child("events/\(event.event.uid)/caption/\(event.event.date.datetime())/").observeSingleEvent(of: .value, with: {(snapshot) in
            if let value = snapshot.value as? String{
                event.caption.text = value
                event.caption.addLinks()
                event.caption.font = UIFont(name: Settings.shared.fontName, size: 13)
                event.caption.isEditable = false
            }
        })
        ref.child("events/likes/\(event.event.uid)/\(event.event.date.datetime())/").observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.containsKey(Settings.shared.get().uid){
                event.liked = true
                event.refreshIcons()
            }
        })
        ref.child("events/\(event.event.uid)/social/comments/\(event.event.date.datetime())/").observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.containsKey(Settings.shared.get().uid){
                event.commented = true
                event.refreshIcons()
            }
        })
        ref.child("events/\(event.event.uid)/tags/\(event.event.date.datetime())/").observeSingleEvent(of: .value, with: {(snapshot) in
            for tagger in snapshot.children.allObjects as! [DataSnapshot]{
                for picture in tagger.children.allObjects as! [DataSnapshot]{
                    for tagged in picture.children.allObjects as! [DataSnapshot]{
                        if tagged.key == Settings.shared.get().uid{
                            event.isTagged = true
                            event.refreshIcons()
                        }
                    }
                }
            }
        })
        ref.child("events/\(event.event.uid)/images/\(event.event.date.datetime())").observe( .value, with: { (snapshot) in
            for user in snapshot.children.allObjects as! [DataSnapshot]{
                if user.key == Settings.shared.get().uid{
                    event.pictured = true
                    event.refreshIcons()
                }
                for image in user.children.allObjects as! [DataSnapshot]{
                    if !event.event.gallery.contains(where: {$0.uid == user.key && $0.date == image.key}){
                        let tn = Thumbnail(uid: user.key, date: image.key, event: event.event.date.datetime(), host: event.event.uid)
                        event.event.gallery.append(tn)
                        tn.widget = event
                        self.ref.child("events/\(event.event.uid)/imageLikes/\(event.event.date.datetime())/\(user.key)/\(image.key)").observe(.value, with: {(snapshot) in
                            for user in snapshot.children.allObjects as! [DataSnapshot]{
                                if user.key == Settings.shared.get().uid{
                                    tn.liked = true
                                }
                                tn.likes = snapshot.children.allObjects.count
                            }
                        })
                    }
                }
            }
            event.reload.stopAnimating()
        })
    }
    
    func getEvent(_ page: PageEvent){
        
        ref.child("events/\(page.uid)/images/\(page.date.datetime())").observe( .value, with: { (snapshot) in
            for user in snapshot.children.allObjects as! [DataSnapshot]{
                for image in user.children.allObjects as! [DataSnapshot]{
                    if !page.gallery.contains(where: {$0.uid == user.key && $0.date == image.key}){
                        let tn = Thumbnail(uid: user.key, date: image.key, event: page.date.datetime(), host: page.uid)
                        tn.page = page
                        page.gallery.append(tn)
                        self.ref.child("events/\(page.uid)/imageLikes/\(page.date.datetime())/\(user.key)/\(image.key)").observe(.value, with: {(snapshot) in
                            for user in snapshot.children.allObjects as! [DataSnapshot]{
                                if user.key == Settings.shared.get().uid{
                                    tn.liked = true
                                }
                                tn.likes = snapshot.children.allObjects.count
                            }
                        })
                    }
                }
            }
            page.display()
        })
    }
    
    func getEventTitle(_ uid: String,_ date: String, _ label: UILabel){
        ref.child("events/\(uid)/title/\(date)/").observeSingleEvent(of: .value, with: {(snapshot) in
            if let value = snapshot.value as? String{
                label.text = value
            }
        })
    }
    
    func getUpcoming(_ event: WidgetUpcoming){
        picRef.child("events/\(event.event.uid)/poster/\(event.event.date.datetime())").getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let _ = error {
            } else {
                event.poster.image = UIImage(data: data!)!
                event.hasLoaded = true
                event.load()
            }
        }
    }
    
    func storeProfile(_ uid: String, with incompletion: @escaping () -> Void?, completion: @escaping () -> Void?){
        if !Settings.shared.profiles.keys.contains(uid){
            ref.child("users/address/\(uid)").observeSingleEvent(of: .value, with: {(snapshot) in
                if let address = snapshot.value as? String{
                    
                    let geoCoder = CLGeocoder()
                    geoCoder.geocodeAddressString(address.replacingOccurrences(of: "\n", with: ", ")) { (placemarks, error) in
                        guard
                            let placemarks = placemarks,
                            let location = placemarks.first?.location
                        else {
                            self.ref.child("users/info/\(uid)").observeSingleEvent(of: .value, with: {(snapshot) in
                                if let name = snapshot.childSnapshot(forPath: "name").value as? String{
                                    Settings.shared.profiles[uid] = Profile(uid: uid, name: name, distance: -1)
                                }
                            })
                            completion()
                            return
                        }
                        if uid == Settings.shared.get().uid{
                            self.setLocation(location)
                        }
                        self.ref.child("users/info/\(uid)").observeSingleEvent(of: .value, with: {(snapshot) in
                            if let name = snapshot.childSnapshot(forPath: "name").value as? String{
                                if let loc = Location.shared.get(){
                                    Settings.shared.profiles[uid] = Profile(uid: uid, name: name, distance: location.coordinate.getDistance(loc))
                                    completion()
                                    return
                                }
                                else{
                                    Location.shared.locationManager?.requestWhenInUseAuthorization()
                                    if uid == Settings.shared.get().uid{
                                        Settings.shared.profiles[uid] = Profile(uid: uid, name: name, distance: 0.0)
                                        completion()
                                        return
                                    }
                                }
                            }
                            incompletion()
                        })
                    }
                }
                else{
                    self.ref.child("users/info/\(uid)").observeSingleEvent(of: .value, with: {(snapshot) in
                        if let name = snapshot.childSnapshot(forPath: "name").value as? String{
                            print(name)
                            if let username = snapshot.childSnapshot(forPath: "username").value as? String{
                                Settings.shared.profiles[uid] = Profile(uid: uid, name: name, username: username)
                                completion()
                                return
                            }
                        }
                        incompletion()
                    })
                }
                
            })
        }
    }
    
    func setLocation(_ location: CLLocation){
        ref.child("users/location/\(Settings.shared.get().uid)/latitude").setValue(location.coordinate.latitude)
        ref.child("users/location/\(Settings.shared.get().uid)/longitude").setValue(location.coordinate.longitude)
    }
    
    func storeProfileFromUsername(_ username: String, _ open: Bool){
        ref.child("users/info").observeSingleEvent(of: .value, with: {(snapshot) in
            for user in snapshot.children.allObjects as! [DataSnapshot]{
                if let child = user.childSnapshot(forPath: "username").value as? String{
                    if child == username{
                        self.storeProfile(user.key, with: {}, completion: {})
                        break
                    }
                }
            }
            if open{
                Settings.shared.home?.container?.append(PageError(title: username))
            }
        })
    }
    
    func getProfileImage(_ profile: Profile){
        if let _ = Settings.shared.getProfile(profile.uid)?.image{
            return
        }
        picRef.child("users/display/\(profile.uid)").getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let _ = error {
                profile.hasImage = false
            } else {
                profile.image = UIImage(data: data!)!
            }
        }
        if profile.uid == Settings.shared.get().uid{
            if let location = Location.shared.get(){
                self.setLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
            }
        }
    }
    
    func getPage(_ uid: String){
        var valid = true
        if let container = Settings.shared.home?.container{
            if container.pages.last is PageProfile{
                if (container.pages.last as! PageProfile).uid == uid{
                    valid = false
                }
            }
            if valid{
                if let profile = Settings.shared.getProfile(uid){
                    if profile.isBusiness(){
                        ref.child("users/address/\(uid)").observeSingleEvent(of: .value, with: {(snapshot) in
                            if let address = snapshot.value as? String{
                                let page = PageBusiness(uid: uid, title: profile.name, address: address)
                                container.append(page)
                            }
                            else{
                                let page = PageBusiness(uid: uid, title: profile.name, address: "")
                                container.append(page)
                            }
                        })
                    }
                    else{
                        ref.child("users/bio/\(uid)").observeSingleEvent(of: .value, with: {(snapshot) in
                            if let bio = snapshot.value as? String{
                                let page = PagePersonal(uid: uid, title: profile.username!, name: profile.name, bio: bio)
                                container.append(page)
                            }
                            else{
                                let page = PagePersonal(uid: uid, title: profile.username!, name: profile.name, bio: "")
                                container.append(page)
                            }
                        })
                    }
                }
                else{
                    storeProfile(uid, with: {}, completion: {})
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
                        self.getPage(uid)
                    })
                }
            }
        }
    }
    
    func getEventPage(_ uid: String, _ event: String){
        Settings.shared.home?.container?.append(PageEvent(date: event, uid: uid, event: nil))
    }
    
    func getPersonal(_ banner: PageBanner){
        ref.child("users/follows/following/\(banner.page.uid)").observe(.value, with: {(snapshot) in
            banner.following.update(snapshot.children.allObjects.count)
            for value in snapshot.children.allObjects as! [DataSnapshot]{
                self.storeProfile(value.key, with: {}, completion: {})
            }
        })
        ref.child("users/follows/followers/\(banner.page.uid)").observe(.value, with: {(snapshot) in
            banner.followers.update(snapshot.children.allObjects.count)
            for value in snapshot.children.allObjects as! [DataSnapshot]{
                self.storeProfile(value.key, with: {}, completion: {})
            }
        })
    }

    func createUser(uid: String, username: String, name: String){
        ref.child("users/info/\(uid)/username").setValue(username)
        ref.child("users/info/\(uid)/name").setValue(name)
        ref.child("users/bio/\(uid)/").setValue("")
    }

    func createUser(uid: String, title: String, address: String){
        ref.child("users/info/\(uid)/name").setValue(title)
        ref.child("users/address/\(uid)/").setValue(address)
    }
    
    func createEvent(date: String, title: String, caption: String, poster: UIImage?){
        let uid = Settings.shared.get().uid
        ref.child("events/\(uid)/title/\(date)/").setValue(title)
        ref.child("events/\(uid)/caption/\(date)/").setValue(caption)
        if let image = poster{
            let compressed = image.compress()
            let data = compressed.jpegData(compressionQuality: 0.9)! as NSData
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            if (data.count < Int(1024 * 1024)){
                storageRef.child("events/\(uid)/poster/\(date)").putData(data as Data, metadata: metaData)
            }
        }
    }
    
    func block(_ uid: String){
        ref.child("users/follows/blocked/\(Settings.shared.get().uid)/\(uid)").setValue(DateTime.shared.get())
    }
    
    func unblock(_ uid: String){
        ref.child("users/follows/blocked/\(Settings.shared.get().uid)/\(uid)").removeValue()
    }
    
    func report(_ uid: String){
        
    }
    
    func deleteEvent(_ event: WidgetEvent) -> Void{
        for child in ["caption","title","images","imageLikes","imageCaptions","tags","social/likes","social/comments"]{
            ref.child("events/\(Settings.shared.get().uid)/\(child)/\(event.event.date.datetime())").removeValue()
        }
        Settings.shared.events[event.event.uid]![event.event.date.datetime()] = nil
        if let feed = Settings.shared.home?.container?.feed{
            feed.remove(event.event)
        }
    }
    
    func search(_ page: PageSearch, _ query: String){
        if page.snapshot == nil{
            ref.child("users/info/").observeSingleEvent(of: .value, with: {(snapshot) in
                self.ref.child("users/address/").observeSingleEvent(of: .value, with: {(addresses) in
                    self.ref.child("menus/drinks/").observeSingleEvent(of: .value, with: {(drinks) in
                        page.snapshot = snapshot
                        page.addresses = addresses
                        page.drinks = drinks
                        page.refine(query)
                    })
                })
            })
        }
        else{
            page.refine(query)
        }
    }
    
    func upload(_ page: PageUpload){
        let time = DateTime.shared.get()
        let uid = page.event!.event.uid
        let event = page.event!.event.date.datetime()
        let tags = page.tagButton.tags
        
        let compressed = (page.button.imageView?.image!)!.compress()
        let data = compressed.jpegData(compressionQuality: 0.9)! as NSData
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        if (data.count < Int(1024 * 1024)){
            storageRef.child("events/\(uid)/\(event)/\(Settings.shared.get().uid)/\(time)/").putData(data as Data, metadata: metaData) { (data, error) in
                if let _ = error{
                }
                else{
                    self.ref.child("events/\(uid)/images/\(event)/\(Settings.shared.get().uid)/\(time)").setValue(true)
                    self.ref.child("events/\(uid)/imageCaptions/\(event)/\(Settings.shared.get().uid)/\(time)").setValue(page.caption.text())
                    for tag in tags{
                        self.tagUser(host: uid, event: event, picture: time, tag: tag)
                    }
                    page.event!.pictured = true
                    page.event!.refreshIcons()
                }
                Settings.shared.home?.container?.remove()
            }
        }
        else{
            page.stopLoading()
        }
    }
    
    func tagUser(host: String, event: String, picture: String, tag: Tagger){
        ref.child("events/\(host)/tags/\(event)/\(Settings.shared.get().uid)/\(picture)/\(tag.uid)/x").setValue(tag.getX()!)
        ref.child("events/\(host)/tags/\(event)/\(Settings.shared.get().uid)/\(picture)/\(tag.uid)/y").setValue(tag.getY()!)
        ref.child("tags/\(tag.uid)/\(host)/\(event)/\(Settings.shared.get().uid)/\(picture)").setValue(false)
        notify(uid: tag.uid, host: host, event: event, type: .tag)
    }
    
    func loadThumbnail(thumbnail: Thumbnail, event: String, host: String){
        picRef.child("events/\(host)/\(event)/\(thumbnail.uid)/\(thumbnail.date)/").getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let _ = error {
            } else {
                thumbnail.image = UIImage(data: data!)!
                thumbnail.isLoaded = true
                thumbnail.prompt()
            }
        }
    }
    
    func notBlocked(_ uid: String, with completion: @escaping () -> Void){
        ref.child("users/follows/blocked/\(uid)").observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.containsKey(Settings.shared.get().uid){
                completion()
            }
        })
    }
    
    func likePost(_ event: WidgetEvent){
        notBlocked(event.event.uid, with: {
            self.ref.child("events/likes/\(event.event.uid)/\(event.event.date.datetime())/\(Settings.shared.get().uid)").setValue(DateTime.shared.get())
            self.notify(uid: event.event.uid, host: nil, event: event.event.date.datetime(), type: .like)
        })
    }
    
    func likePhoto(_ thumbnail: Thumbnail){
        self.likePhoto(thumbnail.host, event: thumbnail.event, uid: thumbnail.uid, picture: thumbnail.date)
    }
    
    func likePhoto(_ host: String, event: String, uid: String, picture: String){
        notBlocked(host, with: {
            self.notBlocked(uid, with: {
                self.ref.child("events/\(host)/imageLikes/\(event)/\(uid)/\(picture)/\(Settings.shared.get().uid)").setValue(DateTime.shared.get())
                self.notify(uid: uid, host: host, event: event, type: .like)
            })
        })
    }
    
    func getTagged(_ page: PagePersonal){
        ref.child("tags/\(page.uid)/").observe( .value, with: {(snapshot) in
            for host in snapshot.children.allObjects as! [DataSnapshot]{
                for event in host.children.allObjects as! [DataSnapshot]{
                    self.ref.child("events/\(host.key)/title/\(event.key)").observe(.value, with: {(snapshot) in
                        if snapshot.exists(){
                            for tagger in event.children.allObjects as! [DataSnapshot]{
                                for picture in tagger.children.allObjects as! [DataSnapshot]{
                                    if let valid = picture.value as? Bool{
                                        if valid{
                                            let image = TaggedImage(uid: tagger.key, host: host.key, event: event.key, picture: picture.key, page: page)
                                            let year = event.key.datetime()!.get(.year)
                                            let month = event.key.datetime()!.get(.month)
                                            if let a = page.pictures[year]?[month]{
                                                if !a.contains(where: {$0.event == event.key && $0.host == host.key && $0.picture == picture.key}){
                                                    page.pictures[year]![month]!.append(image)
                                                }
                                            }
                                            else{
                                                page.pictures[year] = [month:[image]]
                                            }
                                        }
                                    }
                                    page.sortPictures()
                                }
                            }
                        }
                    })
                }
            }
        })
    }
    
    func getTagged(_ page: PageSortTagged){
        ref.child("tags/\(Settings.shared.get().uid)/").observe( .value, with: {(snapshot) in
            for host in snapshot.children.allObjects as! [DataSnapshot]{
                for event in host.children.allObjects as! [DataSnapshot]{
                    for tagger in event.children.allObjects as! [DataSnapshot]{
                        for picture in tagger.children.allObjects as! [DataSnapshot]{
                            if let valid = picture.value as? Bool{
                                if !valid{
                                    let image = TaggedImage(uid: tagger.key, host: host.key, event: event.key, picture: picture.key, page: page)
                                    let year = event.key.datetime()!.get(.year)
                                    let month = event.key.datetime()!.get(.month)
                                    if let a = page.pictures[year]?[month]{
                                        if !a.contains(where: {$0.event == event.key && $0.host == host.key}){
                                            page.pictures[year]![month]!.append(image)
                                        }
                                        else{
                                            page.pictures[year]![month] = [image]
                                        }
                                    }
                                    else{
                                        page.pictures[year] = [month:[image]]
                                    }
                                }
                            }
                            page.sortPictures()
                        }
                    }
                }
            }
        })
    }
    
    func getTaggedImage(_ image: TaggedImage){
        picRef.child("events/\(image.host)/\(image.event)/\(image.uid)/\(image.picture)/").getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let _ = error {
            } else {
                image.image = UIImage(data: data!)!
                image.hasLoaded = true
                image.prompt()
            }
        }
    }
    
    func tagConfirmed(_ image: TaggedImage){
        ref.child("tags/\(Settings.shared.get().uid)/\(image.host)/\(image.event)/\(image.uid)/\(image.picture)").setValue(true)
    }
    
    func tagDenied(_ image: TaggedImage){
        ref.child("tags/\(Settings.shared.get().uid)/\(image.host)/\(image.event)/\(image.uid)/\(image.picture)").removeValue()
        ref.child("events/\(image.host)/tags/\(image.event)/\(image.uid)/\(image.picture)/\(Settings.shared.get().uid)/").removeValue()
    }
    
    func getTagged(_ page: PageTaggedList){
        ref.child("events/\(page.event.event.uid)/tags/\(page.event.event.date.datetime())/").observeSingleEvent(of: .value, with: {(snapshot) in
            for tagger in snapshot.children.allObjects as! [DataSnapshot]{
                for picture in tagger.children.allObjects as! [DataSnapshot]{
                    for tagged in picture.children.allObjects as! [DataSnapshot]{
                        if let profile = Settings.shared.getProfile(tagged.key){
                            if !page.results.contains(where: {$0.uid == profile.uid}){
                                page.results.append(profile)
                            }
                        }
                        else{
                            self.storeProfile(tagged.key, with: {}, completion: {})
                        }
                    }
                }
            }
            page.display()
        })
    }
    
    func getFollowPage(_ page: PageFollowList){
        ref.child("users/follows/followers/\(page.uid)").observeSingleEvent(of: .value, with: {(snapshot) in
            page.full = snapshot.children.allObjects.count
            for user in snapshot.children.allObjects as![DataSnapshot]{
                if !page.results.contains(where: {$0.uid == user.key}){
                    if let profile = Settings.shared.getProfile(user.key){
                        page.results.append(profile)
                    }
                    else{
                        self.storeProfile(user.key, with: {}, completion: {})
                    }
                }
            }
            page.display()
        })
        ref.child("users/follows/following/\(page.uid)").observeSingleEvent(of: .value, with: {(snapshot) in
            page.full2 = snapshot.children.allObjects.count
            for user in snapshot.children.allObjects as![DataSnapshot]{
                if !page.results2.contains(where: {$0.uid == user.key}){
                    if let profile = Settings.shared.getProfile(user.key){
                        page.results2.append(profile)
                    }
                    else{
                        self.storeProfile(user.key, with: {}, completion: {})
                    }
                }
            }
            page.display()
        })
    }
    
    func updateBio(_ text: String){
        ref.child("users/bio/\(Settings.shared.get().uid)").setValue(text)
    }
    
    func updateProfilePic(_ image: UIImage){
        let compressed = image.compress()
        let data = compressed.jpegData(compressionQuality: 0.9)! as NSData
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        if (data.count < Int(1024 * 1024)){
            storageRef.child("users/display/\(Settings.shared.get().uid)/").putData(data as Data, metadata: metaData)
            if let profile = Settings.shared.getProfile(Settings.shared.get().uid){
                profile.image = image
            }
        }
    }
    
    func uploadTAL(_ image: UIImage, _ tal: TALScrollView?){
        let compressed = image.compress()
        let data = compressed.jpegData(compressionQuality: 0.9)! as NSData
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        if (data.count < Int(1024 * 1024)){
            let time = DateTime.shared.get()
            tal?.append(image, time)
            storageRef.child("takealook/\(Settings.shared.get().uid)/\(time)").putData(data as Data, metadata: metaData)
            ref.child("takealook/\(Settings.shared.get().uid)/").observeSingleEvent(of: .value, with: {(snapshot) in
                var max = -1
                for pic in snapshot.all(){
                    if let a = pic.value as? Int{
                        if a > max{
                            max = a
                        }
                    }
                }
                self.ref.child("takealook/\(Settings.shared.get().uid)/\(time)").setValue(max+1)
            })
        }
    }
    
    func updateTAL(_ tal: TALScrollView){
        if let uid = tal.uid{
            ref.child("takealook/\(uid)/").observeSingleEvent(of: .value, with: {(snapshot) in
                for pic in snapshot.all(){
                    if let position = pic.value as? Int{
                        if let a = tal.images.first(where: {$0.ref == pic.key}){
                            a.position = position
                            a.frame = a.location()
                        }
                        else{
                            if tal.deleted.contains(pic.key){
                                return
                            }
                            let new = TALImage(position: position, ref: pic.key, uid: uid, tal: tal)
                            tal.images.append(new)
                            tal.addSubview(new)
                            if uid == Settings.shared.get().uid{
                                tal.addSubview([new.fs,new.delete,new.left,new.right])
                            }
                            else{
                                tal.addSubview(new.fs)
                            }
                        }
                    }
                }
                tal.update()
            })
        }
    }
    
    func openYet(_ label: UILabel, _ uid: String, _ light: UIView){
        let day = getDayOfWeek()
        print(day)
        ref.child("business/openings/\(day)/open/\(uid)").observeSingleEvent(of: .value, with: {(openVal) in
            self.ref.child("business/openings/\(day)/close/\(uid)").observeSingleEvent(of: .value, with: {(closeVal) in
                light.isHidden = false
                func updateTitle(_ open: String, _ close: String){
                    if self.before(time: open, close: false){
                        label.text = "   opens at \(open)"
                        light.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                        return
                    }
                    else if self.before(time: close, close: true){
                        label.text = "   open until \(close)"
                        light.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
                        return
                    }
                    label.text = "   opens tomorrow at \(open)"
                    light.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                }
                
                if let open = openVal.value as? String{
                    if let close = closeVal.value as? String{
                        updateTitle(open, close)
                    }
                    else{
                        updateTitle(open, "00:00")
                    }
                }
                else{
                    if let close = closeVal.value as? String{
                        updateTitle("11:00", close)
                    }
                    else{
                        updateTitle("11:00", "00:00")
                    }
                }
            })
        })
    }
    
    func before(time: String, close: Bool) -> Bool{
        let split = time.split(separator: ":")
        if split.count == 2{
            if var hour = Int(split[0]){
                if let minute = Int(split[1]){
                    if hour < 6 && close{
                        hour = 24
                    }
                    let h = Date().get(.hour)
                    let m = Date().get(.minute)
                    if h < hour{
                        return true
                    }
                    
                    if h == hour{
                        if m < minute{
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
    func getDayOfWeek() -> String {
        
        let y = String(Date().get(.year))
        let m = String(Date().get(.month))
        let d = String(Date().get(.day)-1)
        
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: "\(y)-\(m)-\(d)") else { return "" }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return ["monday","tuesday","wednesday","thursday","friday","saturday","sunday"][weekDay-1]
    }
    
    func getTALImage(_ talImage: TALImage){
        picRef.child("takealook/\(talImage.uid)/\(talImage.ref)").getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let _ = error {
            } else {
                talImage.image = UIImage(data: data!)!
            }
        }
    }
    
    func deleteTALImage(_ talImage: TALImage){
        ref.child("takealook/\(Settings.shared.get().uid)/\(talImage.ref)").setValue(nil)
        picRef.child("takealook/\(talImage.uid)/\(talImage.ref)").delete { _ in
            
        }
    }
    
    func updateTAL(_ talImage: TALImage){
        ref.child("takealook/\(Settings.shared.get().uid)/\(talImage.ref)").setValue(talImage.position)
    }
    
    func usernameDownload(){
        ref.child("users/info").observe(.value, with: {(snapshot) in
            for user in snapshot.children.allObjects as! [DataSnapshot]{
                if let username = user.childSnapshot(forPath: "username").value as? String{
                    if !Settings.shared.taken.contains(username){
                        Settings.shared.taken.append(username.lowercased())
                    }
                }
            }
        })
    }
    
    func fullscreenExtra(_ fullscreenInfo: FullScreenInfo){
        let info = fullscreenInfo.fullscreen
        if let size = info.image?.size{
            ref.child("events/\(info.host)/tags/\(info.event)/\(info.uid!)/\(info.pic!)").observeSingleEvent(of: .value, with: {(snapshot) in
                for user in snapshot.children.allObjects as! [DataSnapshot]{
                    self.storeProfile(user.key, with: {}, completion: {})
                    if user.key == Settings.shared.get().uid{
                        fullscreenInfo.isTagged = true
                    }
                    let height = UIScreen.main.bounds.width/(size.width/size.height)
                    let gap = (UIScreen.main.bounds.height-height)/2
                    if let x = user.childSnapshot(forPath: "x").value as? Double{
                        if let y = user.childSnapshot(forPath: "y").value as? Double{
                            fullscreenInfo.tags.append(Tagger(point: CGPoint(x: (UIScreen.main.bounds.width*CGFloat(x)/100), y: (height*CGFloat(y)/100)+gap), uid: user.key, new: false))
                        }
                    }
                }
                fullscreenInfo.update()
            })
        }
        ref.child("events/\(info.host)/imageLikes/\(info.event)/\(info.uid!)/\(info.pic!)/").observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.containsUser(){
                fullscreenInfo.hasLiked = true
                fullscreenInfo.update()
            }
        })
        ref.child("events/\(info.host)/imageCaptions/\(info.event)/\(info.uid!)/\(info.pic!)/").observeSingleEvent(of: .value, with: {(snapshot) in
            if let value = snapshot.value as? String{
                fullscreenInfo.caption.text = value
                fullscreenInfo.update()
            }
        })
    }
    
    func getBusinessInfo(_ scroll: BusinessScroll){
        
    }
    
    func getMenus(_ page: PageFoodMenu){
        ref.child("menus/food/\(page.uid)").observeSingleEvent(of: .value, with: {(snapshot) in
            for menu in snapshot.children.allObjects as! [DataSnapshot]{
                if let new = menu.getMenu(page) as? MenuEdit{
                    page.menus.append(new)
                }
            }
            page.display()
        })
    }
    
    func getMenus(_ page: PageEditMenu){
        ref.child("menus/food/\(Settings.shared.get().uid)").observeSingleEvent(of: .value, with: {(snapshot) in
            for menu in snapshot.children.allObjects as! [DataSnapshot]{
                if let new = menu.getMenu(page) as? MenuEdit{
                    page.menus.append(new)
                }
            }
            page.display()
        })
    }
    
    func saveMenuTitle(title: String, path: [Int]){
        var a = "menus/food/\(Settings.shared.get().uid)/"
        for level in path{
            a += "\(level)/"
        }
        ref.child("\(a)title").setValue(title)
    }
    
    func saveMenuItem(title: String, subtitle: String, price: Int, path: [Int]){
        var a = "menus/food/\(Settings.shared.get().uid)/"
        for level in path{
            a += "\(level)/"
        }
        ref.child("\(a)title").setValue(title)
        ref.child("\(a)subtitle").setValue(subtitle)
        ref.child("\(a)price").setValue(price)
    }
    
    func saveMenuItem(title: String, price: Int, path: [Int]){
        var a = "menus/food/\(Settings.shared.get().uid)/"
        for level in path{
            a += "\(level)/"
        }
        ref.child("\(a)title").setValue(title)
        ref.child("\(a)price").setValue(price)
    }
    
    func deleteMenu(_ path: [Int]){
        var a = "menus/food/\(Settings.shared.get().uid)/"
        for level in path{
            a += "\(level)/"
        }
        ref.child("\(a)").setValue(nil)
    }
    
    func updateDietary(_ path: [Int], _ code: String){
        var a = "menus/food/\(Settings.shared.get().uid)/"
        for level in path{
            a += "\(level)/"
        }
        if code == "00000"{
            ref.child("\(a)dietary").setValue(nil)
            return
        }
        ref.child("\(a)dietary").setValue(code)
    }
    
    func removeMenuItems(_ menu: MenuEdit){
        var a = "menus/food/\(Settings.shared.get().uid)/"

        if let p = menu.page{
            for level in p.path{
                a += "\(level)/"
            }
            ref.child("\(a)").observeSingleEvent(of: .value, with: {(snapshot) in
                for child in snapshot.children.allObjects as! [DataSnapshot]{
                    if child.key != "title"{
                        self.ref.child("\(a)\(child.key)").removeValue()
                    }
                }
                menu.affirm()
            })
        }
    }
    
    func getDrinkList(_ page: PageEditDrinks){
        ref.child("drinks").observeSingleEvent(of: .value, with: {(snapshot) in
            for sort in snapshot.all(){
                for type in sort.all(){
                    for drink in type.all(){
                        let new = Drink(name: drink.key, sort: sort.key, type: type.key)
                        if let _ = page.drinks[sort.key]?[type.key]{
                            page.drinks[sort.key]![type.key]![drink.key] = new
                        }
                        else{
                            if let _ = page.drinks[sort.key]{
                                page.drinks[sort.key]![type.key] = [drink.key: new]
                            }
                            else{
                                page.drinks[sort.key] = [type.key: [drink.key: new]]
                            }
                        }
                    }
                }
            }
            self.getDrinkPrices(page)
        })
    }
    
    func submitMissingDrinkReport(_ report: String){
        ref.child("reports/drinks/missing/\(Settings.shared.get().uid)/\(DateTime.shared.get())").setValue(report)
    }
    
    func getDrinkPrices(_ page: PageEditDrinks){
        ref.child("menus/drinks/\(Settings.shared.get().uid)/").observeSingleEvent(of: .value, with: {(snapshot) in
            for sort in snapshot.all(){
                for type in sort.all(){
                    for drink in type.all(){
                        if let price = drink.value as? Int{
                            if let d = page.drinks[sort.key]?[type.key]?[drink.key]{
                                d.price = price
                                d.inStock = true
                                d.update()
                            }
                        }
                    }
                }
            }
            page.display(nil)
        })
    }
    
    func getDrinkPrices(_ page: PageDrinkMenu){
        ref.child("menus/drinks/\(page.uid)/").observeSingleEvent(of: .value, with: {(snapshot) in
            for sort in snapshot.all(){
                for type in sort.all(){
                    for drink in type.all(){
                        if let price = drink.value as? Int{
                            let new = Drink(name: drink.key, sort: sort.key, type: type.key)
                            new.price = price
                            new.inStock = true
                            new.update()
                            new.edit = false
                            if let _ = page.drinks[sort.key]?[type.key]{
                                page.drinks[sort.key]![type.key]![drink.key] = new
                            }
                            else{
                                if let _ = page.drinks[sort.key]{
                                    page.drinks[sort.key]![type.key] = [drink.key: new]
                                }
                                else{
                                    page.drinks[sort.key] = [type.key: [drink.key: new]]
                                }
                            }
                        }
                    }
                }
            }
            page.display()
        })
    }
    
    func updateDrinkPrice(_ drink: Drink){
        if let price = drink.price{
            if price > 0{
                ref.child("menus/drinks/\(Settings.shared.get().uid)/\(drink.sort)/\(drink.type)/\(drink.name)").setValue(price)
                return
            }
        }
        ref.child("menus/drinks/\(Settings.shared.get().uid)/\(drink.sort)/\(drink.type)/\(drink.name)").setValue(nil)
    }
    
    func getBusinessSettings(_ page: PageEditBusiness){
        ref.child("business/openings/").observeSingleEvent(of: .value, with: {(snapshot) in
            var i = 0
            for child in ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]{
                if let open = snapshot.childSnapshot(forPath: "\(child)/open/\(Settings.shared.get().uid)/").value as? String{
                    page.get(i).update(open)
                }
                else{
                    page.get(i).update("11:00")
                }
                i += 1
                if let close = snapshot.childSnapshot(forPath: "\(child)/close/\(Settings.shared.get().uid)/").value as? String{
                    page.get(i).update(close)
                }
                else{
                    page.get(i).update("00:00")
                }
                i += 1
            }
        })
    }
    
    func updateOpening(_ day: String, ooc: String, _ time: String){
        ref.child("business/openings/\(day)/\(ooc)/\(Settings.shared.get().uid)/").setValue(time)
    }
    
    func getBusinessOpenings(_ page: PageBusiOpen){
        ref.child("business/openings/").observeSingleEvent(of: .value, with: {(snapshot) in
            var i = 0
            for child in ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]{
                if let open = snapshot.childSnapshot(forPath: "\(child)/open/\(Settings.shared.get().uid)/").value as? String{
                    page.hours.append(open)
                }
                else{
                    page.hours.append("11:00")
                }
                i += 1
                if let close = snapshot.childSnapshot(forPath: "\(child)/close/\(Settings.shared.get().uid)/").value as? String{
                    page.hours.append(close)
                }
                else{
                    page.hours.append("00:00")
                }
                i += 1
            }
            page.display()
        })
    }
    
    func getAddress(_ page: PageAddress){
        ref.child("users/address/\(page.uid)").observeSingleEvent(of: .value, with: {(snapshot) in
            if let address = snapshot.value as? String{
                page.address = address
            }
            page.update()
        })
    }
    
    func getAddress(_ page: PageEditBasic){
        ref.child("users/address/\(Settings.shared.get().uid)").observeSingleEvent(of: .value, with: {(snapshot) in
            if let address = snapshot.value as? String{
                page.address.input.text = address
                page.address.denullify()
                page.address.textChanged()
            }
        })
    }
    
    func getEvents(_ page: PageBusiness){
        ref.child("events/\(page.uid)/title").observe(.value, with: {(snapshot) in
            for event in snapshot.all(){
                if let title = event.value as? String{
                    let event = Event(name: title, date: event.key.datetime()!, uid: page.uid)
                    page.container.events.append(event)
                }
            }
            page.container.update()
        })
    }
    
    func updateTier(_ tier: TierCategory){
        ref.child("business/tier/\(Settings.shared.get().uid)/").setValue(tier.rawValue)
    }
    
    func logTierPurchase(_ tier: TierCategory, _ transaction: String){
        ref.child("reports/purchases/membership/\(Settings.shared.get().uid)/\(DateTime.shared.get())/tier").setValue(tier.rawValue)
        ref.child("reports/purchases/membership/\(Settings.shared.get().uid)/\(DateTime.shared.get())/reference").setValue(transaction)
    }
    
    func updateRange(_ range: Int){
        ref.child("users/range/\(Settings.shared.get().uid)/").setValue(range)
    }
    
    func getRange(_ page: PageSettings){
        ref.child("users/range/\(Settings.shared.get().uid)/").observeSingleEvent(of: .value, with: {(snapshot) in
            if let value = snapshot.value as? Int{
                page.slideStart(value)
            }
            else{
                page.slideStart(Int(Settings.shared.distance))
            }
        })
    }
    
    func updateMagnifyRange(_ range: Int){
        ref.child("users/magnifyRange/\(Settings.shared.get().uid)/").setValue(range)
    }
    
    func getRange(_ page: PageMagnifyManage){
        ref.child("users/magnifyRange/\(Settings.shared.get().uid)/").observeSingleEvent(of: .value, with: {(snapshot) in
            if let value = snapshot.value as? Int{
                page.slideStart(value)
            }
            else{
                page.slideStart(Int(Settings.shared.distance))
            }
        })
    }
    
    func getTier(_ page: PageMagnify){
        ref.child("business/tier/\(Settings.shared.get().uid)/").observeSingleEvent(of: .value, with: {(snapshot) in
            if let value = snapshot.value as? String{
                if let tier = TierCategory(rawValue: value){
                    page.setTier(tier)
                }
            }
        })
    }
    
    func updateInfo(_ text: String){
        switch text {
        case " ":
            ref.child("users/extrainfo/\(Settings.shared.get().uid)").setValue(nil)
            break
        default:
            ref.child("users/extrainfo/\(Settings.shared.get().uid)").setValue(text)
            break
        }
    }
    
    func getInfo(_ page: PageEditInfo){
        ref.child("users/extrainfo/\(Settings.shared.get().uid)").observeSingleEvent(of: .value, with: {(snapshot) in
            if let value = snapshot.value as? String{
                page.box.text = value
            }
        })
    }
    
    func getInfo(_ page: PageExtraInfo){
        ref.child("users/extrainfo/\(page.uid)").observeSingleEvent(of: .value, with: {(snapshot) in
            if let value = snapshot.value as? String{
                page.box.text = value
            }
        })
    }
    
    func getFeaturedEvents(_ page: PageMagnifyManage){
        ref.child("events/\(Settings.shared.get().uid)/title").observeSingleEvent(of: .value, with: {(snapshot) in
            var base = 80
            if page.tier == .gold{
                base = 200
            }
            var i = 0
            for event in snapshot.all(){
                if let title = event.value as? String{
                    let e = EventClick(title: title, date: event.key, position: i, base: CGFloat(base))
                    page.events.append(e)
                    i += 1
                }
            }
            page.display()
        })
    }
    
    func featureEvent(_ button: EventClick, _ display: Bool){
        if display{
            ref.child("events/\(Settings.shared.get().uid)/magnify/\(button.date)").setValue(true)
        }
        else{
            ref.child("events/\(Settings.shared.get().uid)/magnify/\(button.date)").removeValue()
        }
    }
    
    func isFeatured(_ button: EventClick){
        ref.child("events/\(Settings.shared.get().uid)/magnify/\(button.date)").observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.exists(){
                button.click.click()
                button.clickClick()
            }
        })
    }
    
    func getComments(_ page: PageComments){
        let event = page.event.event
        ref.child("events/\(event.uid)/social/comments/\(event.date.datetime())").observeSingleEvent(of: .value, with: {(snapshot) in
            for comment in snapshot.all(){
                for date in comment.all(){
                    if let value = date.value as? String{
                        let new = Comment(uid: comment.key, comment: value, date: date.key)
                        page.comments.append(new)
                    }
                }
            }
            page.display()
        })
    }
    
    func sendComment(_ page: PageComments, _ comment: String){
        let event = page.event.event
        ref.child("events/\(event.uid)/social/comments/\(event.date.datetime())/\(Settings.shared.get().uid)/\(DateTime.shared.get())").setValue(comment)
        let new = Comment(uid: Settings.shared.get().uid, comment: comment, date: DateTime.shared.get())
        page.comments.append(new)
        page.display()
        notify(uid: page.event.event.uid, host: nil, event: page.event.event.date.datetime(), type: .comment)
    }
    
    func signInFailed(_ uid: String){
        ref.child("users/failed/\(uid)").observeSingleEvent(of: .value, with: {(snapshot) in
            
        })
    }
    
    func updateUsername(_ page: PageEditBasic){
        let uid = Settings.shared.get().uid
        ref.child("users/info/\(uid)/name").setValue(page.name.text())
        if let profile = Settings.shared.getProfile(uid){
            if profile.username!.lowercased() != page.username.text().lowercased(){
                ref.child("users/info").observeSingleEvent(of: .value, with: {(snapshot) in
                    for user in snapshot.all(){
                        if let value = user.childSnapshot(forPath: "username").value as? String{
                            if value.lowercased() == page.username.text().lowercased(){
                                page.failure(type: .usernameTaken)
                                return
                            }
                        }
                    }
                    page.success()
                    self.ref.child("users/info/\(uid)/username").setValue(page.username.text().lowercased())
                    profile.update(page.username.text())
                    profile.updateName(page.name.text())
                })
            }
        }
    }
    
    func updateAddress(_ page: PageEditBasic){
        let uid = Settings.shared.get().uid
        ref.child("users/info/\(uid)/name").setValue(page.name.text())
        ref.child("users/address/\(uid)/").setValue(page.address.text(), withCompletionBlock: { error, arg  in
            if let _ = error{
                page.failure(type: .network)
                return
            }
            page.success()
        })
    }
    
    func sendReport(_ report: Report){
        ref.child("reports/users/\(report.uid)/\(Settings.shared.get().uid)/\(DateTime.shared.get())/comment").setValue(report.box.text)
        if let host = report.host{
            ref.child("reports/users/\(report.uid)/\(Settings.shared.get().uid)/\(DateTime.shared.get())/host").setValue(host)
        }
        if let event = report.event{
            ref.child("reports/users/\(report.uid)/\(Settings.shared.get().uid)/\(DateTime.shared.get())/event").setValue(event)
        }
    }
    
    func deleteUser(){
        let uid = Settings.shared.get().uid
        ref.child("users/follows/following/\(uid)").observeSingleEvent(of: .value, with: { (snapshot) in
            for user in snapshot.all(){
                self.ref.child("users/follows/followers/\(user.key)/\(uid)").removeValue()
            }
            self.ref.child("users/follows/following/\(uid)").removeValue()
            self.ref.child("users/follows/blocked/\(uid)").removeValue()
            for a in ["bio","location","notificationTokens","range"]{
                self.ref.child("users/\(a)/\(uid)").removeValue()
            }
            self.ref.child("events/\(uid)").removeValue()
            self.ref.child("tags/\(uid)").removeValue()
            self.ref.child("notifications/new/\(uid)").removeValue()
            self.ref.child("notifications/read/\(uid)").removeValue()
            self.ref.child("users/info/\(uid)").removeValue()
            Settings.shared.finishDelete()
        })
    }
    
    func getWhatsHot(_ page: WhatsHot){
        if page.active{
            return
        }
        ref.child("events/likes/").observeSingleEvent(of: .value, with: {(snapshot) in
            for host in snapshot.all(){
                for event in host.all(){
                    if event.key.datetime()! > Date(timeIntervalSinceNow: -7*24*60*60){
                        if let location = Location.shared.get(){
                            self.ref.child("users/location/\(host.key)").observeSingleEvent(of: .value, with: {(snapshot) in
                                if let coordinates = snapshot.getCoordinate(){
                                    self.ref.child("events/\(host.key)/title/\(event.key)").observeSingleEvent(of: .value, with: {(snapshot) in
                                        if let value = snapshot.value as? String{
                                            if location.getDistance(coordinates) > Settings.shared.distance{
                                                page.worldwide.append(Event(name: value, date: event.key.datetime()!, uid: host.key))
                                                page.worldwide.update()
                                            }
                                            else{
                                                page.local.append(Event(name: value, date: event.key.datetime()!, uid: host.key))
                                                page.local.update()
                                            }
                                        }
                                    })
                                }
                            })
                        }
                        else{
                            page.noLocation()
                            self.ref.child("events/\(host.key)/title/\(event.key)").observeSingleEvent(of: .value, with: {(snapshot) in
                                if let value = snapshot.value as? String{
                                    page.worldwide.append(Event(name: value, date: event.key.datetime()!, uid: host.key))
                                    page.worldwide.update()
                                }
                            })
                        }
                    }
                }
            }
        })
    }
    
    func getMessages(_ messenger: Messenger){
        ref.child("messages/\(Settings.shared.get().uid)/latest").observe(.value, with: {(snapshot) in
            for user in snapshot.all(){
                var l = String()
                var u = String()
                for latest in user.all().reversed(){
                    if let uid = latest.value as? String{
                        if let lat = l.datetime(){
                            if latest.key.datetime()! > lat{
                                l = latest.key
                                u = uid
                            }
                            else{
                                self.ref.child("messages/\(Settings.shared.get().uid)/latest/\(user.key)/\(latest.key)").removeValue()
                            }
                        }
                        else{
                            l = latest.key
                            u = uid
                        }
                    }
                }
                self.ref.child("messages/\(Settings.shared.get().uid)/\(user.key)/\(u)/\(l)").observeSingleEvent(of: .value, with: {(message) in
                    if let value = message.value as? String{
                        if messenger.messages.contains(where: {$0.uid == user.key}){
                            if let first = messenger.messages.first(where: {$0.uid == user.key}){
                                first.updateMessage(value, l.datetime()!)
                            }
                        }
                        else{
                            let new = MessageHeader(uid: user.key, message: value, latest: l.datetime()!)
                            messenger.messages.append(new)
                        }
                    }
                    messenger.update(nil)
                })
                self.ref.child("users/online/\(user.key)/").observe(.value, with: {(snapshot) in
                    if let value = snapshot.value as? Bool{
                        if let first = messenger.messages.first(where: {$0.uid == user.key}){
                            if value{
                                first.online()
                                if let page = Settings.shared.home?.container?.pages.last as? PageConversation{
                                    if page.uid == user.key{
                                        Settings.shared.home?.container?.banner?.notifications.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
                                    }
                                }
                            }
                            else{
                                first.offline()
                                if let page = Settings.shared.home?.container?.pages.last as? PageConversation{
                                    if page.uid == user.key{
                                        Settings.shared.home?.container?.banner?.notifications.backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
                                    }
                                }
                            }
                        }
                    }
                })
            }
        })
    }
    
    func getMessages(_ page: PageConversation){
        
        ref.child("messages/\(Settings.shared.get().uid)/\(page.uid)/\(page.uid)").observe(.value, with: {(snapshot) in
            for child in snapshot.all(){
                if let val = child.value as? String{
                    if !page.messages.contains(where: {$0.time == child.key.datetime() && $0.uid == page.uid}){
                        page.messages.append(Message(uid: page.uid, message: val, time: child.key.datetime()!))
                    }
                }
            }
            page.update()
            page.loaded = true
        })
        ref.child("messages/\(Settings.shared.get().uid)/\(page.uid)/\(Settings.shared.get().uid)").observe(.value, with: {(snapshot) in
            for child in snapshot.all(){
                if let val = child.value as? String{
                    if !page.messages.contains(where: {$0.time == child.key.datetime() && $0.uid == Settings.shared.get().uid}){
                        page.messages.append(Message(uid: Settings.shared.get().uid, message: val, time: child.key.datetime()!))
                    }
                }
            }
            page.update()
            page.loaded = true
        })
        self.ref.child("messages/\(Settings.shared.get().uid)/\(page.uid)/typing").observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? Bool{
                page.isTyping = value
                page.update()
            }
        })
    }
    
    func newMessage(uid: String, message: String){
        let time = DateTime.shared.get()
        ref.child("messages/\(Settings.shared.get().uid)/\(uid)/\(Settings.shared.get().uid)/\(time)").setValue(message)
        ref.child("messages/\(Settings.shared.get().uid)/latest/\(uid)/\(time)").setValue(Settings.shared.get().uid)
        ref.child("messages/\(uid)/\(Settings.shared.get().uid)/\(Settings.shared.get().uid)/\(time)").setValue(message)
        ref.child("messages/\(uid)/latest/\(Settings.shared.get().uid)/\(time)").setValue(Settings.shared.get().uid)
        notify(uid: uid, host: nil, event: nil, type: .message)
    }
    
    func removeMessageNotifications(_ uid: String){
        ref.child("notifications/new/\(Settings.shared.get().uid)").observeSingleEvent(of: .value, with: {(snapshot) in
            for time in snapshot.all(){
                for user in time.all(){
                    for type in user.all(){
                        if type.key == "message" && user.key == uid{
                            self.ref.child("notifications/new/\(Settings.shared.get().uid)/\(time.key)/\(user.key)/").removeValue()
                        }
                    }
                }
            }
        })
    }
    
    func startTyping(uid: String){
        ref.child("messages/\(uid)/\(Settings.shared.get().uid)/typing").setValue(true)
    }
    
    func stopTyping(uid: String){
        ref.child("messages/\(uid)/\(Settings.shared.get().uid)/typing").setValue(false)
    }
    
    func online(){
        ref.child("users/online/\(Settings.shared.get().uid)/").setValue(true)
    }
    
    func offline(){
        ref.child("users/online/\(Settings.shared.get().uid)/").setValue(false)
    }
    
    func getALook(_ widget: WidgetTakeALook){
        ref.child("takealook/\(widget.uid)/").observeSingleEvent(of: .value, with: {(snapshot) in
            for snap in snapshot.all(){
                print(snap.key)
            }
        })
    }
    
    func uploadLook(_ image: UIImage){
        
    }
    
}

enum notificationType: String{
    case like
    case follow
    case message
    case tag
    case comment
}
