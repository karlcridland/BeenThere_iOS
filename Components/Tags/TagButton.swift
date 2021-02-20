//
//  TagButton.swift
//  Been There
//
//  Created by Karl Cridland on 14/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class TagButton: UIButton{
    
    var isChecked = false
    let tagTitle = UILabel(frame: CGRect(x: 50, y: 0, width: UIScreen.main.bounds.width-90, height: 30))
    let img = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    var page: PageUpload?
    
    var tags = [Tagger]()
    var show: TagShow?
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        addTarget(self, action: #selector(check), for: .touchUpInside)
        check()
        addSubview(img)
        addSubview(tagTitle)
        tagTitle.text = "tag friends"
        tagTitle.textColor = .white
        tagTitle.font = Settings.shared.font
        img.image = UIImage(named: "tag")
        show = TagShow(button: self)
    }
    
    @objc func check(){
        isChecked = !isChecked
        if let upload = page{
            if isChecked{
                img.image = UIImage(named: "tag")
                upload.pad.isHidden = true
            }
            else{
                img.image = UIImage(named: "tag-highlight")
                upload.pad.isHidden = false
            }
        }
    }
    
    func resetTags(){
        for t in tags{
            t.removeFromSuperview()
        }
        tags.removeAll()
        
        page?.pad.removeAll()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
