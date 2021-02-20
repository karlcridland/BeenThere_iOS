//
//  DataSnapshot.swift
//  Been There
//
//  Created by Karl Cridland on 23/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import FirebaseDatabase
import CoreLocation

extension DataSnapshot{
    
    func getCoordinate() -> CLLocationCoordinate2D?{
        if let lat = self.childSnapshot(forPath: "latitude").value as? Double{
            if let lon = self.childSnapshot(forPath: "longitude").value as? Double{
                return CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
            }
        }
        return nil
    }
    
    func containsUser() -> Bool{
        for user in self.children.allObjects as! [DataSnapshot]{
            if user.key == Settings.shared.get().uid{
                return true
            }
        }
        return false
    }
    
    func isSubMenu() -> Bool{
        for child in self.children.allObjects as! [DataSnapshot]{
            if child.key == "price"{
                return false
            }
        }
        return true
    }
    
    func getMenu(_ page: PageEditMenu) -> Menu?{
        if let title = self.childSnapshot(forPath: "title").value as? String{
            if isSubMenu(){
                let new = MenuEdit(page: page, title: title)
                var temp = [Menu]()
                for child in self.children.allObjects as! [DataSnapshot]{
                    if let new = child.getMenu(page){
                        temp.append(new)
                    }
                }
                if temp is [MenuEdit]{
                    new.menus = temp as! [MenuEdit]
                }
                if temp is [MenuItemEdit]{
                    new.items = temp as! [MenuItemEdit]
                }
                return new
            }
            else{
                if let subtitle = self.childSnapshot(forPath: "subtitle").value as? String{
                    if let price = self.childSnapshot(forPath: "price").value as? Int{
                        return MenuItemEdit(title: title, subtitle: subtitle, price: price, position: 0, diet: self.childSnapshot(forPath: "dietary").value as? String ?? "")
                    }
                }
                else{
                    if let price = self.childSnapshot(forPath: "price").value as? Int{
                        return MenuItemEdit(title: title, subtitle: nil, price: price, position: 0, diet: self.childSnapshot(forPath: "dietary").value as? String ?? "")
                    }
                }
            }
        }
        return nil
    }
    
    func getMenu(_ page: PageFoodMenu) -> Menu?{
        if let title = self.childSnapshot(forPath: "title").value as? String{
            if isSubMenu(){
                let new = MenuEdit(page: page, title: title, items: [], menus: [])
                var temp = [Menu]()
                for child in self.children.allObjects as! [DataSnapshot]{
                    if let new = child.getMenu(page){
                        temp.append(new)
                    }
                }
                if temp is [MenuEdit]{
                    new.menus = temp as! [MenuEdit]
                }
                if temp is [MenuItemEdit]{
                    new.items = temp as! [MenuItemEdit]
                }
                new.edit = false
                return new
            }
            else{
                if let price = self.childSnapshot(forPath: "price").value as? Int{
                    if let subtitle = self.childSnapshot(forPath: "subtitle").value as? String{
                        let new = MenuItemEdit(title: title, subtitle: subtitle, price: price, position: 0, diet: self.childSnapshot(forPath: "dietary").value as? String ?? "")
                        new.edit = false
                        new.redisplay()
                        return new
                    }
                    else{
                        let new = MenuItemEdit(title: title, subtitle: "", price: price, position: 0, diet: self.childSnapshot(forPath: "dietary").value as? String ?? "")
                        new.edit = false
                        new.redisplay()
                        return new
                    }
                }
            }
        }
        return nil
    }
    
    func all() -> [DataSnapshot]{
        return children.allObjects as! [DataSnapshot]
    }
    
    func containsKey(_ key: String) -> Bool{
        for user in self.all(){
            if user.key == key{
                return true
            }
        }
        return false
    }
    
    func inRange(_ uid: String) -> Bool{
        return inRange(uid, Settings.shared.distance)
    }
    
    func inRange(_ uid: String, _ dist: Double) -> Bool{
        if let location = Location.shared.get(){
            if let lat = self.childSnapshot(forPath: "latitude").value as? Double{
                if let lon = self.childSnapshot(forPath: "longitude").value as? Double{
                    if location.getDistance(CLLocationCoordinate2D(latitude: lat, longitude: lon)) < dist{
                        return true
                    }
                }
            }
        }
        return false
    }
}
