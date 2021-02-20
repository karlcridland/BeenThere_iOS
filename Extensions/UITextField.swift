//
//  UITextField.swift
//  Been There
//
//  Created by Karl Cridland on 20/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

extension UITextField{
    
    func makePounds(){
        addTarget(self, action: #selector(pounds), for: .allEvents)
    }
    
    @objc private func pounds(){
        text?.removeAll(where: {!$0.isNumber})
    }
    
    func makeChange(){
        addTarget(self, action: #selector(pence), for: .allEvents)
    }
    
    @objc private func pence(){
        text?.removeAll(where: {!$0.isNumber})
        if text != nil{
            while text!.count > 2{
                text?.removeLast()
            }
        }
    }
    
    func timeMin(){
        addTarget(self, action: #selector(minutes), for: .allEvents)
    }
    
    @objc private func minutes(){
        text?.removeAll(where: {!$0.isNumber})
        if text != nil{
            while text!.count > 2{
                text?.removeLast()
            }
            if let m = Int(text!){
                if m > 59{
                    text = "59"
                }
            }
        }
    }
    
    func timeHour(){
        addTarget(self, action: #selector(hours), for: .allEvents)
    }
    
    @objc private func hours(){
        text?.removeAll(where: {!$0.isNumber})
        if text != nil{
            while text!.count > 2{
                text?.removeLast()
            }
            if let m = Int(text!){
                if m > 23{
                    text = "23"
                }
            }
        }
    }
}
