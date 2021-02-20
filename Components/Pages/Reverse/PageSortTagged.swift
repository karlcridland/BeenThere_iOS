//
//  PageSortTagged.swift
//  Been There
//
//  Created by Karl Cridland on 16/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageSortTagged: PageReverse {
    
    var pictures = [Int:[Int:[TaggedImage]]]()
    
    init() {
        super .init(title: "review tags")
        Firebase.shared.getTagged(self)
    }
    
    func sortPictures(){
        scroll.removeAll()
        if let latest = showLatest(){
            scroll.addSubview(latest)
            latest.center = CGPoint(x: latest.center.x, y: frame.height/2 - 50)
            let question = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
            question.text = "are you in this picture?"
            question.font = Settings.shared.font
            question.textColor = .white
            question.textAlignment = .center
            scroll.addSubview(question)
            
            let banner = UIView(frame: CGRect(x: 0, y: latest.frame.maxY, width: UIScreen.main.bounds.width, height: 60))
            banner.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 0.672062286)
            scroll.addSubview(banner)
            let yes = UIButton(frame: CGRect(x: frame.width/2+10, y: 10, width: frame.width/2-20, height: 40))
            yes.setTitle("yes", for: .normal)
            let no = UIButton(frame: CGRect(x: 10, y: 10, width: frame.width/2-20, height: 40))
            no.setTitle("no", for: .normal)
            yes.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
            no.backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
            for button in [yes,no]{
                button.layer.cornerRadius = 4
                button.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                button.layer.borderWidth = 2.0
                button.backgroundColor = button.backgroundColor?.withAlphaComponent(0.6)
                banner.addSubview(button)
            }
            scroll.contentSize = CGSize(width: frame.width, height: banner.frame.maxY)
            
            yes.addTarget(self, action: #selector(confirm), for: .touchUpInside)
            no.addTarget(self, action: #selector(deny), for: .touchUpInside)
        }
        else{
            let text = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400))
            text.text = "there are no pictures to review."
            text.font = Settings.shared.font
            text.textColor = .white
            text.textAlignment = .center
            scroll.addSubview(text)
        }
    }
    
    func showLatest() -> TaggedImage?{
        for year in pictures.keys.sorted().reversed(){
            for month in pictures[year]!.keys.sorted().reversed(){
                for picture in pictures[year]![month]!{
                    if let size = picture.image?.size{
                        let height = UIScreen.main.bounds.width/(size.width/size.height)
                        picture.frame = CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: height)
                    }
                    return picture
                }
            }
        }
        return nil
    }
    
    @objc func confirm(){
        if let latest = showLatest(){
            Firebase.shared.tagConfirmed(latest)
            remove()
        }
    }
    
    @objc func deny(){
        if let latest = showLatest(){
            Firebase.shared.tagDenied(latest)
            remove()
        }
    }
    
    func remove(){
        if let latest = showLatest(){
            for year in pictures.keys.sorted().reversed(){
                for month in pictures[year]!.keys.sorted().reversed(){
                    var pics = pictures[year]![month]!
                    if pics.contains(where: {$0.event == latest.event && $0.uid == latest.uid}){
                        pics.removeAll(where: {$0.event == latest.event && $0.uid == latest.uid})
                    }
                    pictures[year]![month]! = pics
                }
            }
        }
        sortPictures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
