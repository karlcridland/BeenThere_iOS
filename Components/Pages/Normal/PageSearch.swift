//
//  PageSearch.swift
//  Kaktus
//
//  Created by Karl Cridland on 12/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import CoreLocation

class PageSearch: Page, UIScrollViewDelegate {
    
    var snapshot: DataSnapshot?
    var addresses: DataSnapshot?
    var drinks: DataSnapshot?
    let search = SearchBar(frame: CGRect(x: 10, y: 10, width: UIScreen.main.bounds.width-20, height: 30), placeholder: "search", type: .search)
    
    var results = [Profile]()
    
    init() {
        super .init(title: "search")
        addSubview(search)
        search.input.becomeFirstResponder()
        scroll.frame = CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-(Settings.shared.upper_bound+120))
        search.input.addTarget(self, action: #selector(query), for: .editingChanged)
        search.clear.addTarget(self, action: #selector(query), for: .touchUpInside)
        Timer.scheduledTimer(withTimeInterval: 120, repeats: true, block: { timer in
            if self.superview == nil{
                timer.invalidate()
            }
            self.snapshot = nil
            self.addresses = nil
            self.drinks = nil
        })
        scroll.delegate = self
    }
    
    @objc func query(){
        if search.text() == "" || search.text() == " "{
            results.removeAll()
            showResults()
        }
        else{
            Firebase.shared.search(self, search.text())
        }
    }
    
    func refine(_ query: String){
        results.removeAll()
        if query.count < 3{
            for key in Settings.shared.profiles.keys{
                var scoreboost = 0.0
                if let user = Settings.shared.profiles[key]{
                    scoreboost += user.name.match(query)
                    if let username = user.username{
                        scoreboost += username.match(query)
                    }
                    else{
                        if let dist = user.distance{
                            let maxDistance = Settings.shared.distance
                            scoreboost += maxDistance - dist
                        }
                    }
                    if scoreboost > 0{
                        user.relevancy = scoreboost
                        results.append(user)
                    }
                }
            }
            showResults()
            return
        }
        if let data = snapshot{
            for user in data.children.allObjects as! [DataSnapshot]{
                if !Settings.shared.blocked.contains(user.key){
                    if let name = user.childSnapshot(forPath: "name").value as? String{
                        var scoreboost = 0.0
                        for word in name.split(separator: " "){
                            for part in query.split(separator: " "){
                                scoreboost += word.lowercased().match(part.lowercased())
                            }
                        }
                        if let username = user.childSnapshot(forPath: "username").value as? String{
                            let new = Profile(uid: user.key, name: name, username: username)
                            if username == query{
                                let new = Profile(uid: user.key, name: name, username: username)
                                new.relevancy = 1000.0
                                results.append(new)
                            }
                            new.relevancy = scoreboost + username.lowercased().match(query.lowercased())
                            if let r = new.relevancy{
                                if r > 0.0{
                                    results.append(new)
                                }
                            }
                        }
                        else{
                            if scoreboost > 0.0{
                                if let address = addresses?.childSnapshot(forPath: user.key).value as? String{
                                    let geoCoder = CLGeocoder()
                                    geoCoder.geocodeAddressString(address.replacingOccurrences(of: "\n", with: ", ")) { (placemarks, error) in
                                        guard
                                            let placemarks = placemarks,
                                            let location = placemarks.first?.location
                                        else {
                                            return
                                        }
                                        if let loc = Location.shared.get(){
                                            let distance = location.coordinate.getDistance(loc)
                                            let maxDistance = Settings.shared.distance
                                            scoreboost += maxDistance - distance
                                            if distance < maxDistance{
                                                var new: Profile?
                                                if let profile = Settings.shared.getProfile(user.key){
                                                    new = profile
                                                }
                                                else{
                                                    new = Profile(uid: user.key, name: name, distance: location.coordinate.getDistance(loc))
                                                    Settings.shared.profiles[user.key] = new
                                                    Timer.scheduledTimer(withTimeInterval: 720, repeats: false, block: { _ in
                                                        if let profile = Settings.shared.getProfile(user.key){
                                                            if !Settings.shared.friends.contains(user.key){
                                                                Settings.shared.profiles.removeValue(forKey: profile.uid)
                                                            }
                                                        }
                                                    })
                                                }
                                                if self.search.text() == query{
                                                    self.results.append(new!)
                                                }
                                                for word in name.split(separator: " "){
                                                    if let relevancy = new!.relevancy{
                                                        new!.relevancy = relevancy + word.lowercased().match(query.lowercased())
                                                    }
                                                    else{
                                                        new!.relevancy = word.lowercased().match(query.lowercased())
                                                    }
                                                }
                                                if let relevancy = new!.relevancy{
                                                    new!.relevancy = relevancy + (distance*100)/maxDistance
                                                }
                                                else{
                                                    new!.relevancy = (distance*100)/maxDistance
                                                }
                                            }
                                            self.showResults()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if let drinks = self.drinks{
                for uid in drinks.all(){
                    for big in uid.all(){
                        for small in big.all(){
                            for drink in small.all(){
                                if drink.key.match(query) > 50{
                                    if let first = results.first(where: {$0.uid == uid.key}){
                                        if let price = drink.value as? Int{
                                            if let _ = first.relevancy{
                                                first.relevancy! += drink.key.match(query)
                                            }
                                            else{
                                                first.relevancy = drink.key.match(query)
                                            }
                                            first.context = "\(drink.key): \(price.price(currency: .GBP))"
                                        }
                                    }
                                    else{
                                        if let name = snapshot?.childSnapshot(forPath: uid.key).childSnapshot(forPath: "name").value as? String{
                                            if let price = drink.value as? Int{
                                                let new = Profile(uid: uid.key, name: name, distance: 0.0)
                                                Settings.shared.profiles[uid.key] = new
                                                Timer.scheduledTimer(withTimeInterval: 720, repeats: false, block: { _ in
                                                    if let profile = Settings.shared.getProfile(uid.key){
                                                        if !Settings.shared.friends.contains(uid.key){
                                                            Settings.shared.profiles.removeValue(forKey: profile.uid)
                                                        }
                                                    }
                                                })
                                                new.relevancy = drink.key.match(query)
                                                new.context = "\(drink.key): \(price.price(currency: .GBP))"
                                                results.append(new)
                                            }
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
            showResults()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func showResults(){
        scroll.removeAll()
        var i = 0
        for result in results.sorted(by: {$0.relevancy! > $1.relevancy!}){
            if !scroll.subviews.contains(where: {$0 is ProfileDisplay && ($0 as! ProfileDisplay).profile.uid == result.uid}){
                let new = result.display()
                scroll.addSubview(new)
                new.frame = CGRect(x: 0, y: CGFloat(i)*85, width: new.frame.width, height: 80)
                i += 1
            }
            else{
                if let profile = scroll.subviews.first(where: {$0 is ProfileDisplay && ($0 as! ProfileDisplay).profile.uid == result.uid}) as? ProfileDisplay{
                    if let relevancy = profile.profile.relevancy{
                        if relevancy < result.relevancy!{
                            profile.removeFromSuperview()
                            let new = result.display()
                            scroll.addSubview(new)
                            new.frame = profile.frame
                            
                        }
                    }
                }
            }
        }
        scroll.contentSize = CGSize(width: scroll.frame.width, height: [CGFloat(i)*85,scroll.frame.height+1].max()!)
    }
    
    override func cancelDisappear() {
        search.input.becomeFirstResponder()
    }
    
    override func disappear() {
        super.disappear()
        snapshot = nil
        addresses = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
