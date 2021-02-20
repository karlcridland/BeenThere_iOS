//
//  Widget.swift
//  Been There
//
//  Created by Karl Cridland on 13/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class Widget: UIView {
    
    let scroll: UIScrollView
    let name: UILabel
    let subtitle: UILabel
    
    init(title: String, frame: CGRect) {
        scroll = UIScrollView()
        name = UILabel(frame: CGRect(x: 10, y: 5, width: UIScreen.main.bounds.width-20, height: 15))
        subtitle = UILabel(frame: CGRect(x: 10, y: 20, width: UIScreen.main.bounds.width-20, height: 15))
        super .init(frame: frame)
        subtitle.text = title
        subtitle.textColor = .white
        name.textColor = .white
        name.font = Settings.shared.font
        name.increase(-1)
        subtitle.font = Settings.shared.font
        subtitle.increase(-2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
