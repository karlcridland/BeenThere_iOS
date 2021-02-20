//
//  PageEditInfo.swift
//  Been There
//
//  Created by Karl Cridland on 21/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageEditInfo: PageReverse {

    let box = UITextView(frame: CGRect(x: 20, y: 20, width: UIScreen.main.bounds.width-40, height: 200))
    
    init() {
        super .init(title: "extra info")
        addSubview(box)
        box.backgroundColor = .white
        box.clipsToBounds = true
        box.layer.cornerRadius = 4
        box.textColor = .black
        box.font = Settings.shared.font
        Firebase.shared.getInfo(self)
    }
    
    override func disappear() {
        super.disappear()
        Firebase.shared.updateInfo(box.text!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
