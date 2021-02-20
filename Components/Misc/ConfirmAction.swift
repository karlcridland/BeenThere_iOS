//
//  ConfirmAction.swift
//  Been There
//
//  Created by Karl Cridland on 18/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class ConfirmAction: UIView {
    
    let action: () -> Void
    let block = UIView()
    
    init(title: String, with completion: @escaping () -> Void) {
        self.action = completion
        super .init(frame: CGRect(x: UIScreen.main.bounds.width/2 - 125, y: UIScreen.main.bounds.height/2 - 50, width: 250, height: 100))
    
        block.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height/2))
        label.text = "confirm you want to \(title):"
        layer.cornerRadius = 8
        backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        self.block.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.block.alpha = 0.0
        self.alpha = 0.2
        
        UIView.animate(withDuration: 0.2, animations: {
            self.block.alpha = 1.0
            self.alpha = 1.0
        })
        
        if let view = Settings.shared.home?.view{
            view.addSubview(block)
            view.addSubview(self)
        }
        
        label.font = Settings.shared.font
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let confirm = UIButton(frame: CGRect(x: frame.width/2, y: frame.height/2, width: frame.width/2, height: frame.height/2))
        let cancel = UIButton(frame: CGRect(x: 0, y: frame.height/2, width: frame.width/2, height: frame.height/2))
        
        confirm.addTarget(self, action: #selector(clicked), for: .touchUpInside)
        for button in [confirm,cancel]{
            button.addTarget(self, action: #selector(close), for: .touchUpInside)
            button.titleLabel?.font = label.font
            button.setTitleColor(.black, for: .normal)
        }
        
        confirm.setTitle("confirm", for: .normal)
        cancel.setTitle("cancel", for: .normal)
        
        for a in [confirm,cancel,label]{
            addSubview(a)
        }
        
        Settings.shared.ca = self
    }
    
    @objc func clicked(){
        action()
    }
    
    @objc func close(){
        UIView.animate(withDuration: 0.2, animations: {
            self.block.alpha = 0.0
            self.alpha = 0.0
        })
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { _ in
            self.block.removeFromSuperview()
            self.removeFromSuperview()
        })
        Settings.shared.ca = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
