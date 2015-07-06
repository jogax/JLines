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

    let maxGeneratedColorCount = 20
    var goWhenEnd: ()->()
    var gameBoardView = UIView()
    var buttonsView: MyButtonsView?
    let buttonsViewParamTab = ["return", "pause", "newGame"]
    var collectViews = [MyButton]()
    var collectCounts = [Int]()
    var trashView: MyButton?
    var trashCount = 0
    var countColorsProCollection = [Int]()
    let countCollectViews = 4
    var timer: NSTimer?
    //var points = [MySprite]()
    var playColors = [UIColor]()
    var lastPressed: MySprite?
    var point: MySprite? 

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
            countColorsProCollection.append(maxGeneratedColorCount)
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
            playColors.append(color)
            collectViews[index].backgroundColor = color
            gameBoardView.addSubview(collectViews[index])
        }
        trashView = MyButton()
        trashView!.backgroundColor = UIColor.whiteColor()
        trashView!.layer.borderColor = UIColor.blackColor().CGColor
        trashView!.layer.borderWidth = 2.0
        trashView!.layer.shadowColor = UIColor.lightGrayColor().CGColor
        trashView!.layer.shadowOffset = CGSizeMake(2,2)
        trashView!.layer.cornerRadius = 5
        trashView?.enabled = false
        
        //trashView!.textAlignment = .Center
        gameBoardView.addSubview(trashView!)
        setupLayout()
        generateAPoint()
        

        // Do any additional setup after loading the view.
    }
    
    
    func callBackFromMyButtonsView(index: Int) {
        switch index {
        case 0: stopPlayWithPoints()
        case 1: waitPlayWithPoints()
        case 2: startNewGame()
        default: stopPlayWithPoints()
        }
    }
    
    func waitPlayWithPoints() {
        
    }
    
    func startNewGame() {
        
    }

    func stopPlayWithPoints () { //(sender: UIButton) {
        self.timer!.invalidate()
        var mySpriteTab = [MySprite]()
        let counter = gameBoardView.subviews.count
        for index in 0..<gameBoardView.subviews.count {
            println("index: \(index)")
            if gameBoardView.subviews[index].type == "MySprite" {
                mySpriteTab.append(gameBoardView.subviews[index] as! MySprite)
            }
        }
        for index in 0..<mySpriteTab.count {
            mySpriteTab[index].stopObject()
        }
        mySpriteTab.removeAll(keepCapacity: false)
        println("SpritesCount: \(MySprite.spritesCount)")
        self.dismissViewControllerAnimated(true, completion: {self.goWhenEnd()})
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generateAPoint() {
        let nextTime = Double(GV.random(5, max: 50)) / 15
        var colorTab = [Int]()
        for index in 0..<countColorsProCollection.count {
            if countColorsProCollection[index] > 0 {
                colorTab.append(index)
            }
        }
        if colorTab.count > 0 {
            let colorIndex = colorTab[GV.random(0, max: colorTab.count - 1)]
            countColorsProCollection[colorIndex]--
            self.timer = NSTimer.scheduledTimerWithTimeInterval(nextTime, target: self, selector: Selector("generateAPoint"), userInfo: nil, repeats: false)
            point = MySprite(callBack: callBackWhenMySpriteExits, index: colorIndex)
            //points.append(point)
            point!.backgroundColor = playColors[colorIndex]
            point!.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
            gameBoardView.addSubview(point!)
            //point.layer.name = "\(points.count)"
            
            println("Anzahl Sprites: \(MySprite.spritesCount)")
            setupLayoutForPoint(point!)
        }
    }
    
    func callBackWhenMySpriteExits(sender: MySprite) {
        let index = sender.index
        collectCounts[index]--
        collectViews[index].setTitle("\(collectCounts[index])", forState: .Normal)
    }
    
    func buttonPressed (sender: MySprite) {
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
                lastPressed!.timer.invalidate()
                lastPressed!.removeFromSuperview()
                collectViews[index!].setTitle("\(collectCounts[index!])", forState: .Normal)
                //println("Anzahl Sprites nach delete: \(MySprite.spritesCount)")
            } else {
                trashCount++
                lastPressed!.removeFromSuperview()
                trashView!.setTitle("\(trashCount)", forState: .Normal)
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
    
    func setupLayoutForPoint(point: UIView) {
        var constraintsArray = Array<NSObject>()
        
        point.setTranslatesAutoresizingMaskIntoConstraints(false)
        let xPosMultiplier = CGFloat(GV.random(20, max: 190)) / 100
        let yPosMultiplier = CGFloat(GV.random(20, max: 190)) / 100
        let sizeMultiplier = CGFloat(GV.random(70, max: 100)) / 1000
        
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
        trashView!.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // gameBoardView
        constraintsArray.append(NSLayoutConstraint(item: gameBoardView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: gameBoardView, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 0.9, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: gameBoardView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.90, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: gameBoardView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.80, constant: 0))
        
        // trashView!
        constraintsArray.append(NSLayoutConstraint(item: trashView!, attribute: .CenterX, relatedBy: .Equal, toItem: gameBoardView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: trashView!, attribute: .CenterY, relatedBy: .Equal, toItem: gameBoardView, attribute: .CenterY, multiplier: 1.85, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: trashView!, attribute: .Width, relatedBy: .Equal, toItem: gameBoardView, attribute: .Width, multiplier: 0.10, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: trashView!, attribute: .Height, relatedBy: .Equal, toItem: gameBoardView, attribute: .Width, multiplier: 0.10, constant: 0))
        
       
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


