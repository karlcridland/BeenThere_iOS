//
//  TALScrollView.swift
//  Been There
//
//  Created by Karl Cridland on 23/09/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class TALScrollView: UIScrollView {
    
    var images = [TALImage]()
    var deleted = [String]()
    var uid: String?
    
    var special: TALImage?
    
    override init(frame: CGRect){
        super .init(frame: frame)
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
            Firebase.shared.updateTAL(self)
        })
    }
    
    func append(_ image: UIImage, _ ref: String){
        print(image,ref)
        var max = -1
        for image in images{
            if image.position > max{
                max = image.position
            }
        }
        let new = TALImage(position: max + 1, ref: ref, image: image, tal: self)
        images.append(new)
        addSubview([new,new.fs,new.delete,new.left,new.right])
        
        expandScroll()
    }
    
    func expandScroll(){
        var maxY = CGFloat(0.0)
        for subview in self.subviews{
            if maxY < subview.frame.maxY{
                maxY = subview.frame.maxY
            }
        }
        self.contentSize = CGSize(width: UIScreen.main.bounds.width, height: maxY)
        isPagingEnabled = false
    }
    
    func update(){
        images.sort(by: {$0.position < $1.position})
        var i = 0
        var temp = [TALImage]()
        for image in images{
            image.left.isHidden = false
            image.right.isHidden = false
            if let special = special{
                if i == special.position{
                    temp.append(image)
                    i += 1
                }
                if image != special{
                    temp.append(image)
                    image.position = i
                    image.relocate()
                    if uid == Settings.shared.get().uid{
                        Firebase.shared.updateTAL(image)
                    }
                }
            }
            else{
                temp.append(image)
                image.position = i
                image.relocate()
                if uid == Settings.shared.get().uid{
                    Firebase.shared.updateTAL(image)
                }
            }
            i += 1
        }
        images = temp
        expandScroll()
        images.first?.left.isHidden = true
        images.last?.right.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TALImage: UIImageView {
    
    var position: Int
    let ref: String
    let uid: String
    let tal: TALScrollView
    
    let delete = UIButton()
    let left = UIButton()
    let right = UIButton()
    let fs = UIButton()
    
    init(position: Int, ref: String, uid: String, tal: TALScrollView){
        self.position = position
        self.ref = ref
        self.uid = uid
        self.tal = tal
        super .init(frame: .zero)
        Firebase.shared.getTALImage(self)
        doBits()
    }
    
    init(position: Int, ref: String, image: UIImage, tal: TALScrollView){
        self.position = position
        self.ref = ref
        self.uid = Settings.shared.get().uid
        self.tal = tal
        super .init(frame: .zero)
        self.image = image
        doBits()
    }
    
    func doBits(){
        frame = location()
        contentMode = .scaleAspectFill
        clipsToBounds = true
        delete.setImage(UIImage(named: "delete"), for: .normal)
        delete.addTarget(self, action: #selector(confirmDelete), for: .touchUpInside)
        delete.frame = CGRect(x: frame.minX + 5, y: frame.minY + UIScreen.main.bounds.width/2 - 30, width: 25, height: 25)
        left.frame = CGRect(x: frame.minX + 5, y: frame.minY + 5, width: 25, height: 25)
        right.frame = CGRect(x: frame.minX + frame.width - 30, y: frame.minY + 5, width: 25, height: 25)
        fs.frame = frame
        
        left.setImage(UIImage(named: "arrow2"), for: .normal)
        right.setImage(UIImage(named: "arrow2"), for: .normal)
        left.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        
        left.addTarget(self, action: #selector(moveLeft), for: .touchUpInside)
        right.addTarget(self, action: #selector(moveRight), for: .touchUpInside)
        fs.addTarget(self, action: #selector(openFullScreen), for: .touchUpInside)
    }
    
    @objc func confirmDelete(){
        tal.deleted.append(ref)
        tal.images.removeAll(where: {$0 == self})
        self.removeFromSuperview()
        self.delete.removeFromSuperview()
        self.left.removeFromSuperview()
        self.right.removeFromSuperview()
        tal.update()
        
        Firebase.shared.deleteTALImage(self)
    }
    
    func location() -> CGRect{
        let length = UIScreen.main.bounds.width/2
        return CGRect(x: length * CGFloat(position%2), y: length * CGFloat(position/2), width: length, height: length)
    }
    
    func relocate(){
        UIView.animate(withDuration: 0.4, animations: {
            self.frame = self.location()
            self.delete.frame = CGRect(x: self.frame.minX + 5, y: self.frame.minY + UIScreen.main.bounds.width/2 - 30, width: 25, height: 25)
            self.left.frame = CGRect(x: self.frame.minX + 5, y: self.frame.minY + 5, width: 25, height: 25)
            self.right.frame = CGRect(x: self.frame.minX + self.frame.width - 30, y: self.frame.minY + 5, width: 25, height: 25)
            self.fs.frame = self.frame
        })
    }
    
    @objc func moveLeft(){
        if position > 0{
            if let image = tal.images.first(where: {$0.position == position-1}){
                image.position = position
                position = position-1
            }
        }
        tal.update()
    }
    
    @objc func moveRight(){
        if position < tal.images.count-1{
            if let image = tal.images.first(where: {$0.position == position+1}){
                image.position = position
                position = position+1
            }
        }
        tal.update()
    }
    
    @objc func openFullScreen(){
        let _ = TALFullScreen(images: tal.images, start: position)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TALFullScreen: UIScrollView {
    
    init(images: [TALImage], start: Int) {
        super .init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.793557363)
        showsHorizontalScrollIndicator = false
        
        var i = 0
        for image in images{
            let new = UIImageView(frame: CGRect(x: CGFloat(i)*UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            new.image = image.image
            addSubview(new)
            new.contentMode = .scaleAspectFit
            i += 1
        }
        
        contentSize = CGSize(width: UIScreen.main.bounds.width*CGFloat(i), height: UIScreen.main.bounds.height)
        let remove = UIButton(frame: CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height))
        addSubview(remove)
        remove.addTarget(self, action: #selector(disappear), for: .touchUpInside)
        
        if let home = Settings.shared.home{
            home.view.addSubview(self)
        }
        isPagingEnabled = true
        contentOffset = CGPoint(x: CGFloat(start)*UIScreen.main.bounds.width, y: 0)
    }
    
    @objc func disappear(){
        removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
