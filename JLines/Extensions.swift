//
//  Extensions.swift
//  JogaxLinesV1
//
//  Created by Jozsef Romhanyi on 03.02.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import UIKit

extension Dictionary {
    static func loadJSONFromBundle(fileName: String) -> (Dictionary <String, AnyObject>?, NSData?) {
        //if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "json") {
        if   let path = NSBundle.mainBundle().pathForResource(fileName,ofType:"json") {

            
            var error: NSError?
            let data: NSData? = NSData(contentsOfFile: path, options: NSDataReadingOptions(), error: &error)
            if let data = data {
                
                let dictionary: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
                    options:NSJSONReadingOptions(), error: &error)
                
                if let dictionary = dictionary as? Dictionary<String, AnyObject> {
                    return (dictionary,data)
                } else {
                    //println("Level file \(fileName) is not valid JSON: \(error!)")
                    return (nil,nil)
                }
            } else {
                //println("Could not load level file: \(fileName), error: \(error!)")
            }
        } else {
            //println("Could not find level file \(fileName)")
            return (nil,nil)
        }
        return (nil,nil)
    }
    
}


extension String {
    
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
    

}

extension UIImage {
    public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
        let radiansToDegrees: (CGFloat) -> CGFloat = {
            return $0 * (180.0 / CGFloat(M_PI))
        }
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(M_PI)
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPointZero, size: size))
        let t = CGAffineTransformMakeRotation(degreesToRadians(degrees));
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        CGContextTranslateCTM(bitmap, rotatedSize.width / 2.0, rotatedSize.height / 2.0);
        
        //   // Rotate the image context
        CGContextRotateCTM(bitmap, degreesToRadians(degrees));
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        CGContextScaleCTM(bitmap, yFlip, -1.0)
        CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), CGImage)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension UIView {
    
    func layerGradient(startColor: CGColor, endColor: CGColor) {
        let gradient: CAGradientLayer = CAGradientLayer()
        let colors: [AnyObject] = [startColor, endColor]
        
        gradient.colors = colors
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        gradient.cornerRadius = 8
        self.layer.insertSublayer(gradient, atIndex: 0)
    }
}

extension UIButton {

    func setupDepression() {
        addTarget(self, action: "didTouchDown:", forControlEvents: .TouchDown)
        addTarget(self, action: "didTouchDragExit:", forControlEvents: .TouchDragExit)
        addTarget(self, action: "didTouchUp:", forControlEvents: .TouchUpInside)
    }
    
    func didTouchDown(button:MyButton) {
        UIView.animateWithDuration(0.07){
            self.transform = CGAffineTransformMakeScale(0.95, 0.95)
            //self.setNeedsDisplay()
        }
    }
    
    func didTouchDragExit(button:MyButton) {
        UIView.animateWithDuration(0.07){
            self.transform = CGAffineTransformMakeScale(1, 1)
            //self.setNeedsDisplay()
        }
    }
    
    func didTouchUp(button:MyButton) {
        UIView.animateWithDuration(0.07){
            self.transform = CGAffineTransformMakeScale(1, 1)
            //self.setNeedsDisplay()
        }
    }
    
    override public func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        let exitExtension: CGFloat = 5
        let outerBounds: CGRect = CGRectInset(self.bounds, -exitExtension, -exitExtension)
        let touchOutside: Bool = !CGRectContainsPoint(outerBounds, touch.locationInView(self))
        if touchOutside {
            let previousTouchInside = CGRectContainsPoint(outerBounds, touch.previousLocationInView(self))
            if previousTouchInside {
                sendActionsForControlEvents(.TouchDragExit)
                return false
            } else {
                sendActionsForControlEvents(.TouchDragOutside)
                return false
            }
        }
        return super.continueTrackingWithTouch(touch, withEvent: event)
    }
    
    func moveToCenter(rect: CGRect) {
        frame.origin.x = (rect.size.width - frame.size.width) / 2
    }
    
}

public enum DeviceTypes : String {
    case simulator      = "Simulator",
    iPad2          = "iPad 2",
    iPad3          = "iPad 3",
    iPhone4        = "iPhone 4",
    iPhone4S       = "iPhone 4S",
    iPhone5        = "iPhone 5",
    iPhone5S       = "iPhone 5S",
    iPhone5c       = "iPhone 5c",
    iPad4          = "iPad 4",
    iPadMini1      = "iPad Mini 1",
    iPadMini2      = "iPad Mini 2",
    iPadAir1       = "iPad Air 1",
    iPadAir2       = "iPad Air 2",
    iPhone6        = "iPhone 6",
    iPhone6plus    = "iPhone 6 Plus",
    unrecognized   = "?unrecognized?"
}

public extension UIDevice {
    
    public var deviceType: DeviceTypes {
        var sysinfo : [CChar] = Array(count: sizeof(utsname), repeatedValue: 0)
        let modelCode = sysinfo.withUnsafeMutableBufferPointer {
            (inout ptr: UnsafeMutableBufferPointer<CChar>) -> DeviceTypes in
            uname(UnsafeMutablePointer<utsname>(ptr.baseAddress))
            // skip 1st 4 256 byte sysinfo result fields to get "machine" field
            let machinePtr = advance(ptr.baseAddress, Int(_SYS_NAMELEN * 4))
            var modelMap : [ String : DeviceTypes ] = [
                "i386"      : .simulator,
                "x86_64"    : .simulator,
                "iPad2,1"   : .iPad2,          //
                "iPad3,1"   : .iPad3,          // (3rd Generation)
                "iPhone3,1" : .iPhone4,        //
                "iPhone3,2" : .iPhone4,        //
                "iPhone4,1" : .iPhone4S,       //
                "iPhone5,1" : .iPhone5,        // (model A1428, AT&T/Canada)
                "iPhone5,2" : .iPhone5,        // (model A1429, everything else)
                "iPad3,4"   : .iPad4,          // (4th Generation)
                "iPad2,5"   : .iPadMini1,      // (Original)
                "iPhone5,3" : .iPhone5c,       // (model A1456, A1532 | GSM)
                "iPhone5,4" : .iPhone5c,       // (model A1507, A1516, A1526 (China), A1529 | Global)
                "iPhone6,1" : .iPhone5S,       // (model A1433, A1533 | GSM)
                "iPhone6,2" : .iPhone5S,       // (model A1457, A1518, A1528 (China), A1530 | Global)
                "iPad4,1"   : .iPadAir1,       // 5th Generation iPad (iPad Air) - Wifi
                "iPad4,2"   : .iPadAir2,       // 5th Generation iPad (iPad Air) - Cellular
                "iPad4,4"   : .iPadMini2,      // (2nd Generation iPad Mini - Wifi)
                "iPad4,5"   : .iPadMini2,      // (2nd Generation iPad Mini - Cellular)
                "iPhone7,1" : .iPhone6plus,    // All iPhone 6 Plus's
                "iPhone7,2" : .iPhone6         // All iPhone 6's
            ]
            if var model = modelMap[String.fromCString(machinePtr)!] {
                if model == .simulator  {
                    let screen = UIScreen.mainScreen().nativeBounds
                    let screenSize = (screen.width, screen.height)
                    switch screenSize {
                    case (640,960):
                        model = modelMap["iPhone3,1"]!
                    case (640,1136):
                        model = modelMap["iPhone5,1"]!
                    case (750,1334):
                        model = modelMap["iPhone7,2"]!
                    case (1080, 1920):
                        model = modelMap["iPhone7,1"]!
                    case (1536, 2048):
                        model = modelMap["iPad4,1"]!
                    default:
                        model = DeviceTypes.unrecognized
                    }
                }
                return model
            }
            return DeviceTypes.unrecognized
        }
        return modelCode
    }
}

extension NSNotificationCenter {

}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

