//
//  MissedDrink.swift
//  Been There
//
//  Created by Karl Cridland on 20/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class MissedDrink: UIView {
    
    let block = UIView()
    let text = UITextView(frame: CGRect(x: 10, y: 60, width: UIScreen.main.bounds.width-60, height: 145))
    
    init() {
        super .init(frame: CGRect(x: 20, y: 150, width: UIScreen.main.bounds.width-40, height: 250))
        block.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 60))
        label.text = "did we miss any? help us out by telling us which ones:"
        layer.cornerRadius = 8
        backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        self.block.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.block.alpha = 0.0
        self.alpha = 0.2
        
        text.layer.cornerRadius = 4
        text.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        text.layer.borderWidth = 1
        text.textColor = .black
        text.font = Settings.shared.font
        text.backgroundColor = .white
        text.becomeFirstResponder()
        
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
        
        let cancel = UIButton(frame: CGRect(x: 0, y: 205, width: frame.width/2, height: 45))
        let confirm = UIButton(frame: CGRect(x: frame.width/2, y: 205, width: frame.width/2, height: 45))
        
        cancel.addTarget(self, action: #selector(close), for: .touchUpInside)
        confirm.addTarget(self, action: #selector(submit), for: .touchUpInside)
    
        for button in [confirm,cancel]{
            button.titleLabel?.font = label.font
            button.setTitleColor(.black, for: .normal)
            addSubview(button)
        }
    
        cancel.setTitle("cancel", for: .normal)
        confirm.setTitle("submit", for: .normal)
        addSubview(label)
        addSubview(text)
        
        
    }
    
    @objc func submit(){
        if let t = text.text{
            Firebase.shared.submitMissingDrinkReport(t)
        }
        close()
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


