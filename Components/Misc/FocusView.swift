//
//  FocusView.swift
//  Been There
//
//  Created by Karl Cridland on 24/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class FocusView: UIView {
    
    let block = UIButton()
    var speed = TimeInterval(0.2)
    
    init(width: CGFloat, height: CGFloat) {
        super .init(frame: CGRect(x: (UIScreen.main.bounds.width-width)/2, y: (UIScreen.main.bounds.height-height)/2, width: width, height: height))
    
        block.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        layer.cornerRadius = 8
        backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        self.block.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.block.alpha = 0.0
        self.alpha = 0.2
        
        UIView.animate(withDuration: speed, animations: {
            self.block.alpha = 1.0
            self.alpha = 1.0
        })
        
        if let view = Settings.shared.home?.view{
            view.addSubview(block)
            view.addSubview(self)
        }
        
        block.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    override func removeFromSuperview() {
        close()
    }
    
    @objc func close(){
        UIView.animate(withDuration: speed, animations: {
            self.block.alpha = 0.0
            self.alpha = 0.0
        })
        Timer.scheduledTimer(withTimeInterval: speed, repeats: false, block: { _ in
            self.block.removeFromSuperview()
            self.removeFromSuperview()
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

