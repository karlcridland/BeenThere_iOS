//
//  WhatsHot.swift
//  Been There
//
//  Created by Karl Cridland on 27/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class WhatsHot: HomePage {
    
    let local = FeedContainer(type: .local)
    let worldwide = FeedContainer(type: .worldwide)
    
    var events = [Event]()
    
    init() {
        let buf = Settings.shared.upper_bound+90
        super .init(frame: CGRect(x: UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-buf))

        Firebase.shared.getWhatsHot(self)
        Timer.scheduledTimer(withTimeInterval: 600, repeats: true, block: { _ in
            Firebase.shared.getWhatsHot(self)
        })
        addSubview(local)
        addSubview(worldwide)
    }
    
    func noLocation(){
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: local.scroll.frame.width, height: local.scroll.frame.height))
        local.addSubview(button)
        button.setTitle("location required", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel!.font = Settings.shared.font
        button.addTarget(self, action: #selector(getLocale), for: .touchUpInside)
    }
    
    @objc func getLocale(){
        Location.shared.locationManager?.requestWhenInUseAuthorization()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

