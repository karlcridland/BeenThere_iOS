//
//  FeedContainerExpandable.swift
//  Been There
//
//  Created by Karl Cridland on 21/09/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class FeedContainerExpandable: FeedContainer {
    
    var cover = UIButton()
    
    override init(type: eventType) {
        super .init(type: type)
        
        cover.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0.4957191781)
        cover.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func expand(height: CGFloat, y: CGFloat, bigger: Bool){
        addSubview(cover)
        UIView.animate(withDuration: 0.1, animations: {
            if bigger{
                self.cover.alpha = 0.0
            }
            else{
                self.cover.alpha = 1.0
            }
            self.cover.frame = CGRect(x: 0, y: 20, width: self.frame.width, height: height-20)
            self.frame = CGRect(x: 0, y: y, width: self.frame.width, height: height)
        })
        if bigger{
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
                self.cover.removeFromSuperview()
            })
        }
    }
}
