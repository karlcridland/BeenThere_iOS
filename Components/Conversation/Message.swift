//
//  Message.swift
//  Been There
//
//  Created by Karl Cridland on 05/10/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class Message{
    
    let time: Date
    let message: String
    let uid: String
    var ghost = false
    
    init(uid: String, message: String, time: Date) {
        self.uid = uid
        self.time = time
        self.message = message
    }
    
    func timestamp() -> UILabel{
        let label = UILabel(frame: CGRect(x: UIScreen.main.bounds.width, y: 0, width: 100, height: 30))
        label.tag = -1
        label.font = Settings.shared.font
        label.increase(-2)
        label.textColor = .white
        label.text = time.toString()
        return label
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
