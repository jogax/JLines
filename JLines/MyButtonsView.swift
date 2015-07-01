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
    let verticalButtons: Bool
    
    init(verticalButtons: Bool, paramTab: [String], callBack: (Int)->()) {
        self.callBackToParent = callBack
        self.verticalButtons = verticalButtons
        super.init(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
        self.backgroundColor = UIColor.whiteColor()//GV.darkTurquoiseColor
        self.layer.cornerRadius = 5
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSizeMake(1, 1)
        self.layer.shadowColor = UIColor.blackColor().CGColor
        
        if self.verticalButtons {
            decoFrame.layer.backgroundColor = UIColor.clearColor().CGColor
            decoFrame.layer.borderColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.5).CGColor//UIColor.blueColor().CGColor
            decoFrame.layer.borderWidth = 1
            decoFrame.layer.cornerRadius = 10
            
            self.addSubview(decoFrame)
        }
        
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
    
    func getButton(index:Int) -> MyButton {
        return buttonsTab[index]
    }
    
    func setupLayout() {
        var constraintsArray = Array<NSObject>()
        
        let buttonsHeight = 16 * GV.dX * GV.ipadKorrektur
        let gap = 3 * GV.dX
        let borderGap = 2 * GV.dX
        let buttonsViewHeight = CGFloat(buttonsTab.count) * (buttonsHeight + gap) + gap + 2 * borderGap
        
        //self.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        
        if verticalButtons {
        
            constraintsArray.append(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: buttonsViewHeight))
            decoFrame.setTranslatesAutoresizingMaskIntoConstraints(false)
            
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
        } else {
            
            
            for index in 0..<buttonsTab.count {
                buttonsTab[index].setTranslatesAutoresizingMaskIntoConstraints(false)
                
                // buttonsTab[index]
                constraintsArray.append(NSLayoutConstraint(item: buttonsTab[index], attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
                
                if buttonsTab.count == 1 {
                    constraintsArray.append(NSLayoutConstraint(item: buttonsTab[index], attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
                } else {
                    if index == 0 {
                        constraintsArray.append(NSLayoutConstraint(item: buttonsTab[index], attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 2 * gap))
                    } else {
                        constraintsArray.append(NSLayoutConstraint(item: buttonsTab[index], attribute: .Left, relatedBy: .Equal, toItem: buttonsTab[index - 1], attribute: .Right, multiplier: 1.0, constant: gap))
                        
                    }
                }
                
                var buttonsWidthMultiplier = buttonsTab.count == 1 ? CGFloat(0.4) : CGFloat(0.85) / CGFloat(buttonsTab.count)
                
                constraintsArray.append(NSLayoutConstraint(item: buttonsTab[index], attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: buttonsWidthMultiplier, constant: 0))
                
                constraintsArray.append(NSLayoutConstraint(item: buttonsTab[index], attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 0.4, constant: 0))
                
            }
        }
        
        self.addConstraints(constraintsArray)
        
        
    }
    
    

}
