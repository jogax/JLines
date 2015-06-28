//
//  MyColorChooseView.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 22.06.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit

class MyColorChooseView: UIView {
    var sliderTab = [UISlider]()
    var colorView = UIView()
    var colorInCenterView = UIView()
    var choosedTab = [CGFloat]()
    var OKButton = MyButton(title: "OK")
    var cancelButton = MyButton(title: "cancel")
    let countSliders = 3
    let colorTab: [UIColor] = [UIColor.redColor(), UIColor.greenColor(), UIColor.blueColor()]
    var originalColor = UIColor.clearColor()
    let redIndex = 0
    let greenIndex = 1
    let blueIndex = 2
    var goBack: (Bool)->()
    var callBackSliderMoved: (UIColor)->()
    var withOKButton: Bool
    
    init(returnWhenEnded: (Bool)->(), sliderMoved: (UIColor)->(), withOKButton: Bool, colorInCenter: UIColor) {
        self.goBack = returnWhenEnded
        self.callBackSliderMoved = sliderMoved
        self.withOKButton = withOKButton
        super.init(frame:CGRectZero)
        self.backgroundColor = UIColor.whiteColor()
        self.layer.cornerRadius = 5 * GV.dX
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSizeMake(3,3)
        colorView.backgroundColor = UIColor.clearColor()
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor = UIColor.blackColor().CGColor
        colorView.layer.cornerRadius = 4 * GV.dX
        self.addSubview(colorView)
        colorView.addSubview(colorInCenterView)
        colorInCenterView.backgroundColor = colorInCenter
        colorInCenterView.layer.cornerRadius = 4 * GV.dX / 5
        if withOKButton {
            self.addSubview(OKButton)
            self.addSubview(cancelButton)
            OKButton.addTarget(self, action: "OKButtonChoosed:", forControlEvents: UIControlEvents.TouchUpInside)
            cancelButton.addTarget(self, action: "cancelButtonChoosed:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        for index in 0..<countSliders {
            sliderTab.append(UISlider())
            choosedTab.append(0)
            sliderTab[index].backgroundColor = colorTab[index]
            sliderTab[index].minimumValue = 0
            sliderTab[index].maximumValue = 255
            sliderTab[index].value = 255
            sliderTab[index].addTarget(self, action: "sliderMoved:", forControlEvents: UIControlEvents.ValueChanged)
            self.addSubview(sliderTab[index])
        }
        setupLayout()
    }
    
    func OKButtonChoosed (sender: MyButton) {
       goBack(false)
    }

    func cancelButtonChoosed (sender: MyButton) {
        goBack(true)
    }

    func sliderMoved(sender: UISlider) {
        //let name = sender.layer.name
        for index in 0..<countSliders {
            let colorIndex = index + 1
            choosedTab[index] = CGFloat(sliderTab[index].value) / 255
        }
        let color = UIColor(red: choosedTab[redIndex], green: choosedTab[greenIndex], blue: choosedTab[blueIndex], alpha: 1)
        callBackSliderMoved(color)
        colorView.backgroundColor = color
    }
    
    func reset (colorInCenter: UIColor)  {
        for index in 0..<countSliders {
            sliderTab[index].value = 255
            sliderTab[index].userInteractionEnabled = true
            sliderTab[index].enabled = true
            colorView.backgroundColor = UIColor.whiteColor()
        }
        colorInCenterView.backgroundColor = colorInCenter
        //self.backgroundColor = UIColor(red: choosedTab[redIndex], green: choosedTab[greenIndex], blue: choosedTab[blueIndex], alpha: 1)
    }
        
    func disable () {
        sliderTab[redIndex].userInteractionEnabled = false
        sliderTab[redIndex].enabled = false
        sliderTab[greenIndex].userInteractionEnabled = false
        sliderTab[greenIndex].enabled = false
        sliderTab[blueIndex].userInteractionEnabled = false
        sliderTab[blueIndex].enabled = false

    }
    
    func setColorViewBackgroundColor(color:UIColor) {
        originalColor = color
        colorView.backgroundColor = color
        let numComponents = CGColorGetNumberOfComponents(color.CGColor) - 1
        
        if (numComponents == 3)
        {
            let components = CGColorGetComponents(color.CGColor)
            let red = components[0]
            let green = components[1]
            let blue = components[2]
            for index in 0..<numComponents {
                sliderTab[index].value = Float(components[index] * 255)
                //sliderTab[index].setNeedsLayout()
            }
        }

    }
    
    func getChoosedColorComponents() -> ([CGFloat]) {
        return (choosedTab)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        var constraintsArray = Array<NSObject>()
        colorView.setTranslatesAutoresizingMaskIntoConstraints(false)
        colorInCenterView.setTranslatesAutoresizingMaskIntoConstraints(false)
        var okButtonKorrektur: CGFloat = 1.0
        if withOKButton {
            okButtonKorrektur = 0.6
        }
        
        // colorView
        constraintsArray.append(NSLayoutConstraint(item: colorView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: colorView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: GV.dX))
        
        constraintsArray.append(NSLayoutConstraint(item: colorView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0.9, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: colorView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 0.4 * okButtonKorrektur, constant: 1))
        
        // colorInCenterView
        constraintsArray.append(NSLayoutConstraint(item: colorInCenterView, attribute: .CenterX, relatedBy: .Equal, toItem: colorView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: colorInCenterView, attribute: .CenterY, relatedBy: .Equal, toItem: colorView, attribute: .CenterY, multiplier: 1.0, constant: 1.0))
        
        constraintsArray.append(NSLayoutConstraint(item: colorInCenterView, attribute: .Width, relatedBy: .Equal, toItem: colorView, attribute: .Width, multiplier: 0.7, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: colorInCenterView, attribute: .Height, relatedBy: .Equal, toItem: colorView, attribute: .Height, multiplier: 0.5, constant: 0))
        
        
        for index in 0..<countSliders {
            sliderTab[index].setTranslatesAutoresizingMaskIntoConstraints(false)
            constraintsArray.append(NSLayoutConstraint(item: sliderTab[index], attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
            if index == 0 {
            constraintsArray.append(NSLayoutConstraint(item: sliderTab[index], attribute: .Top, relatedBy: .Equal, toItem: colorView, attribute: .Bottom, multiplier: 1.0, constant: 3 * GV.dX * GV.ipadKorrektur))
            } else {
            constraintsArray.append(NSLayoutConstraint(item: sliderTab[index], attribute: .Top, relatedBy: .Equal, toItem: sliderTab[index - 1], attribute: .Bottom, multiplier: 1.0, constant: 5 * GV.dX * GV.ipadKorrektur))
            }
            
            constraintsArray.append(NSLayoutConstraint(item: sliderTab[index], attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0.95, constant: 0))
            
            constraintsArray.append(NSLayoutConstraint(item: sliderTab[index], attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 0.1, constant: 0))
        }
        
        if withOKButton {
            OKButton.setTranslatesAutoresizingMaskIntoConstraints(false)
            cancelButton.setTranslatesAutoresizingMaskIntoConstraints(false)
            // OKButton
            constraintsArray.append(NSLayoutConstraint(item: OKButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.5, constant: 0))
            constraintsArray.append(NSLayoutConstraint(item: OKButton, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -2 * GV.dX))
            
            constraintsArray.append(NSLayoutConstraint(item: OKButton, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0.4, constant: 0))
            
            constraintsArray.append(NSLayoutConstraint(item: OKButton, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 0.1, constant: 1))
            
            // cancelButton
            constraintsArray.append(NSLayoutConstraint(item: cancelButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 0.5, constant: 0))
            constraintsArray.append(NSLayoutConstraint(item: cancelButton, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -2 * GV.dX))
            
            constraintsArray.append(NSLayoutConstraint(item: cancelButton, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0.4, constant: 0))
            
            constraintsArray.append(NSLayoutConstraint(item: cancelButton, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 0.1, constant: 1))
        }
        self.addConstraints(constraintsArray)
    
    }

}
