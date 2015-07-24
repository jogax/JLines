//
//  Accelerometer.swift
//  JLinesV2
//
//  Created by Jozsef Romhanyi on 27.05.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import CoreMotion
import UIKit


class Accelerometer: UIView {
    let motionManager = CMMotionManager()
    let acceleroCorrectur = 20.0
    let triggerWert: CGFloat = 3.0
    var speed = CGSizeMake(0, 0)
    
    init() {
        super.init(frame:CGRectMake(0,0,0,0))
        GV.notificationCenter.addObserver(self, selector: "changeColor", name: GV.notificationColorChanged, object: nil)
        motionManager.accelerometerUpdateInterval = 0.02
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func stopAccelerometer() {
        motionManager.stopAccelerometerUpdates()
    }
    
    func startAccelerometer() {
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: {(accelerometerData: CMAccelerometerData!, error:NSError!)in
            self.outputAccelerationData(accelerometerData.acceleration)
            if (error != nil)
            {
                println("\(error)")
            }
        })
    }
    
    func changeColor () {
        startAccelerometer()
    }
    
    func outputAccelerationData(acceleration:CMAcceleration)
    {
        if GV.gameControll == .Accelerometer {

            speed.width = CGFloat(Int(acceleration.x * acceleroCorrectur))
            speed.height = -CGFloat(Int(acceleration.y * acceleroCorrectur))
            
            if abs(speed.width) < triggerWert {
                speed.width = 0
            }
            if abs(speed.height) < triggerWert {
                speed.height = 0
            }
            
            if abs(speed.width) > abs(speed.height) + triggerWert {
                speed.height = 0
            }
            if abs(speed.height) > abs(speed.width) + triggerWert {
                speed.width = 0
            }
            GV.speed = speed
            GV.notificationCenter.postNotificationName(GV.notificationMadeMove, object: nil)
        }
    }
    
    
    
}