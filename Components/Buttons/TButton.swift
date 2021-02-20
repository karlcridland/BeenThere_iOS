//
//  TButton.swift
//  Been There
//
//  Created by Karl Cridland on 21/09/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class TButton: UIButton {
    
    var clicked = false
    
    init(frame: CGRect, text: String) {
        super .init(frame: frame)
        
        layer.cornerRadius = 4
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        setTitle(text, for: .normal)
        titleLabel!.font = Settings.shared.font
        
        addTarget(self, action: #selector(click), for: .touchUpInside)
    }
    
    @objc func click(){
        clicked = !clicked
        if clicked{
            backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        }
        else{
            backgroundColor = .clear
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
