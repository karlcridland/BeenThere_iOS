//
//  TagPad.swift
//  Been There
//
//  Created by Karl Cridland on 14/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class TagPad: UIView {
    
    var page: PageUpload?
    var button = UIButton()
    
    override init(frame: CGRect) {
        super .init(frame: frame)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            button = UIButton(frame: frame)
            addSubview(button)
            let list = TagList(frame: CGRect(x: frame.width/2 - 100, y: 25, width: 200, height: frame.height-50), point: touch.location(in: self), pad: self)
            addSubview(list)
            button.accessibilityElements = [list]
            button.addTarget(self, action: #selector(removeList), for: .touchUpInside)
            page?.returnScroll()
            UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    @objc func removeList(sender: UIButton){
        let list = sender.accessibilityElements![0] as! TagList
        list.removeFromSuperview()
        sender.removeFromSuperview()
    }
    
    func append(_ tagger: Tagger){
        addSubview(tagger)
        page?.tagButton.tags.append(tagger)
        page?.tagButton.show?.display()
        button.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
