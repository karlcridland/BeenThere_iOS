//
//  WidgetTakeALook.swift
//  Been There
//
//  Created by Karl Cridland on 21/09/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class WidgetTakeALook: Widget {
    
    let uid: String
    
    let height = (UIScreen.main.bounds.height-Settings.shared.upper_bound-40)/2 - 25
    
    init(title: String, frame: CGRect, uid: String) {
        self.uid = uid
        super .init(title: title, frame: frame)
        Firebase.shared.getALook(self)
        
        removeAll()
        scroll.frame = CGRect(x: 10, y: 10, width: UIScreen.main.bounds.width-20, height: height-20)
        addSubview(scroll)
        
        if Settings.shared.get().uid == uid{
            let upload = UIButton(frame: CGRect(x: frame.width-50, y: self.height - 50, width: 35, height: 35))
//            s.addSubview(upload)
            upload.setImage(UIImage(named: "camera"), for: .normal)
            upload.addTarget(self, action: #selector(self.update), for: .touchUpInside)
        }
        
        clipsToBounds = true
        
        
    }
    
    @objc func update(){
        if let page = Settings.shared.home?.container?.pages.last(where: {($0 is PageBusiness) && ($0 as! PageBusiness).uid == Settings.shared.get().uid}) as? PageBusiness{
//            page.target = self
            let pageUpload = PageUpload(page: page)
            Settings.shared.home?.container?.append(pageUpload)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
