//
//  PageError.swift
//  Been There
//
//  Created by Karl Cridland on 13/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageError: Page {
    
    override init(title: String){
        super .init(title: title)
        
        let message = UILabel(frame: CGRect(x: UIScreen.main.bounds.width/2 - 100, y: 50, width: 200, height: 50))
        message.text = "error: username not in use"
        message.font = Settings.shared.font
        message.textColor = .white
        
        addSubview(message)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
