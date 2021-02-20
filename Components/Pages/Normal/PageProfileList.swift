//
//  PageProfileList.swift
//  Been There
//
//  Created by Karl Cridland on 16/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageProfileList: Page{
    
    var results = [Profile]()
    var full = 0
    
    override init(title: String) {
        super .init(title: title)
    }
    
    func display(){
        var h = CGFloat(0.0)
        scroll.removeAll()
        for result in results{
            let view = result.display()
            view.frame = CGRect(x: 0, y: h, width: view.frame.width, height: view.frame.height)
            scroll.addSubview(view)
            h += view.frame.height
        }
        scroll.contentSize = CGSize(width: UIScreen.main.bounds.width, height: h)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
