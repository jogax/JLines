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
    var callBackToParent: (Int)->()
    
    init(paramTab: [String], callBack: (Int)->()) {
        self.callBackToParent = callBack
        super.init(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
        for index in 0..<paramTab.count {
            buttonsTab.append(MyButton(title: paramTab[index]))
            buttonsTab[index].addTarget(self, action: "callBack:", forControlEvents: .TouchUpInside)
            buttonsTab[index].layer.name = "\(index)"
            self.addSubview(buttonsTab[index])
        }
        setupLayout()
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
        
        
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        for index in 0..<buttonsTab.count {
            buttonsTab[index].setTranslatesAutoresizingMaskIntoConstraints(false)
        
            // buttonsTab[index]
            constraintsArray.append(NSLayoutConstraint(item: buttonsTab[index], attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            
            if index == 0 {
                constraintsArray.append(NSLayoutConstraint(item: buttonsTab[index], attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 3 * GV.dX))
            } else {
                constraintsArray.append(NSLayoutConstraint(item: buttonsTab[index], attribute: .Top, relatedBy: .Equal, toItem: buttonsTab[index - 1], attribute: .Bottom, multiplier: 1.0, constant: 3 * GV.dX))
                
            }
            constraintsArray.append(NSLayoutConstraint(item: buttonsTab[index], attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0.8, constant: 0))
            
            constraintsArray.append(NSLayoutConstraint(item: buttonsTab[index], attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 0.2, constant: 0))
            
        }
        
        self.addConstraints(constraintsArray)
        
        
    }
    
    

}
