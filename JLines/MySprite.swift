//
//  MyButton.swift
//  JLinesV2
//
//  Created by Jozsef Romhanyi on 29.04.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit

class MySprite: UIButton {
    let spriteFont = UIFont(name:"Times New Roman", size: GV.onIpad ? 20 : 10)
    var startTime: NSDate
    var lebensDauer: Double
    var timer = NSTimer()
    var callBackWhenExit: (MySprite)->()
    var index: Int
    let type = "MySprite"
    
    static var spritesCount = 0
    
    init(callBack:(MySprite)->(), index: Int) {
        startTime = NSDate()
        lebensDauer = Double(GV.random(10, max:15))
        self.callBackWhenExit = callBack
        self.index = index
        super.init(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("countDown"), userInfo: nil, repeats: true)
        self.setTitle("\(lebensDauer)", forState: .Normal)
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
        self.titleLabel?.font = spriteFont
        MySprite.spritesCount++
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func countDown() {
        lebensDauer--
        self.setTitle("\(lebensDauer)", forState: .Normal)
        if lebensDauer == 0 {
            callBackWhenExit(self)
            self.removeFromSuperview()
        }
    }
    
    func getLebensDauer() -> Double {
        let aktZeit = NSDate()
        return aktZeit.timeIntervalSinceDate(startTime) * 1000 / 1000
    }
    
    func stopObject() {
        self.removeFromSuperview()
    }
    
    deinit {
        MySprite.spritesCount--
        println("deinit. Count:\(MySprite.spritesCount)")
    }
    
    
}

