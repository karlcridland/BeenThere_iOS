//
//  Date.swift
//  Been There
//
//  Created by Karl Cridland on 16/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation

extension Date{
    
    func toString() -> String{
        if self.timeIntervalSinceNow > -60*60*24{
            let h = String(self.get(.hour)).setw("0", 2)
            let m = String(self.get(.minute)).setw("0", 2)
            return "\(h):\(m)"
        }
        return "\(self.get(.day))/\(self.get(.month))/\(self.get(.year))"
    }
    
    func get(_ type: dateType) -> Int{
        let formatter = DateFormatter()
        switch type {
            case .second:
            formatter.dateFormat = "ss"
                break
            case .minute:
            formatter.dateFormat = "mm"
                break
            case .hour:
            formatter.dateFormat = "HH"
                break
            case .day:
            formatter.dateFormat = "dd"
                break
            case .month:
            formatter.dateFormat = "MM"
                break
            case .year:
            formatter.dateFormat = "yyyy"
                break
        }
        return Int(formatter.string(from: self))!
    }
    
}

enum dateType{
    case day
    case month
    case year
    case second
    case minute
    case hour
}
