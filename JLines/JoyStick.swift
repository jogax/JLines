//
//  JoyStick.swift
//  JLinesV2
//
//  Created by Jozsef Romhanyi on 19.05.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit
import Foundation

enum JoystickDirections: Int {
        case None = 0, Right, Left, Up, Down
}

class JoyStick: UIView {
    var color: LineType = .Unknown
    var newColor: LineType = .Unknown
    var knopf = UIView()
    var speedX: CGFloat = 0.0
    var speedY: CGFloat = 0.0
    var direction = JoystickDirections.None
    var startTouchPoint = CGPoint(x: 0, y: 0)
    var aktTouchPoint = CGPoint(x: 0, y: 0)
    var timer: NSTimer?
    let speedCorrection: CGFloat = 12.5
    let triggerWert: CGFloat = 1.0
    let timerInterval = 0.02

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        GV.notificationCenter.addObserver(self, selector: "changeColor", name: GV.notificationColorChanged, object: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setJoyStickLayout () {

        self.layer.borderColor = GV.SilverColor.CGColor
        self.layer.cornerRadius = GV.joyStickRadius / 1.7
        self.layer.borderWidth = 2.8
        self.layer.shadowColor = GV.BlackColor.CGColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSizeMake(GV.joyStickRadius / 12, GV.joyStickRadius / 12)

        self.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 0.5)
        let knopfSize = CGFloat(Int(GV.joyStickRadius / 1.2))
        
        knopf.frame.size = CGSizeMake(knopfSize, knopfSize)
        
        knopf.center.x = self.bounds.midX
        knopf.center.y = self.bounds.midY
        knopf.layer.cornerRadius = GV.joyStickRadius / 2.4
        knopf.backgroundColor = color.uiColor
        knopf.hidden = false
        
        self.addSubview(knopf)
        
   }
    

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touchCount = touches.count
        let touch = touches.first as! UITouch
        startTouchPoint = touch.locationInView(self)
        GV.speed = CGSizeMake(0, 0)
        startTimer(true)
    }

    func startTimer(start: Bool) {
        if self.timer != nil {
            self.timer!.invalidate()
        }
        if start {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: Selector("makeStep"), userInfo: nil, repeats: true)
        } else {
            self.timer = nil            
        }
    }
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        resetJoystick()
    }

    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touchCount = touches.count
        let touch = touches.first as! UITouch
        aktTouchPoint = touch.locationInView(self)
        var distanceX = (aktTouchPoint.x - startTouchPoint.x) / speedCorrection
        var distanceY = (aktTouchPoint.y - startTouchPoint.y) / speedCorrection

        if abs(distanceX) < triggerWert {
            distanceX = 0
        }
        if abs(distanceY) < triggerWert {
            distanceY = 0
        }
        
        if distanceX > GV.gameRectSize / 2 {
            distanceX = GV.gameRectSize / 2
        }

        if distanceY > GV.gameRectSize / 2 {
            distanceY = GV.gameRectSize / 2
        }

        var x: CGFloat = 0
        var y: CGFloat = 0
        //let maxX = self.bounds.midX - knopf.bounds.midX
        //let maxY = self.bounds.midY - knopf.bounds.midY
        if abs(distanceX) > abs(distanceY) {
            distanceY = 0
            y = self.bounds.midY
            x = self.bounds.midX + distanceX
            direction = distanceX > 0 ? .Right : .Left
        } else {
            distanceX = 0
            x = self.bounds.midX
            y = self.bounds.midY + distanceY
            direction = distanceY > 0 ? .Up : .Down
        }
        //rintln("distanceX: \(distanceX), distanceY: \(distanceY)")
        GV.speed = CGSizeMake(distanceX, distanceY)

        knopf.center.x = x
        knopf.center.y = y
    }

    func makeStep () {
        GV.notificationCenter.postNotificationName(GV.notificationMadeMove, object: nil)
    }

    func changeColor () {
        self.newColor = GV.aktColor
        resetJoystick()
    }

    func resetJoystick() {
        knopf.center.x = self.bounds.midX
        knopf.center.y = self.bounds.midY
        speedX = 0
        speedY = 0
        startTimer(false)
        if self.newColor != self.color {
            self.color = self.newColor
            knopf.backgroundColor = color.uiColor
            knopf.setNeedsDisplay()
        }
    }

}
