//
//  PageMagnifyManage.swift
//  Been There
//
//  Created by Karl Cridland on 22/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageMagnifyManage: PageReverse {

    let rangeTitle = MenuButton(title: "range", position: 1)
    let range = UISlider(frame: CGRect(x: 20, y: 85, width: UIScreen.main.bounds.width-100, height: 30))
    let distance = UILabel(frame: CGRect(x: UIScreen.main.bounds.width-80, y: 85, width: 70, height: 30))
    
    let featured = MenuButton(title: "featured posts:", position: 1)
    
    var events = [EventClick]()
    let tier: TierCategory
    
    init(tier: TierCategory){
        self.tier = tier
        super .init(title: "manage - \(tier.rawValue)")
        if tier == .gold{
            featured.update(3)
            scroll.addSubview(rangeTitle)
            rangeTitle.layer.borderWidth = 0
            scroll.addSubview(range)
            scroll.addSubview(distance)
            distance.textAlignment = .right
            distance.font = Settings.shared.font
            range.addTarget(self, action: #selector(sliding), for: .allEvents)
            range.addTarget(self, action: #selector(slid), for: .primaryActionTriggered)
            Firebase.shared.getRange(self)
        }
        scroll.addSubview(featured)
        featured.layer.borderWidth = 0
        Firebase.shared.getFeaturedEvents(self)
    }

    @objc func sliding(){
        let d = Int(100*(range.value*95.0/100.0)+5)
        distance.text = "\(d) km"
    }

    @objc func slid(){
        let d = Int(100*(range.value*95.0/100.0)+5)
        Firebase.shared.updateMagnifyRange(d)
    }

    func slideStart(_ position: Int){
        range.value = (Float(position - 5)/95)
        distance.text = "\(position) km"
    }
    
    func display(){
        for event in events{
            scroll.addSubview(event)
            scroll.contentSize = CGSize(width: scroll.frame.width, height: event.frame.maxY)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EventClick: UIView{
    
    let click: CButton
    let date: String
    
    init(title: String, date: String, position: Int, base: CGFloat) {
        self.click = CButton(frame: CGRect(x: 15, y: 15, width: 30, height: 30))
        self.date = date
        super .init(frame: CGRect(x: 10, y: base + CGFloat(position)*80, width: UIScreen.main.bounds.width-20, height: 60))
        
        layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        layer.borderWidth = 1
        layer.cornerRadius = 6
        
        let text = UILabel(frame: CGRect(x: 70, y: 30, width: frame.width-80, height: 25))
        text.text = title
        addSubview(text)
        text.font = Settings.shared.font
        
        let dmy = UILabel(frame: CGRect(x: 70, y: 5, width: frame.width-80, height: 25))
        dmy.text = date.datetime()!.dmy()
        addSubview(dmy)
        dmy.font = Settings.shared.font
        
        addSubview(click)
        click.addTarget(self, action: #selector(clickClick), for: .touchUpInside)
        Firebase.shared.isFeatured(self)
    }
    
    @objc func clickClick(){
        if click.isChecked{
            layer.borderColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            layer.borderWidth = 2
            Firebase.shared.featureEvent(self, true)
        }
        else{
            layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            layer.borderWidth = 1
            Firebase.shared.featureEvent(self, false)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
