//
//  PageExtraInfo.swift
//  Been There
//
//  Created by Karl Cridland on 21/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageExtraInfo: Page {

    let box = UITextView(frame: CGRect(x: 20, y: 20, width: UIScreen.main.bounds.width-40, height: 200))
    let uid: String
    
    init(uid: String) {
        self.uid = uid
        super .init(title: "information")
        addSubview(box)
        box.backgroundColor = .clear
        box.clipsToBounds = true
        box.layer.cornerRadius = 4
        box.textColor = .white
        box.isEditable = false
        box.font = Settings.shared.font
        Firebase.shared.getInfo(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
