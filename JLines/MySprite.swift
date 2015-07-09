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
    var first = true
    let type = "MySprite"
    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    
    static var spritesCount = 0
    
    init(callBack:(MySprite)->(), index: Int) {
        startTime = NSDate()
        lebensDauer = Double(GV.random(1000, max:2000)) // msec
        self.callBackWhenExit = callBack
        self.index = index
        super.init(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("countDown"), userInfo: nil, repeats: true)
        //self.setTitle("\(lebensDauer)", forState: .Normal)
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
        if first {
            setupLayoutForSpritePosition()
            first = false
        }
        setupLayoutForSpriteSize()
        //self.setTitle("\(lebensDauer)", forState: .Normal)
        if lebensDauer == 0 {
            timer.invalidate()
            callBackWhenExit(self)
        }
    }
    
    func getLebensDauer() -> Double {
        let aktZeit = NSDate()
        return aktZeit.timeIntervalSinceDate(startTime) * 1000 / 1000
    }
    
    func stopObject() {

    }
    
    deinit {
        MySprite.spritesCount--
        println("deinit. Count:\(MySprite.spritesCount)")
    }
    
    func setupLayoutForSpritePosition() {
        
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        let xPosMultiplier = CGFloat(GV.random(20, max: 180)) / 100
        let yPosMultiplier = CGFloat(GV.random(20, max: 180)) / 100
        
        superview!.addConstraint(NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: superview!, attribute: .CenterX, multiplier: xPosMultiplier, constant: 0.0))
        
        superview!.addConstraint(NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: superview!, attribute: .CenterY, multiplier: yPosMultiplier, constant: 0.0))
    }
    
    func setupLayoutForSpriteSize() {
        let sizeMultiplier = CGFloat(lebensDauer / 10000)

        if widthConstraint != nil {
            superview!.removeConstraint(widthConstraint!)
        }
        widthConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: superview!, attribute: .Width, multiplier: sizeMultiplier, constant: 0)
        superview!.addConstraint(widthConstraint!)
        
        if heightConstraint != nil {
            superview!.removeConstraint(heightConstraint!)
        }
        heightConstraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0)
        superview!.addConstraint(heightConstraint!)
        
    }

    
}

