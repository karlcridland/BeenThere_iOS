//
//  NButton.swift
//  waitt
//
//  Created by Karl Cridland on 24/05/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class NButton: UIButton {
    
    private let title: String
    private let t = UILabel()
    private let button = UIButton()
    var highlight = false
    var s = "s"
    
    private var n = Int()
    
    init(frame: CGRect, title: String, s: Bool) {
        self.title = title
        super .init(frame: frame)
        if !s{
            self.s = ""
        }
        button.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        t.text = title
        t.textAlignment = .center
        t.font = Settings.shared.font
        addSubview(t)
        addSubview(button)
        update(0)
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: {_ in
            self.t.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            self.t.increase(-1)
        })
    }
    
    func get() -> Int{
        return n
    }
    
    func update(_ i: Int){
        n = i
        if i >= 1000000{
            t.text = "\(i/1000)m \(title)\(s)"
        }
        else if i >= 1000{
            t.text = "\(i/1000)k \(title)\(s)"
        }
        else if i == 1{
            t.text = "\(i) \(title)"
        }
        else{
            t.text = "\(i) \(title)\(s)"
        }
        if highlight{
            t.textColor = .systemBlue
        }
        else{
            t.textColor = .white
        }
    }
    
    override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        button.addTarget(target, action: action, for: controlEvents)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
