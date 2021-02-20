//
//  PageMagnify.swift
//  Been There
//
//  Created by Karl Cridland on 21/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class PageMagnify: PageReverse{
    
    let silver = Tier(tier: .silver)
    let gold = Tier(tier: .gold)
    let managed: Bool
    
    init(managed: Bool) {
        self.managed = managed
        super .init(title: "magnify")
        
        let ad = UILabel(frame: CGRect(x: 10, y: 10, width: frame.width-20, height: 100))
        ad.text = "magnify who sees your posts and increase your popularity.."
        ad.font = Settings.shared.font
        ad.numberOfLines = 0
        ad.textColor = .white
        scroll.addSubview(ad)
        
        scroll.addSubview(silver)
        scroll.addSubview(gold)
        
        scroll.contentSize = CGSize(width: scroll.frame.width, height: gold.frame.maxY)
        
        Firebase.shared.getTier(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTier(_ tier: TierCategory){
        func removePrevious(_ t: Tier){
            for subview in t.subviews{
                if subview.tag == -1{
                    subview.removeFromSuperview()
                }
            }
        }
        switch tier{
        case .silver:
            silver.already()
            removePrevious(gold)
            break
        case .gold:
            gold.already()
            removePrevious(silver)
            break
        }
        if managed{
            Settings.shared.home?.container?.remove()
            background.removeFromSuperview()
            Settings.shared.home?.container?.append(PageMagnifyManage(tier: tier))
        }
    }
    
}

class Tier: UIView{
    
    let tier: TierCategory
    let desc: UITextView
    let title: UILabel
    let gl: CAGradientLayer
    let secondary: UIColor
    let price: Int
    
    init(tier: TierCategory) {
        
        self.tier = tier
        self.title = UILabel(frame: CGRect(x: 10, y: 10, width: (UIScreen.main.bounds.width-20)/2, height: 20))
        self.desc = UITextView(frame: CGRect(x: 10, y: 40, width: UIScreen.main.bounds.width-40, height: 150))
        
        switch tier{
            
        case .silver:
            self.secondary = #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 1).withAlphaComponent(0.6)
            self.gl = Colors(top: #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1), bottom: #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)).gl
            self.price = 999
            super .init(frame: CGRect(x: 10, y: 120, width: UIScreen.main.bounds.width-20, height: 200))
            desc.text = "Increase the number of people who will have access your posts. Your posts will display as a featured post in the feed of users who do not follow you if you are within in range of the distance limit they have set (min 5km)."
            break
            
        case .gold:
            self.secondary = #colorLiteral(red: 0.6638882756, green: 0.6557548046, blue: 0.2578871548, alpha: 1).withAlphaComponent(0.6)
            self.gl = Colors(top: #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1), bottom: #colorLiteral(red: 0.830920279, green: 0.7484388351, blue: 0.1663301885, alpha: 1)).gl
            self.price = 1499
            super .init(frame: CGRect(x: 10, y: 340, width: UIScreen.main.bounds.width-20, height: 200))
            desc.text = "Access an even larger range of potential customers, recieve the perks of the silver tier but choose the range in which your posts will reach (max 100km)."
            break
            
        }
        
        gl.frame = bounds
        layer.addSublayer(gl)
        title.text = tier.rawValue
        addSubview(desc)
        addSubview(title)
        
        title.font = Settings.shared.font
        desc.font = Settings.shared.font
        desc.backgroundColor = secondary
        desc.layer.cornerRadius = 8
        desc.isEditable = false
        desc.textColor = .white
        
        title.frame = CGRect(x: 10, y: 10, width: (title.text?.width(font: title.font))!+20, height: 20)
        title.clipsToBounds = true
        title.textAlignment = .center
        title.backgroundColor = secondary
        title.layer.cornerRadius = 10
        title.textColor = .white
        
        layer.cornerRadius = 16
        clipsToBounds = true
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        addSubview(button)
        button.addTarget(self, action: #selector(clicked), for: .touchUpInside)
        
        let pWidth = "\(price.price(currency: .GBP))/mo".width(font: Settings.shared.font!)
        let pLabel = UILabel(frame: CGRect(x: frame.width-pWidth-60, y: 10, width: pWidth+20, height: 20))
        pLabel.text = "\(price.price(currency: .GBP))/mo"
        pLabel.backgroundColor = secondary
        pLabel.layer.cornerRadius = 10
        pLabel.clipsToBounds = true
        pLabel.font = Settings.shared.font
        pLabel.textAlignment = .center
        pLabel.textColor = .white
        addSubview(pLabel)
        
        if let home = Settings.shared.home{
            if let vc = home.storyboard?.instantiateViewController(withIdentifier: "upgrade") as? UpgradeViewController {
                vc.getPrice("com.beenthere.gold", pLabel)
            }
        }
        
        let arrow = UIImageView(frame: CGRect(x: frame.width-30, y: 10, width: 20, height: 20))
        arrow.image = UIImage(named: "arrow2")
        arrow.layer.cornerRadius = 10
        arrow.clipsToBounds = true
        arrow.backgroundColor = secondary
        addSubview(arrow)
        
    }
    
    func already(){
        let subscribed = UILabel(frame: CGRect(x: title.frame.maxX+10, y: 10, width: "subscribed".width(font: Settings.shared.font!)+20, height: 20))
        subscribed.text = "subscribed"
        subscribed.tag = -1
        subscribed.font = Settings.shared.font
        subscribed.textAlignment = .center
        subscribed.backgroundColor = secondary
        subscribed.layer.cornerRadius = 10
        subscribed.clipsToBounds = true
        subscribed.textColor = .white
        addSubview(subscribed)
    }
    
    @objc func clicked(){
        if let home = Settings.shared.home{
            if let vc = home.storyboard?.instantiateViewController(withIdentifier: "upgrade") as? UpgradeViewController {
                vc.title = "upgrate tier"
                home.navigationController?.pushViewController(vc, animated: true)
                home.addChild(vc)
                vc.view.translatesAutoresizingMaskIntoConstraints = false
                home.view.addSubview(vc.view)
                vc.fetchProducts(tier: tier)
            }
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum TierCategory: String{
    case silver
    case gold
}

class Colors {
    var gl:CAGradientLayer!

    init(top: UIColor, bottom: UIColor) {
        self.gl = CAGradientLayer()
        self.gl.colors = [top.cgColor, bottom.cgColor]
        self.gl.locations = [0.0, 1.0]
    }
}
