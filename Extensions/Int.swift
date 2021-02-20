//
//  Int.swift
//  Kaktus
//
//  Created by Karl Cridland on 11/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation

extension Int{
    
    func ordinate() -> String{
        if (self%100 >= 11) && (self%100 <= 13){
            return String(self)+"th"
        }
        else{
            switch self%10 {
            case 1:
                return String(self)+"st"
            case 2:
                return String(self)+"nd"
            case 3:
                return String(self)+"rd"
            default:
                return String(self)+"th"
            }
        }
    }
    
    func isLeapYear() -> Bool{
        if self % 4 == 0 {
            if self % 100 == 0 && self % 400 != 0 {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    func price(currency: Currency) -> String{
        var pence = String(self%100)
        while pence.count < 2{
            pence = "0"+pence
        }
        let pounds = String(self/100)
        switch currency{
            case .HRK:
                return "\(pounds),\(pence) \(currency.rawValue)"
            case .EUR:
                return "\(pounds),\(pence) \(currency.rawValue)"
            case .HUF:
                return "\(pounds)\(pence) \(currency.rawValue)"
            default:
                return "\(currency.rawValue)\(pounds).\(pence)"
        }
    }
}

enum Currency: String{
    case GBP = "£"
    case USD = "$"
    case CNY = "¥"
    case HRK = "kn"
    case EGP = "EGP"
    case EUR = "€"
    case HGK = "HK$"
    case HUF = "Ft"
}

