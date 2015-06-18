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
        self.backgroundColor = GV.PeachPuffColor
        self.titleLabel?.font = buttonFont    
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}

