//
//  ChooseColorViewController.swift
//  JLinesV2
//
//  Created by Jozsef Romhanyi on 08.06.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit

class ChooseColorViewController: UIViewController   {

    var backButton = UIButton()
    var pickerData: [[String]] = []
    var topping: String = ""
    var chooseView: MyColorChooseView?
    var descriptionsLabel = UILabel()
    let buttonsView = UIView()
    var colorSetViews = [UIView]()
    var colorSetButtons = [MyButton]()
    var colorSets = [[]]
    var goWhenEnd: ()->()
    var aktIndex = 0
    var aktColorIndex = 0

    //var sliderTab = [UISlider]()
    //var sliderView = UIView()
    //var choosedColorView = UIView()
    let countSliders = 3
    var choosedTab = [CGFloat]()
    let colorTab: [UIColor] = [UIColor.redColor(), UIColor.greenColor(), UIColor.blueColor()]
    let redIndex = 0
    let greenIndex = 1
    let blueIndex = 2
    let viewRadius = 4 * GV.dX

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
    
    func dummy (UIColor) {
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = GV.lightSalmonColor
        dY = view.frame.size.height / 100
        dX = view.frame.size.width / 100
        
        chooseView = MyColorChooseView(returnWhenEnded: goHearWhenColorChoosed, sliderMoved: sliderMoved, withOKButton: true, colorInCenter: UIColor.clearColor())
        descriptionsLabel.backgroundColor = UIColor.whiteColor()
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
        //view.addSubview(sliderView)
        view.addSubview(chooseView!)
        chooseView!.alpha = 0

        //view.addSubview(choosedColorView)
        
        buttonsView.backgroundColor = GV.darkTurquoiseColor
        buttonsView.layer.cornerRadius = 10
        buttonsView.layer.shadowOpacity = 1.0
        buttonsView.layer.shadowOffset = CGSizeMake(3, 3)
        buttonsView.layer.shadowColor = UIColor.blackColor().CGColor
        colorSets.removeAll(keepCapacity: false)
        var colorSet = [UIButton]()
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
            if index == GV.colorSetIndex {
                colorSetViews[index].layer.borderColor = UIColor.darkGrayColor().CGColor
                colorSetViews[index].layer.borderWidth = 3
            }
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
                colorSet[colorIndex].layer.name = "\(index * 100 + colorIndex)"
                colorSet[colorIndex].addTarget(self, action: "colorChoosed:", forControlEvents: UIControlEvents.TouchUpInside)
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
    
    func goHearWhenColorChoosed(color: UIColor) {
        chooseView!.alpha = 0
        GV.colorSets[aktIndex][aktColorIndex + 1] = color        
    }
    
    func sliderMoved (color: UIColor) {
        GV.colorSets[aktIndex][aktColorIndex] = color
        let button:MyButton = colorSets[aktIndex][aktColorIndex] as! MyButton
        button.backgroundColor = color
    }
    
    func colorChoosed (sender: MyButton) {
        aktIndex = sender.layer.name.toInt()! / 100
        aktColorIndex = sender.layer.name.toInt()! % 100
        //let aktColorSet = colorSets[aktColorIndex]
        //let colorSet:[UIButton] = aktColorSet[colorIndex] as! [UIButton]
        let aktColor:UIColor = GV.colorSets[aktIndex][aktColorIndex + 1]
        //sliderView.alpha = 1
        chooseView!.alpha = 1
        chooseView!.setColorViewBackgroundColor(aktColor)
    }
    
    func colorSetChoosed (sender: UIButton) {
        colorSetViews[GV.colorSetIndex].layer.borderColor = UIColor.clearColor().CGColor
        colorSetViews[GV.colorSetIndex].layer.borderWidth = 0

        GV.colorSetIndex = sender.layer.name.toInt()!
        GV.appData.farbSchemaIndex = Int64(GV.colorSetIndex)
        GV.dataStore.createAppVariablesRecord(GV.appData)
        colorSetViews[GV.colorSetIndex].layer.borderColor = UIColor.darkGrayColor().CGColor
        colorSetViews[GV.colorSetIndex].layer.borderWidth = 3
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


    func setupLayout() {
        
        var constraintsArray = Array<NSObject>()
        var colorRadius: CGFloat = 4 * dX
        var gap: CGFloat = dX
        let countButtons: CGFloat = 3
        let buttonsHeight = 21 * gap
        let buttonsViewHeight = countButtons * (buttonsHeight + gap) + 5 * gap

        buttonsView.setTranslatesAutoresizingMaskIntoConstraints(false)
        backButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        chooseView!.setTranslatesAutoresizingMaskIntoConstraints(false)
        //sliderView.setTranslatesAutoresizingMaskIntoConstraints(false)
        descriptionsLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        //choosedColorView.setTranslatesAutoresizingMaskIntoConstraints(false)
        for index in 0..<colorSetViews.count {
            colorSetViews[index].setTranslatesAutoresizingMaskIntoConstraints(false)
            for colorIndex in 0..<colorSets[index].count {
                colorSets[index][colorIndex].setTranslatesAutoresizingMaskIntoConstraints(false)
            }
        }
        /*
        for index in 0..<countSliders {
            sliderTab[index].setTranslatesAutoresizingMaskIntoConstraints(false)
        }
        */
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
        
        // chooseView
        constraintsArray.append(NSLayoutConstraint(item: chooseView!, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: chooseView!, attribute: .Top, relatedBy: .Equal, toItem: buttonsView, attribute: .Bottom, multiplier: 1.0, constant: GV.dX))
        
        constraintsArray.append(NSLayoutConstraint(item: chooseView!, attribute: .Width, relatedBy: .Equal, toItem: buttonsView, attribute: .Width, multiplier: 1.0, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: chooseView!, attribute: .Height , relatedBy: .Equal, toItem: buttonsView, attribute: .Height, multiplier: 1.0, constant: 0))
/*
        // sliderView
        constraintsArray.append(NSLayoutConstraint(item: sliderView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: sliderView, attribute: .Top, relatedBy: .Equal, toItem: buttonsView, attribute: .Bottom, multiplier: 1.0, constant: GV.dX))
        
        constraintsArray.append(NSLayoutConstraint(item: sliderView, attribute: .Width, relatedBy: .Equal, toItem: buttonsView, attribute: .Width, multiplier: 1.0, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: sliderView, attribute: .Height , relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30 * GV.dX))

        // choosedColorView
        constraintsArray.append(NSLayoutConstraint(item: choosedColorView, attribute: .CenterX, relatedBy: .Equal, toItem: sliderView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: choosedColorView, attribute: .Bottom, relatedBy: .Equal, toItem: sliderView, attribute: .Bottom, multiplier: 1.0, constant: -GV.dX))
        
        constraintsArray.append(NSLayoutConstraint(item: choosedColorView, attribute: .Width, relatedBy: .Equal, toItem: sliderView, attribute: .Width, multiplier: 0.90, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: choosedColorView, attribute: .Height , relatedBy: .Equal, toItem: sliderView, attribute: .Height, multiplier: 0.5, constant: 0))
        
        // sliders
        for index in 0..<countSliders {
            constraintsArray.append(NSLayoutConstraint(item: sliderTab[index], attribute: .CenterX, relatedBy: .Equal, toItem: sliderView, attribute: .CenterX, multiplier: 1.0, constant: 0))
            if index == 0 {
                constraintsArray.append(NSLayoutConstraint(item: sliderTab[index], attribute: .Top, relatedBy: .Equal, toItem: sliderView, attribute: .Bottom, multiplier: 1.0, constant: 1.5 * viewRadius))
            } else {
                constraintsArray.append(NSLayoutConstraint(item: sliderTab[index], attribute: .Top, relatedBy: .Equal, toItem: sliderTab[index - 1], attribute: .Bottom, multiplier: 1.0, constant: 1.5 * viewRadius))
            }
            
            constraintsArray.append(NSLayoutConstraint(item: sliderTab[index], attribute: .Width, relatedBy: .Equal, toItem: sliderView, attribute: .Width, multiplier: 1.0, constant: 0))
            
            constraintsArray.append(NSLayoutConstraint(item: sliderTab[index], attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 1.0 * viewRadius))
        }
*/
        self.view.addConstraints(constraintsArray)
    }

}
