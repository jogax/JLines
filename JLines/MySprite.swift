//
//  MyButton.swift
//  JLinesV2
//
//  Created by Jozsef Romhanyi on 29.04.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit

class MySprite: UIButton {
    var startTime: NSDate
    var lebensDauer: CGFloat
    
    static var spritesCount = 0
    
    init() {
        startTime = NSDate()
        lebensDauer = CGFloat(GV.random(3, max:10))
        super.init(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
        doInit()
    }
    
    func doInit() {
        setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.layer.cornerRadius = 8
        self.setupDepression()
        self.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSizeMake(1, 1)
        self.layer.shadowOpacity = 1.0
        self.backgroundColor = GV.backgroundColor//GV.PeachPuffColor
        MySprite.spritesCount++
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getLebensDauer() -> Double {
        let aktZeit = NSDate()
        return aktZeit.timeIntervalSinceDate(startTime) * 1000 / 1000
    }
    
    
}

