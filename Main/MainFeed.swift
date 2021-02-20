//
//  MainFeed.swift
//  Kaktus
//
//  Created by Karl Cridland on 12/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class MainFeed: HomePage, UIScrollViewDelegate{
    
    let upcoming = FeedContainer(type: .upcoming)
    let feed = FeedContainer(type: .standard)
    
    init() {
        let buf = Settings.shared.upper_bound+90
        super .init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-buf))
        
        addSubview(upcoming)
        addSubview(feed)
    }
    
    func update(){
        for user in Settings.shared.events.keys{
            let events = Settings.shared.events[user]!
            for event in events.keys{
                if let e = events[event]{
                    if e.date > Date(){
                        if !upcoming.events.contains(where: {(($0.date == e.date) && ($0.uid == e.uid))}){
                            upcoming.append(e)
                        }
                    }
                    else{
                        if !feed.events.contains(where: {(($0.date == e.date) && ($0.uid == e.uid))}){
                            feed.append(e)
                        }
                    }
                }
            }
            feed.update()
            upcoming.update()
        }
    }
    
    func remove(_ event: Event){
        if event.date > Date(){
            upcoming.remove(event)
        }
        else{
            feed.remove(event)
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let feed = scrollView.accessibilityElements![0] as? FeedContainer{
            if let event = feed.current(){
                event.load()
            }
            feed.first = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

