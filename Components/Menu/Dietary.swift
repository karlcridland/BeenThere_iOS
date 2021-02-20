//
//  Dietary.swift
//  Been There
//
//  Created by Karl Cridland on 21/09/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class Dietary: UILabel{
    init(center: CGPoint, type: dietaryConfinement) {
        super .init(frame: CGRect(x: center.x - 10, y: center.y - 10, width: 20, height: 20))
        
        layer.cornerRadius = 10
        
        font = Settings.shared.font
        increase(-1)
        
        switch type {
        case .dairy:
            backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            textColor = .black
            text = "DF"
            increase(-1)
            break
        case .vegan:
            backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            text = "V"
            break
        case .vegetarian:
            backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            text = "V"
            break
        case .nuts:
            backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
            text = "N"
            break
        case .gluten:
            backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            text = "GF"
            increase(-1)
            break
        }
        
        textAlignment = .center
        clipsToBounds = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum dietaryConfinement{
    case vegan
    case vegetarian
    case dairy
    case nuts
    case gluten
}
