//
//  Report.swift
//  Been There
//
//  Created by Karl Cridland on 25/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class Report: FocusView {
    
    let uid: String
    let event: String?
    let host: String?
    let box = UITextView()
    
    init(uid: String, event: String?, host: String?) {
        self.uid = uid
        self.event = event
        self.host = host
        super .init(width: 300, height: 320)
        center = CGPoint(x: center.x, y: center.y-140)
        
        let submit = UIButton(frame: CGRect(x: frame.width-50, y: frame.height-40, width: 40, height: 40))
        submit.setImage(UIImage(named: "logo-clear"), for: .normal)
        addSubview(submit)
        submit.addTarget(self, action: #selector(clicked), for: .touchUpInside)
        
        let cancel = UIButton(frame: CGRect(x: 5, y: frame.height-30, width: 80, height: 20))
        cancel.setTitle("cancel", for: .normal)
        cancel.setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), for: .normal)
        addSubview(cancel)
        cancel.titleLabel!.font = Settings.shared.font
        cancel.addTarget(self, action: #selector(exit), for: .touchUpInside)
        
        box.frame = CGRect(x: 5, y: 45, width: frame.width-10, height: frame.height-85)
        box.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        box.layer.cornerRadius = 5
        box.textColor = .black
        box.isEditable = true
        box.font = Settings.shared.font
        box.isUserInteractionEnabled = true
        addSubview(box)
        box.becomeFirstResponder()
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 40))
        if let profile = Settings.shared.getProfile(uid){
            label.text = "report \(profile.name)"
        }
        addSubview(label)
        label.textAlignment = .center
        label.font = Settings.shared.font
        label.textColor = .black
    }
    
    @objc func clicked(){
        Firebase.shared.sendReport(self)
        exit()
        
    }
    
    @objc func exit(){
        removeFromSuperview()
        box.removeFromSuperview()
        resignFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
