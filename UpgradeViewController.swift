//
//  UpgradeViewController.swift
//  Been There
//
//  Created by Karl Cridland on 21/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import UIKit
import StoreKit

class UpgradeViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var myProduct: SKProduct?
    var gl: CAGradientLayer?
    let t = UILabel(frame: CGRect(x: 20, y: 60 + Settings.shared.upper_bound, width: 200, height: 50))
    let cancel = UIButton(frame: CGRect(x: 20, y: Settings.shared.upper_bound, width: 80, height: 30))
    let info = UITextView(frame: CGRect(x: 20, y: 160 + Settings.shared.upper_bound, width: UIScreen.main.bounds.width-40, height: 300))
    var secondary = UIColor()
    
    var tier: TierCategory?
    var tempPrice: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 32
        view.clipsToBounds = true
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = .light
        }
        
        cancel.addTarget(self, action: #selector(remove), for: .touchUpInside)
        cancel.setTitle("cancel", for: .normal)
        cancel.setTitleColor(.white, for: .normal)
        cancel.titleLabel?.font = Settings.shared.font
        view.addSubview(cancel)
        
        t.font = Settings.shared.font
        t.increase(30)
        view.addSubview(t)
        
        info.clipsToBounds = true
        info.layer.cornerRadius = 5
        info.isEditable = false
        info.textColor = .white
        info.font = Settings.shared.font
        view.addSubview(info)
        
    }
    
    func fetchProducts(tier: TierCategory){
        self.tier = tier
        switch tier {
        case .gold:
            let request = SKProductsRequest(productIdentifiers: ["com.beenthere.gold"])
            request.delegate = self
            request.start()
            
            self.secondary = #colorLiteral(red: 0.6638882756, green: 0.6557548046, blue: 0.2578871548, alpha: 1).withAlphaComponent(0.6)
            self.gl = Colors(top: #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1), bottom: #colorLiteral(red: 0.830920279, green: 0.7484388351, blue: 0.1663301885, alpha: 1)).gl
            
            info.text = "Benefits of becoming a gold tiered member:\n\n  • Your posts will show on a users home feed if they are within the distance you have set, this can be a maximum of 100km\n\n  • This will appear on up to 500 users daily\n\n  • Increased Exposure of your business"
            break
        case .silver:
            let request = SKProductsRequest(productIdentifiers: ["com.beenthere.silver"])
            request.delegate = self
            request.start()
            self.secondary = #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 1).withAlphaComponent(0.6)
            self.gl = Colors(top: #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1), bottom: #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)).gl
            
            info.text = "Benefits of becoming a silver tiered member:\n\n  • Your posts will show on a users home feed if you are within the distance they have set, this can be a minimum of 5km\n\n  • This will appear on up to 100 users daily\n\n  • Increased Exposure of your business"
            break
        }
        gl!.frame = view.bounds
        view.layer.addSublayer(gl!)
        
        view.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height)
        UIView.animate(withDuration: 0.2, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        })
        
        for a in [t,cancel,info]{
            view.bringSubviewToFront(a)
        }
        t.text = tier.rawValue
        t.textColor = secondary.withAlphaComponent(1.0)
        
        info.backgroundColor = secondary
        
        let purchase = Purchase(tier: tier, frame: CGRect(x: view.frame.width-120, y: Settings.shared.upper_bound+70, width: 100, height: 30), with: didTapToBuy)
        view.addSubview(purchase)
        purchase.alpha = 0.4
        
        let tickbox = CButton(frame: CGRect(x: 35, y: 465, width: 25, height: 25))
        tickbox.addTarget(self, action: #selector(disclaimed), for: .touchUpInside)
        view.addSubview(tickbox)
        tickbox.accessibilityElements = [purchase]
        
        let tickText = UILabel(frame: CGRect(x: 70, y: 450, width: view.frame.width-90, height: 60))
        tickText.text = "tick to confirm this is the only Apple ID associated with this business"
        tickText.font = Settings.shared.font
        tickText.numberOfLines = 0
        tickText.textAlignment = .left
        tickText.textColor = .white
        view.addSubview(tickText)
        
        cancel.backgroundColor = secondary
        cancel.layer.cornerRadius = cancel.frame.height/2
        
        let terms = UIButton(frame: CGRect(x: 20, y: info.frame.maxY+20, width: info.frame.width, height: 30))
        let privacy = UIButton(frame: CGRect(x: 20, y: terms.frame.maxY+10, width: info.frame.width, height: 30))
        terms.setTitle("Terms & Conditions", for: .normal)
        privacy.setTitle("Privacy Policy", for: .normal)
        terms.setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: .normal)
        terms.contentHorizontalAlignment = .left
        terms.titleLabel?.font = Settings.shared.font
        terms.addTarget(self, action: #selector(openTerms), for: .touchUpInside)
        privacy.setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: .normal)
        privacy.contentHorizontalAlignment = .left
        privacy.titleLabel?.font = Settings.shared.font
        privacy.addTarget(self, action: #selector(openPrivacy), for: .touchUpInside)
        view.addSubview([terms,privacy])
    }
    
    @objc func openTerms(){
        if let url = URL(string: "https://been-there.co.uk/terms-conditions.html") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func openPrivacy(){
        if let url = URL(string: "https://been-there.co.uk/privacy-policy.html") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func disclaimed(sender: CButton){
        if let purchase = sender.accessibilityElements![0] as? Purchase{
            if sender.isChecked{
                purchase.alpha = 1.0
                purchase.ready = true
            }
            else{
                purchase.alpha = 0.4
                purchase.ready = false
            }
        }
    }
    
    func getPrice(_ identifier: String, _ label: UILabel){
        tempPrice = label
        let request = SKProductsRequest(productIdentifiers: [identifier])
        request.delegate = self
        request.start()
    }
    
    @objc func didTapToBuy(){
        guard let myProduct = myProduct else{
            return
        }
        
        if SKPaymentQueue.canMakePayments(){
            let payment = SKPayment(product: myProduct)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        if let product = response.products.first{
            myProduct = product
            if let p = product.priceLocale.currencySymbol{
                if let label = tempPrice{
                    
                    label.text = "\(p)\(product.price)"
                    print("\(p)\(product.price)")
                }
//                tempPrice =
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions{
            switch transaction.transactionState {
            case .purchasing:
                break
            case .purchased, .restored:
                
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                remove()
                Firebase.shared.updateTier(tier!)
                if let reference = transaction.transactionIdentifier{
                    Firebase.shared.logTierPurchase(tier!, reference)
                }
                if let magnify = Settings.shared.home?.container?.pages.last as? PageMagnify{
                    magnify.setTier(tier!)
                }
                break
            case .failed, .deferred:
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                remove()
                break
            default:
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
            }
        }
    }

    @objc func remove(){
        if let home = Settings.shared.home{
            if let vc = home.storyboard?.instantiateViewController(withIdentifier: "upgrade") as? UpgradeViewController {
                vc.title = "upgrate tier"
                home.navigationController?.popViewController(animated: true)
                removeFromParent()
                view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
                })
                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { _ in
                    self.view.removeFromSuperview()
                    UIApplication.shared.windows.forEach { window in
                        window.overrideUserInterfaceStyle = .dark
                    }
                })
            }
        }
    }
}

class Purchase: UIButton{
    
    var hasTapped = false
    let action: () -> Void
    var width = CGFloat(0.0)
    var ready = false
    
    init(tier: TierCategory, frame: CGRect, with completion: @escaping () -> Void) {
        
        self.action = completion
        super .init(frame: frame)
        
        switch tier {
        case .silver:
            width = "£9.99".width(font: Settings.shared.font!)
            setTitle("£9.99", for: .normal)
            break
        case .gold:
            setTitle("£14.99", for: .normal)
            width = "£14.99".width(font: Settings.shared.font!)
            break
        }

        self.frame = CGRect(x: frame.maxX-width-20, y: frame.minY, width: width+20, height: frame.height)
        titleLabel!.font = Settings.shared.font
        setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: .normal)
        layer.borderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        layer.borderWidth = 3
        layer.cornerRadius = 6
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }
    
    @objc func tapped(){
        if ready{
            if !hasTapped{
                UIView.animate(withDuration: 0.1, animations: {
                    self.frame = CGRect(x: self.frame.maxX-100, y: self.frame.minY, width: 100, height: self.frame.height)
                    self.setTitle("subscribe", for: .normal)
                })
                hasTapped = true
            }
            else{
                action()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
