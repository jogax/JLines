//
//  MyButtonsView.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 19.06.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit

class MyButtonsView: UIView {
    var buttonsTab = [MyButton]()
    var buttonsTitleTab = [String]()
    var callBackToParent: (Int)->()
    var decoFrame = UIView()
    
    init(paramTab: [String], callBack: (Int)->()) {
        self.callBackToParent = callBack
        super.init(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
        self.backgroundColor = GV.darkTurquoiseColor
        self.layer.cornerRadius = 10
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSizeMake(3, 3)
        self.layer.shadowColor = UIColor.blackColor().CGColor
        decoFrame.layer.backgroundColor = UIColor.clearColor().CGColor
        decoFrame.layer.borderColor = UIColor.blueColor().CGColor
        decoFrame.layer.borderWidth = 3
        decoFrame.layer.cornerRadius = 10
        
        self.addSubview(decoFrame)
        
        for index in 0..<paramTab.count {
            buttonsTab.append(MyButton(title: paramTab[index]))
            buttonsTab[index].addTarget(self, action: "callBack:", forControlEvents: .TouchUpInside)
            buttonsTitleTab.append(paramTab[index])
            buttonsTab[index].layer.name = "\(index)"
            self.addSubview(buttonsTab[index])
        }
        GV.language.callBackWhenNewLanguage(self.updateLanguage)
        setupLayout()
    }
    
    func updateLanguage() {
        for index in 0..<buttonsTab.count {
            buttonsTab[index].setTitle(GV.language.getText(buttonsTitleTab[index]), forState: .Normal)
        }
    }
    
    func addCallBack(callBack:(Int)->()) {
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func callBack(sender: UIButton) {
        callBackToParent(sender.layer.name.toInt()!)
    }
    
    func setupLayout() {
        var constraintsArray = Array<NSObject>()
        
        let buttonsHeight = 16 * GV.dX
        let gap = 4 * GV.dX
        let borderGap = 2 * GV.dX
        let buttonsViewHeight = CGFloat(buttonsTab.count) * (buttonsHeight + gap) + gap + 2 * borderGap
        
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        decoFrame.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        constraintsArray.append(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: buttonsViewHeight))

        // decoFrame
        constraintsArray.append(NSLayoutConstraint(item: decoFrame, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: borderGap))
        constraintsArray.append(NSLayoutConstraint(item: decoFrame, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: borderGap))
        constraintsArray.append(NSLayoutConstraint(item: decoFrame, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: -borderGap))
        constraintsArray.append(NSLayoutConstraint(item: decoFrame, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -borderGap))
        
        

        for index in 0..<buttonsTab.count {
            buttonsTab[index].setTranslatesAutoresizingMaskIntoConstraints(false)
        
            // buttonsTab[index]
            constraintsArray.append(NSLayoutConstraint(item: buttonsTab[index], attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            
            if index == 0 {
                constraintsArray.append(NSLayoutConstraint(item: buttonsTab[index], attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: gap + borderGap))
            } else {
                constraintsArray.append(NSLayoutConstraint(item: buttonsTab[index], attribute: .Top, relatedBy: .Equal, toItem: buttonsTab[index - 1], attribute: .Bottom, multiplier: 1.0, constant: gap))
                
            }
            constraintsArray.append(NSLayoutConstraint(item: buttonsTab[index], attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0.8, constant: 0))
            
            constraintsArray.append(NSLayoutConstraint(item: buttonsTab[index], attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: buttonsHeight))
            
        }
        
        self.addConstraints(constraintsArray)
        
        
    }
    
    

}
