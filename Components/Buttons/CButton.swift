//
//  CButton.swift
//  Been There
//
//  Created by Karl Cridland on 14/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class CButton: UIButton {
    
    var isChecked = true
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        layer.borderWidth = 2.0
        layer.cornerRadius = frame.width/8
        setTitle("X", for: .normal)
        titleLabel?.font = Settings.shared.font
        click()
        addTarget(self, action: #selector(click), for: .touchUpInside)
    }
    
    @objc func click(){
        isChecked = !isChecked
        if isChecked{
            setTitleColor(.white, for: .normal)
        }
        else{
            setTitleColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.6492669092), for: .normal)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
