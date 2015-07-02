//
//  PlayWithPointsViewController.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 01.07.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit
import SpriteKit

class PlayWithPointsViewController: UIViewController {

    var goWhenEnd: ()->()
    var gameBoardView = UIView()
    var buttonsView: MyButtonsView?
    let buttonsViewParamTab = ["return"]
    var collectViews = [MyButton]()
    var collectCounts = [Int]()
    let countCollectViews = 5
    var timer: NSTimer?
    var points = [MyButton]()
    var playColors = [UIColor]()
    var lastPressed: MyButton?


    init(callBack: ()->()) {
        goWhenEnd = callBack
        
        
        super.init(nibName: nil, bundle: nil)
        
        //GV.language.callBackWhenNewLanguage(self.updateLanguage)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = GV.backgroundColor
        gameBoardView.backgroundColor = GV.backgroundColor
        gameBoardView.layer.borderColor = UIColor.blackColor().CGColor
        gameBoardView.layer.borderWidth = 1
        gameBoardView.layer.shadowColor = UIColor.blackColor().CGColor
        gameBoardView.layer.cornerRadius = 5
        buttonsView = MyButtonsView(verticalButtons: false,paramTab: buttonsViewParamTab, callBack: callBackFromMyButtonsView)
        buttonsView!.backgroundColor = UIColor.clearColor()
        self.view.addSubview(gameBoardView)
        self.view.addSubview(buttonsView!)
        for index in 0..<countCollectViews {
            collectViews.append(MyButton())
            collectCounts.append(0)
            collectViews[index].backgroundColor = UIColor.whiteColor()
            collectViews[index].layer.borderColor = UIColor.blackColor().CGColor
            collectViews[index].layer.borderWidth = 1
            collectViews[index].layer.cornerRadius = 5
            collectViews[index].layer.shadowColor = UIColor.blackColor().CGColor
            collectViews[index].layer.shadowOffset = CGSizeMake(2,2)
            collectViews[index].layer.shadowOpacity = 1.0
            collectViews[index].layer.name = "\(index)"
            collectViews[index].addTarget(self, action: "collectButtonPressed:", forControlEvents: .TouchUpInside)
            let color = GV.colorSets[GV.colorSetIndex][index + 1]
            if index < countCollectViews - 1 {
                playColors.append(color)
            } else {
                collectViews[index].enabled = false
            }
            collectViews[index].backgroundColor = color
            gameBoardView.addSubview(collectViews[index])
        }
        setupLayout()
        generateAPoint()
        

        // Do any additional setup after loading the view.
    }
    
    
    func callBackFromMyButtonsView(index: Int) {
        switch index {
        case 0: stopPlayWithPoints()
        default: stopPlayWithPoints()
        }
    }

    func stopPlayWithPoints () { //(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: {self.goWhenEnd()})
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generateAPoint() {
        let nextTime = Double(random(5, max: 50)) / 15
        let colorIndex = random(0, max: countCollectViews - 2)
        self.timer = NSTimer.scheduledTimerWithTimeInterval(nextTime, target: self, selector: Selector("generateAPoint"), userInfo: nil, repeats: false)
        let point = MyButton()
        points.append(point)
        point.backgroundColor = playColors[colorIndex]
        point.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        gameBoardView.addSubview(point)
        point.layer.name = "\(points.count)"
        
        setupLayoutForPoint(point)
    }
    
    func buttonPressed (sender: MyButton) {
        if lastPressed != nil {
            let (lastRed, lastGreen, lastBlue, lastalpha) = getColorComponents(lastPressed!.backgroundColor!)
            lastPressed!.backgroundColor = UIColor(red: lastRed, green: lastGreen, blue: lastBlue, alpha: 1.0)
        }
        
        let (red, green, blue, alpha) = getColorComponents(sender.backgroundColor!)
        sender.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 0.5)
        lastPressed = sender
    }
    
    func collectButtonPressed (sender: MyButton) {
        if lastPressed != nil {
            let (red, green, blue, alpha) = getColorComponents(sender.backgroundColor!)
            let (lastRed, lastGreen, lastBlue, lastalpha) = getColorComponents(lastPressed!.backgroundColor!)
            let index = sender.layer.name.toInt()
            if red == lastRed && green == lastGreen && blue == lastBlue {
                collectCounts[index!]++
                lastPressed!.removeFromSuperview()
                collectViews[index!].setTitle("\(collectCounts[index!])", forState: .Normal)
            } else {
                collectCounts[countCollectViews - 1]++
                lastPressed!.removeFromSuperview()
                collectViews[countCollectViews - 1].setTitle("\(collectCounts[countCollectViews - 1])", forState: .Normal)
            }
            lastPressed = nil
        }
    }

    func getColorComponents(color: UIColor) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let components = CGColorGetComponents(color.CGColor)
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        let alpha = CGColorGetAlpha(color.CGColor)
        return (red, green, blue, alpha)
    }
    
    func random(min: Int, max: Int) -> Int {
        let randomInt = min + Int(arc4random_uniform(UInt32(max + 1 - min)))
        return randomInt
    }

    func setupLayoutForPoint(point: UIView) {
        var constraintsArray = Array<NSObject>()
        
        point.setTranslatesAutoresizingMaskIntoConstraints(false)
        let xPosMultiplier = CGFloat(random(20, max: 199)) / 100
        let yPosMultiplier = CGFloat(random(20, max: 199)) / 100
        let sizeMultiplier = CGFloat(random(50, max: 80)) / 1000
        
        constraintsArray.append(NSLayoutConstraint(item: point, attribute: .CenterX, relatedBy: .Equal, toItem: gameBoardView, attribute: .CenterX, multiplier: xPosMultiplier, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: point, attribute: .CenterY, relatedBy: .Equal, toItem: gameBoardView, attribute: .CenterY, multiplier: yPosMultiplier, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: point, attribute: .Width, relatedBy: .Equal, toItem: gameBoardView, attribute: .Width, multiplier: sizeMultiplier, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: point, attribute: .Height, relatedBy: .Equal, toItem: point, attribute: .Width, multiplier: 1.0, constant: 0))

        self.view.addConstraints(constraintsArray)
    }

    func setupLayout() {
        var constraintsArray = Array<NSObject>()
        gameBoardView.setTranslatesAutoresizingMaskIntoConstraints(false)
        buttonsView!.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // gameBoardView
        constraintsArray.append(NSLayoutConstraint(item: gameBoardView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: gameBoardView, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 0.9, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: gameBoardView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.90, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: gameBoardView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.80, constant: 0))
        
        
        // buttonsView!
        constraintsArray.append(NSLayoutConstraint(item: buttonsView!, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: buttonsView!, attribute: .CenterY, relatedBy: .Equal, toItem: gameBoardView, attribute: .CenterY, multiplier: 2.05, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: buttonsView!, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.9, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: buttonsView!, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.2, constant: 0))

        let multiplierXTab: [CGFloat] = [0.2, 1.8, 0.2, 1.8, 1.0]
        let multiplierYTab: [CGFloat] = [0.15, 0.15, 1.85, 1.85, 1.85]

        for index in 0..<collectViews.count {
            collectViews[index].setTranslatesAutoresizingMaskIntoConstraints(false)
            
            constraintsArray.append(NSLayoutConstraint(item: collectViews[index], attribute: .CenterX, relatedBy: .Equal, toItem: gameBoardView, attribute: .CenterX, multiplier:multiplierXTab[index], constant: 0.0))

            constraintsArray.append(NSLayoutConstraint(item: collectViews[index], attribute: .CenterY, relatedBy: .Equal, toItem: gameBoardView, attribute: .CenterY, multiplier: multiplierYTab[index], constant: 0.0))
            
            constraintsArray.append(NSLayoutConstraint(item: collectViews[index], attribute: .Width, relatedBy: .Equal, toItem: gameBoardView, attribute: .Width, multiplier: 0.1, constant: 0.0))
            
            constraintsArray.append(NSLayoutConstraint(item: collectViews[index], attribute: .Height, relatedBy: .Equal, toItem: collectViews[index], attribute: .Width, multiplier: 1.0, constant: 0.0))
            
            
        }

        self.view.addConstraints(constraintsArray)
        
    }
    
    
}


