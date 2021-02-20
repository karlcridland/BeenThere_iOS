//
//  TagShow.swift
//  Been There
//
//  Created by Karl Cridland on 23/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class TagShow: UIScrollView {
    
    let button: TagButton
    
    init(button: TagButton) {
        self.button = button
        super .init(frame: .zero)
        showsHorizontalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func display(){
        removeAll()
        var w = CGFloat(0.0)
        let offset = contentOffset
        for tag in button.tags{
            if let profile = Settings.shared.getProfile(tag.uid){
                let width = profile.name.width(font: Settings.shared.font!)+CGFloat(30)
                let delete = UIButton(frame: CGRect(x: 2+w, y: 2, width: width, height: frame.height-4))
                delete.layer.cornerRadius = 4
                delete.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                delete.layer.borderWidth = 1
                delete.accessibilityLabel = tag.uid
                delete.addTarget(self, action: #selector(deleteTag), for: .touchUpInside)
                
                let label = UILabel(frame: CGRect(x: 7+w, y: 2, width: width-10, height: frame.height-4))
                label.text = profile.name
                label.font = Settings.shared.font
                
                let cross = UILabel(frame: CGRect(x: label.frame.maxX-15, y: 6, width: frame.height-4, height: frame.height-4))
                cross.text = "+"
                cross.transform = CGAffineTransform(rotationAngle: CGFloat.pi/4)
                
                addSubview(cross)
                addSubview(label)
                addSubview(delete)
                w += width + 2
            }
        }
        contentSize = CGSize(width: w, height: frame.height)
        contentOffset = offset
        if contentOffset.x < 0{
            contentOffset = CGPoint(x: 0, y: 0)
        }
    }
    
    @objc func deleteTag(sender: UIButton){
        if let uid = sender.accessibilityLabel{
            if let first = button.tags.first(where: {$0.uid == uid}){
                first.removeFromSuperview()
                button.tags.removeAll(where: {$0.uid == uid})
                display()
            }
        }
    }
}
