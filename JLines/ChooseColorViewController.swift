//
//  ChooseColorViewController.swift
//  JLinesV2
//
//  Created by Jozsef Romhanyi on 08.06.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit

class ChooseColorViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate   {

    var backButton = UIButton()
    var pickerData: [[String]] = []
    var topping: String = ""
    let chooseView = UIPickerView()
    var descriptionsLabel = UILabel()
    let buttonsView = UIView()
    var colorSetViews = [UIView]()
    var colorSetButtons = [MyButton]()
    var colorSets = [[]]
    var goWhenEnd: ()->()

    // Constants
    var dX: CGFloat = 0
    var dY: CGFloat = 0



    init(callBack: ()->()) {
        goWhenEnd = callBack
        
        
        super.init(nibName: nil, bundle: nil)
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = GV.lightSalmonColor
        dY = view.frame.size.height / 100
        dX = view.frame.size.width / 100
        
        
        descriptionsLabel.backgroundColor = UIColor.clearColor()
        descriptionsLabel.text = GV.language.getText("chooseColorSet")
        descriptionsLabel.numberOfLines = 3
        descriptionsLabel.textAlignment = NSTextAlignment.Center
        descriptionsLabel.layer.cornerRadius = 10
        descriptionsLabel.layer.shadowColor = UIColor.blackColor().CGColor
        descriptionsLabel.layer.shadowOffset = CGSizeMake(2, 2)
        descriptionsLabel.layer.shadowOpacity = 1.0
        view.addSubview(descriptionsLabel)
        view.addSubview(buttonsView)
        view.addSubview(backButton)
        
        buttonsView.backgroundColor = GV.darkTurquoiseColor
        buttonsView.layer.cornerRadius = 10
        buttonsView.layer.shadowOpacity = 1.0
        buttonsView.layer.shadowOffset = CGSizeMake(3, 3)
        buttonsView.layer.shadowColor = UIColor.blackColor().CGColor
        colorSets.removeAll(keepCapacity: false)
        var colorSet = [UIView]()
        for index in 0..<GV.colorSets.count {
            colorSetViews.append(UIView())
            colorSetViews[index].setTranslatesAutoresizingMaskIntoConstraints(false)
            colorSetViews[index].backgroundColor = GV.PeachPuffColor
            colorSetViews[index].clipsToBounds = true
            colorSetViews[index].layer.masksToBounds = false
            colorSetViews[index].layer.cornerRadius = 3.0
            colorSetViews[index].layer.shadowColor = UIColor.darkGrayColor().CGColor
            colorSetViews[index].layer.shadowOffset = CGSizeMake(3, 3)
            colorSetViews[index].layer.shadowOpacity = 1.0
            colorSetViews[index].alpha = 1.0
            //colorSetViews[index].layer.name = "colorLabel index: \(index)"
            colorSetButtons.append(MyButton())
            colorSetButtons[index].setTranslatesAutoresizingMaskIntoConstraints(false)
            colorSetButtons[index].layer.name = "\(index)"
            colorSetButtons[index].addTarget(self, action: "colorSetChoosed:", forControlEvents: UIControlEvents.TouchUpInside)
            colorSetButtons[index].setTitle(GV.language.getText("choose"), forState: UIControlState.Normal)
            colorSetButtons[index].titleLabel!.numberOfLines = 3
            //colorSetButtons[index].titleLabel!.textAlignment = NSTextAlignmentCenter
            colorSet.removeAll(keepCapacity: false)
            for colorIndex in 0..<GV.colorSets[index].count - 4 {
                colorSet.append(MyButton())
                colorSet[colorIndex].backgroundColor = GV.colorSets[index][colorIndex + 1]
                //println("index: \(index), colorIndex: \(colorIndex), bgColor: \(colorSet[colorIndex].backgroundColor)")
                colorSet[colorIndex].layer.cornerRadius = 4 * dX
                colorSet[colorIndex].layer.shadowColor = UIColor.blackColor().CGColor
                colorSet[colorIndex].layer.shadowOffset = CGSizeMake(2, 2)
                colorSet[colorIndex].layer.shadowOpacity = 1.0
                colorSet[colorIndex].alpha = 1.0
                //colorSet[colorIndex].layer.name = "colorset:\(index):\(colorIndex)"
                colorSetViews[index].addSubview(colorSet[colorIndex])
            }
            colorSets.append(colorSet)
            view.addSubview(colorSetViews[index])
            view.addSubview(colorSetButtons[index])
        }
        backButton.setImage(GV.images.getBack(), forState: .Normal)
        backButton.addTarget(self, action: "endChooseColor:", forControlEvents: .TouchUpInside)
        setupLayout()
    }
    
    func colorSetChoosed (sender: UIButton) {
        GV.colorSetIndex = sender.layer.name.toInt()!
    }

    func endChooseColor(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: {self.goWhenEnd()})
    }

    func callBackWhenEnded(callBack: ()->()) {
        goWhenEnd = callBack
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[0].count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[0][row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateLabel()
    }

    func updateLabel(){
        topping = pickerData[0][chooseView.selectedRowInComponent(0)]
    }

    func setupLayout() {
        
        var constraintsArray = Array<NSObject>()
        var colorRadius: CGFloat = 4 * dX
        var gap: CGFloat = dX
        let countButtons: CGFloat = 3
        let buttonsHeight = 21 * gap
        let buttonsViewHeight = countButtons * (buttonsHeight + gap) + 5 * gap

        buttonsView.setTranslatesAutoresizingMaskIntoConstraints(false)
        backButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        descriptionsLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        for index in 0..<colorSetViews.count {
            colorSetViews[index].setTranslatesAutoresizingMaskIntoConstraints(false)
            for colorIndex in 0..<colorSets[index].count {
                colorSets[index][colorIndex].setTranslatesAutoresizingMaskIntoConstraints(false)
            }
        }
        
        // descriptionsLabel
        
        constraintsArray.append(NSLayoutConstraint(item: descriptionsLabel, attribute: .CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: descriptionsLabel, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: 10 * gap))
        
        constraintsArray.append(NSLayoutConstraint(item: descriptionsLabel, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.95, constant: 1))
        
        constraintsArray.append(NSLayoutConstraint(item: descriptionsLabel, attribute: .Height , relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 20 * gap))
        
        // buttonsView
        constraintsArray.append(NSLayoutConstraint(item: buttonsView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: buttonsView, attribute: .Top, relatedBy: .Equal, toItem: descriptionsLabel, attribute: .Bottom, multiplier: 1, constant: 2 * gap))
        
        constraintsArray.append(NSLayoutConstraint(item: buttonsView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.95, constant: 1))
        
        constraintsArray.append(NSLayoutConstraint(item: buttonsView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: buttonsViewHeight))
        
    
        // chooseColorSet Buttons
        
        for index in 0..<colorSetViews.count {
            let multiplier = CGFloat(index + 1)

            constraintsArray.append(NSLayoutConstraint(item: colorSetViews[index], attribute: .Left, relatedBy: .Equal, toItem: buttonsView, attribute: .Left, multiplier: 1.0, constant: 1.5 * gap))
            constraintsArray.append(NSLayoutConstraint(item: colorSetButtons[index], attribute: .Right, relatedBy: .Equal, toItem: buttonsView, attribute: .Right, multiplier: 1.0, constant: -1.5 * gap))
            
            if index == 0 {
                constraintsArray.append(NSLayoutConstraint(item: colorSetViews[index], attribute: .Top, relatedBy: .Equal, toItem: buttonsView, attribute: .Top, multiplier: 1.0, constant: 2 * gap))
                constraintsArray.append(NSLayoutConstraint(item: colorSetButtons[index], attribute: .Top, relatedBy: .Equal, toItem: buttonsView, attribute: .Top, multiplier: 1.0, constant: 2 * gap))
            } else {
                constraintsArray.append(NSLayoutConstraint(item: colorSetViews[index], attribute: .Top, relatedBy: .Equal, toItem: colorSetViews[index - 1], attribute: .Bottom, multiplier: 1.0, constant: 2.0 * gap))
                constraintsArray.append(NSLayoutConstraint(item: colorSetButtons[index], attribute: .Top, relatedBy: .Equal, toItem: colorSetViews[index - 1], attribute: .Bottom, multiplier: 1.0, constant: 2.0 * gap))
            }
            constraintsArray.append(NSLayoutConstraint(item: colorSetViews[index], attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 69 * gap))
            constraintsArray.append(NSLayoutConstraint(item: colorSetButtons[index], attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonsHeight))

            constraintsArray.append(NSLayoutConstraint(item: colorSetViews[index], attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonsHeight))
            constraintsArray.append(NSLayoutConstraint(item: colorSetButtons[index], attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonsHeight))
            
            for colorIndex in 0..<colorSets[index].count {
                if colorIndex == 0 || colorIndex == 7 {
                    constraintsArray.append(NSLayoutConstraint(item: colorSets[index][colorIndex], attribute: .Left, relatedBy: .Equal, toItem: colorSetViews[index], attribute: .Left, multiplier: 2.0, constant: gap))
                } else {
                    constraintsArray.append(NSLayoutConstraint(item: colorSets[index][colorIndex], attribute: .Left, relatedBy: .Equal, toItem: colorSets[index][colorIndex - 1], attribute: .Right, multiplier: 1.0, constant: gap))
                }
                if colorIndex < 7 {
                    constraintsArray.append(NSLayoutConstraint(item: colorSets[index][colorIndex], attribute: .Top, relatedBy: .Equal, toItem: colorSetViews[index], attribute: .Top, multiplier: 1, constant: gap))
                } else {
                    constraintsArray.append(NSLayoutConstraint(item: colorSets[index][colorIndex], attribute: .Top, relatedBy: .Equal, toItem: colorSets[index][0], attribute: .Bottom, multiplier: 1, constant: 1 * gap))
                }
                
                constraintsArray.append(NSLayoutConstraint(item: colorSets[index][colorIndex], attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 8.5 * gap))
                
                constraintsArray.append(NSLayoutConstraint(item: colorSets[index][colorIndex], attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 8.5 * gap))
            }
        }

 
        
        // backButton
        constraintsArray.append(NSLayoutConstraint(item: backButton, attribute: NSLayoutAttribute.Right, relatedBy: .Equal, toItem: self.view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -10.0))
        
        constraintsArray.append(NSLayoutConstraint(item: backButton, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 20.0))
        
        constraintsArray.append(NSLayoutConstraint(item: backButton, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.05, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: backButton, attribute: .Height , relatedBy: .Equal, toItem: backButton, attribute: .Width, multiplier: 1.0, constant: 0.0))
        
        self.view.addConstraints(constraintsArray)
    }

}
