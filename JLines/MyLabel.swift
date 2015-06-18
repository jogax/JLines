//
//  MyLabel.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 17.06.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit

class MyLabel: UILabel {
    let labelFont = UIFont(name:"Times New Roman", size: GV.onIpad ? 32 : 16)
    init() {
        super.init(frame:CGRectMake(0,0,0,0))
        doInit()
    }

    init(text:String) {
        super.init(frame:CGRectMake(0,0,0,0))
        doInit()
        self.text = GV.language.getText(text)
    }
    
    func doInit() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.textAlignment = .Center
        self.font = labelFont
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
