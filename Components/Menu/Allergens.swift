//
//  Allergens.swift
//  Been There
//
//  Created by Karl Cridland on 24/09/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class Allergens: FocusView{
    
    init() {
        super .init(width: 200, height: 200)
        
        var i = 0
        let text = ["vegetarian","vegan","contains nuts","dairy free","gluten free"]
        for allergen in [dietaryConfinement.vegetarian,dietaryConfinement.vegan,dietaryConfinement.nuts,dietaryConfinement.dairy,dietaryConfinement.gluten]{
            let new = Dietary(center: CGPoint(x: 20, y: i*30 + 20), type: allergen)
            let label = UILabel(frame: CGRect(x: 45, y: i*30 + 10, width: 155, height: 20))
            label.font = Settings.shared.font
            label.text = text[i]
            i += 1
            
            addSubview([new,label])
        }
        
        backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        let done = UIButton(frame: CGRect(x: 0, y: frame.height-40, width: frame.width, height: 40))
        done.setTitle("done", for: .normal)
        done.titleLabel?.font = Settings.shared.font
        done.setTitleColor(.white, for: .normal)
        done.addTarget(self, action: #selector(close), for: .touchUpInside)
        addSubview(done)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
