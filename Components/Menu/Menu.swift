//
//  Menu.swift
//  Been There
//
//  Created by Karl Cridland on 19/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class Menu: UIView{
    
    var position = 0
    var edit = false
    
    override init(frame: CGRect) {
        super .init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


