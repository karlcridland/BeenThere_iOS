//
//  PageComments.swift
//  Been There
//
//  Created by Karl Cridland on 23/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class PageComments: Page {
    
    let event: WidgetEvent
    var comments = [Comment]()
    
    init(_ event: WidgetEvent){
        self.event = event
        super .init(title: "comments")
        Firebase.shared.getComments(self)
    }
    
    func newComment(){
        let _ = NewComment(page: self)
    }
    
    func display(){
        var h = CGFloat(0.0)
        for comment in comments.sorted(by: {$0.date > $1.date}){
            scroll.addSubview(comment)
            comment.frame = CGRect(x: comment.frame.minX, y: 5+h, width: comment.frame.width, height: comment.frame.height)
            h += comment.frame.height+5
        }
        scroll.contentSize = CGSize(width: scroll.frame.width, height: h)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
