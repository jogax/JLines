//
//  MyButton.swift
//  JLinesV2
//
//  Created by Jozsef Romhanyi on 29.04.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit

class MyButton: UIButton {
    let buttonFont = UIFont(name:"Times New Roman", size: GV.onIpad ? 32 : 16)
    var decoFrame = UIView()
    
    init(title: String) {
        super.init(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
        doInit()
        self.setTitle(GV.language.getText(title), forState: .Normal)
    }
    
    init() {
        super.init(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
        doInit()
    }
    
    func doInit() {
        setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.layer.cornerRadius = 8
        self.setupDepression()
        self.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSizeMake(3, 3)
        self.layer.shadowOpacity = 1.0
        self.backgroundColor = UIColor.whiteColor()//GV.PeachPuffColor
        self.titleLabel?.font = buttonFont
        /*
        decoFrame.layer.backgroundColor = UIColor(red: 0, green: 1, blue: 1, alpha: 0.2).CGColor//UIColor.clearColor().CGColor
        decoFrame.layer.borderColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.8).CGColor//UIColor.blueColor().CGColor
        decoFrame.layer.borderWidth = 2
        decoFrame.layer.cornerRadius = 3
        
        self.addSubview(decoFrame)
        setupLayout()
        */
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    func setupLayout() {
        var constraintsArray = Array<NSObject>()
        
        
        decoFrame.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // decoFrame
        constraintsArray.append(NSLayoutConstraint(item: decoFrame, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: decoFrame, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: decoFrame, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0.96, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: decoFrame, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 0.85, constant: 0))
        
        
        
        self.addConstraints(constraintsArray)
        
        
    }
    */
    
    
}

