//
//  DateTime.swift
//  waitt
//
//  Created by Karl Cridland on 23/05/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation

class DateTime {
    
    public static let shared = DateTime()
    
    private init(){
    }
    
    func get() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd:MM:yy HH:mm:ss"
        return formatter.string(from: Date.init())
    }
    
    func get(d: Int, m: Int, y: Int) -> String{
        let day = String(d).setw("0", 2)
        let month = String(m).setw("0", 2)
        return "\(day):\(month):\(y%100) 00:00:00"
    }
    
    func get(date: Date) -> String{
        return get(d: date.get(.day), m: date.get(.month), y: date.get(.year))
    }
}

extension String{
    
    func datetime() -> Date?{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd:MM:yy HH:mm:ss"
        if let r = formatter.date(from: self){
            return r
        }
        return nil
    }
    
}

extension Date{
    
    func dmy() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        let day = Int(formatter.string(from: self))!.ordinate()
        
        formatter.dateFormat = "MM"
        let month = ["January","February","March","April","May","June","July","August","September","October","November","December"][Int(formatter.string(from: self))!-1]
        
        formatter.dateFormat = "yyyy"
        return "\(day) \(month) \(formatter.string(from: self))"
    }
    
    func datetime() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd:MM:yy HH:mm:ss"
        let str = formatter.string(from: self)
        return str
    }
}
