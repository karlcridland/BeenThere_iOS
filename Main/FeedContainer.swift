//
//  FeedContainer.swift
//  Been There
//
//  Created by Karl Cridland on 13/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

class FeedContainer: UIView{
    
    let type: eventType
    var scroll: UIScrollView
    let header: UILabel
    
    var first = true
    
    var events = [Event]()
    
    private var wait = false
    private var original: Event?
    
    init(type: eventType){
        self.type = type
        let height = (UIScreen.main.bounds.height-Settings.shared.upper_bound-40)/2 - 25
        self.scroll = UIScrollView(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: height-20))
        self.header = UILabel(frame: CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width-20, height: 20))
        switch type {
        case .standard:
            super .init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height))
            header.text = "feed"
            break
        case .upcoming:
            super .init(frame: CGRect(x: 0, y: height, width: UIScreen.main.bounds.width, height: height))
            header.text = "upcoming"
            break
        case .local:
            super .init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height))
            header.text = "near me"
            break
        case .worldwide:
            super .init(frame: CGRect(x: 0, y: height, width: UIScreen.main.bounds.width, height: height))
            header.text = "worldwide"
            break
        case .business:
            super .init(frame: CGRect(x: 0, y: 150, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-Settings.shared.upper_bound-110))
            scroll.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-Settings.shared.upper_bound-130)
            header.text = "feed"
            break
        case .takelook:
            super .init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-Settings.shared.upper_bound-110))
            scroll = TALScrollView(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height-Settings.shared.upper_bound-40)/2 - 45))
            header.text = "take a look"
            break
        }
        addSubview(header)
        addSubview(scroll)
        header.textColor = .white
        header.font = Settings.shared.font
        scroll.isPagingEnabled = true
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: {_ in
            if let feed = Settings.shared.home?.container?.feed{
                self.scroll.delegate = feed
            }
        })
        scroll.accessibilityElements = [self]
        scroll.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2965539384)
        
        backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
    }
    
    func isWaiting() -> Bool{
        return wait
    }
    
    func append(_ event: Event){
        events.append(event)
        if events.count == 0{
            original = event
        }
    }
    
    func remove(_ event: Event){
        let widget = getWidget(event)
        for subview in scroll.subviews{
            if subview.center.x > widget!.center.x{
                subview.center = CGPoint(x: subview.center.x - widget!.frame.width, y: subview.center.y)
            }
        }
        scroll.contentSize = CGSize(width: scroll.contentSize.width - widget!.frame.width, height: scroll.frame.height)
        widget?.removeFromSuperview()
        events.removeAll(where: {$0.date == event.date && $0.uid == event.uid})
    }
    
    func update(){
        
        if !wait{
            events = events.sorted(by: {$0 > $1})
            if type == .upcoming{
                events = events.reversed()
            }
            if type == .local || type == .worldwide{
                events = events.sorted(by: {$0.likes > $1.likes})
            }
            var uid: String?
            var date: Date?
            if let c = current(){
                uid = c.event.uid
                date = c.event.date
            }
            var i = 0
            for event in events{
                if !scroll.subviews.contains(where: {isWidgetOnScreen($0, event)}){
                    var widget: Widget?
                    if event.tal{
//                        widget = WidgetTakeALook(title: "", frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height-Settings.shared.upper_bound-60)/2 - 25), uid: event.uid)
                    }
                    else{
                        widget = WidgetEvent(event: event)
                        if event.date > Date(){
                            widget = WidgetUpcoming(event: event)
                        }
                        widget!.frame = CGRect(x: UIScreen.main.bounds.width*CGFloat(i), y: 0, width: widget!.frame.width, height: widget!.frame.height)
                        if events.count <= 5{
                            (widget as! WidgetEvent).load()
                        }
                        scroll.addSubview(widget!)
                    }
                }
                else{
                    if let widget = getWidget(event){
                        widget.frame = CGRect(x: UIScreen.main.bounds.width*CGFloat(i), y: 0, width: widget.frame.width, height: widget.frame.height)
                    }
                }
                i += 1
            }
            scroll.contentSize = CGSize(
                width: CGFloat(events.count)*UIScreen.main.bounds.width,
                height: scroll.frame.height
            )
            if first{
                scroll.contentOffset = CGPoint(x: 0, y: 0)
            }
            else{
                for subview in scroll.subviews{
                    if let widget = subview as? WidgetEvent{
                        if let u = uid{
                            if let d = date{
                                if widget.event.uid == u && widget.event.date == d{
                                    scroll.contentOffset = CGPoint(x: widget.frame.minX, y: 0)
                                }
                            }
                        }
                    }
                }
            }
        }
        first = false
    }
    
    func current() -> WidgetEvent?{
        let offset = scroll.contentOffset.x + scroll.frame.width/2
        var min = scroll.frame.width
        var event: WidgetEvent?
        var found = false
        for subview in scroll.subviews{
            if subview is WidgetEvent{
                let dist = abs(offset - subview.center.x)
                if dist < min{
                    min = dist
                    event = (subview as! WidgetEvent)
                    found = true
                }
            }
        }
        if found{
            return event
        }
        else{
            return nil
        }
    }
    
    func minX() -> CGFloat{
        var x = CGFloat(0.0)
        for subview in scroll.subviews{
            if (subview.frame.maxX > x) && (subview is WidgetEvent){
                x = subview.frame.maxX
            }
        }
        return x
    }
    
    private func isWidgetOnScreen(_ view: UIView, _ event: Event) -> Bool{
        if let widget = view as? WidgetEvent{
            return widget.event.date == event.date && widget.event.uid == event.uid
        }
        return false
    }
    
    private func getWidget(_ event: Event) -> WidgetEvent?{
        for subview in scroll.subviews{
            if let widget = subview as? WidgetEvent{
                if widget.event.date == event.date && widget.event.uid == event.uid{
                    return widget
                }
            }
        }
        return nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum eventType{
        case standard
        case upcoming
        case business
        case local
        case worldwide
        case takelook
    }
}
