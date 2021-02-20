//
//  PageEditBusiness.swift
//  Been There
//
//  Created by Karl Cridland on 18/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageEditBusiness: PageReverse {
    
    let open = MenuButton(title: "opening hours", position: 1)
    
    let m1 = TimeInput(frame: CGRect(x: 100, y: 80, width: (UIScreen.main.bounds.width-160)/2, height: 30))
    let m2 = TimeInput(frame: CGRect(x: 130+(UIScreen.main.bounds.width-140)/2, y: 80, width: (UIScreen.main.bounds.width-160)/2, height: 30))
    let t1 = TimeInput(frame: CGRect(x: 100, y: 120, width: (UIScreen.main.bounds.width-160)/2, height: 30))
    let t2 = TimeInput(frame: CGRect(x: 130+(UIScreen.main.bounds.width-140)/2, y: 120, width: (UIScreen.main.bounds.width-160)/2, height: 30))
    let w1 = TimeInput(frame: CGRect(x: 100, y: 160, width: (UIScreen.main.bounds.width-160)/2, height: 30))
    let w2 = TimeInput(frame: CGRect(x: 130+(UIScreen.main.bounds.width-140)/2, y: 160, width: (UIScreen.main.bounds.width-160)/2, height: 30))
    let th1 = TimeInput(frame: CGRect(x: 100, y: 200, width: (UIScreen.main.bounds.width-160)/2, height: 30))
    let th2 = TimeInput(frame: CGRect(x: 130+(UIScreen.main.bounds.width-140)/2, y: 200, width: (UIScreen.main.bounds.width-160)/2, height: 30))
    let f1 = TimeInput(frame: CGRect(x: 100, y: 240, width: (UIScreen.main.bounds.width-160)/2, height: 30))
    let f2 = TimeInput(frame: CGRect(x: 130+(UIScreen.main.bounds.width-140)/2, y: 240, width: (UIScreen.main.bounds.width-160)/2, height: 30))
    let sa1 = TimeInput(frame: CGRect(x: 100, y: 280, width: (UIScreen.main.bounds.width-160)/2, height: 30))
    let sa2 = TimeInput(frame: CGRect(x: 130+(UIScreen.main.bounds.width-140)/2, y: 280, width: (UIScreen.main.bounds.width-160)/2, height: 30))
    let su1 = TimeInput(frame: CGRect(x: 100, y: 320, width: (UIScreen.main.bounds.width-160)/2, height: 30))
    let su2 = TimeInput(frame: CGRect(x: 130+(UIScreen.main.bounds.width-140)/2, y: 320, width: (UIScreen.main.bounds.width-160)/2, height: 30))
    
    init(){
        super .init(title: "opening hours")
        scroll.addSubview(open)
        open.layer.borderWidth = 0
        
        var i = 0
        for day in ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]{
            let label = UILabel(frame: CGRect(x: 10, y: 80+CGFloat(i)*40, width: 80, height: 30))
            label.text = day
            scroll.addSubview(label)
            label.font = Settings.shared.font
            
            let dash = UILabel(frame: CGRect(x: (UIScreen.main.bounds.width-160)/2 + 100, y: 80+CGFloat(i)*40, width: 40, height: 30))
            dash.font = Settings.shared.font
            scroll.addSubview(dash)
            dash.text = "-"
            dash.textAlignment = .center
            
            
            i += 1
        }
        
        i = 0
        for time in [m1,m2,t1,t2,w1,w2,th1,th2,f1,f2,sa1,sa2,su1,su2]{
            scroll.addSubview(time)
            time.tag = i
            i += 1
        }
        
        Firebase.shared.getBusinessSettings(self)
        
    }
    
    func get(_ i: Int) -> TimeInput{
        return [m1,m2,t1,t2,w1,w2,th1,th2,f1,f2,sa1,sa2,su1,su2][i]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TimeInput: UIView{
    
    let hours: UITextField
    let minutes: UITextField
    
    override init(frame: CGRect) {
        self.hours = UITextField(frame: CGRect(x: 0, y: 0, width: frame.width/2-10, height: frame.height))
        self.minutes = UITextField(frame: CGRect(x: frame.width/2+10, y: 0, width: frame.width/2-10, height: frame.height))
        super .init(frame: frame)
        
        let colon = UILabel(frame: CGRect(x: frame.width/2-10, y: 0, width: 20, height: frame.height))
        colon.text = ":"
        colon.font = Settings.shared.font
        colon.textAlignment = .center
        addSubview(colon)
        
        for field in [hours,minutes]{
            field.layer.cornerRadius = 4
            field.backgroundColor = .white
            field.textColor = .black
            field.font = Settings.shared.font
            field.textAlignment = .center
            field.keyboardType = .numberPad
            field.keyboardAppearance = .alert
            addSubview(field)
            field.addTarget(self, action: #selector(submit), for: .allEvents)
        }
        
        hours.timeHour()
        minutes.timeMin()
    }
    
    func update(_ time: String){
        hours.text = String(time.split(separator: ":")[0])
        minutes.text = String(time.split(separator: ":")[1])
    }
    
    @objc func submit(){
        let day = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"][tag/2]
        let ooc = ["open","close"][tag%2]
        let time = "\(hours.text!):\(minutes.text!)"
        Firebase.shared.updateOpening(day, ooc: ooc, time)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
