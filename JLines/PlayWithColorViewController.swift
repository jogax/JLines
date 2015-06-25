//
//  PlayWithColorViewController.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 16.06.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit

class PlayWithColorViewController: UIViewController {

    //var playingView = UIView()
    var playingView: MyColorChooseView?
    var evaluationView = UIView()
    //var generatedColorView = UIView()
    var answerView = UIView()
    var generatedColor: UIColor = UIColor.whiteColor()
    var checkButton = MyButton(title: "checkResult")
    var newGameButton = MyButton(title: "newGame")
    var returnButton = MyButton(title: "return")
    
    var generatedTab = [CGFloat]()
    var choosedTab = [CGFloat]()
    
    var goWhenEnd: ()->()
    let viewRadius = 4 * GV.dX

    //let countSliders = 3
    let countColumns = 4
    let countColors = 3

    let redIndex = 1
    let greenIndex = 2
    let blueIndex = 3
    let generatedIndex = 1
    let choosedIndex = 2
    let differenceIndex = 3


    //var sliderTab = [UISlider]()
    var evaluateTable = [MyLabel]()
    let headerRow: [String] = ["color", "generatedColor","choosedColor", "difference"]
    let headerColumn: [String] = ["", "red","green", "blue"]
    //let colorTab: [UIColor] = [UIColor.redColor(), UIColor.greenColor(), UIColor.blueColor()]
    //let sliderNameTab: [String] = ["redSliderView", "greenSliderView", "blueSliderView"]


    var headTableNameLabel = MyLabel(text: "evaluateResults")

    
    init(callBack: ()->()) {
        goWhenEnd = callBack
        
        
        super.init(nibName: nil, bundle: nil)
        
        GV.language.callBackWhenNewLanguage(self.updateLanguage)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        playingView.backgroundColor = UIColor.whiteColor()
        playingView.layer.cornerRadius = 5 * GV.dX
        playingView.layer.shadowColor = UIColor.blackColor().CGColor
        playingView.layer.shadowOffset = CGSizeMake(3,3)
    */
        self.view.backgroundColor = GV.lightSalmonColor
        
        
        for index in 0..<countColors {
            //sliderTab.append(UISlider())
            choosedTab.append(0)
            generatedTab.append(0)
        }
        
        
        
        answerView.alpha = 0
        answerView.backgroundColor = UIColor.clearColor()
        answerView.layer.borderWidth = 1
        answerView.layer.borderColor = UIColor.blackColor().CGColor
        answerView.layer.cornerRadius = 4 * GV.dX
        checkButton.addTarget(self, action: "checkResults:", forControlEvents: .TouchUpInside)
        newGameButton.addTarget(self, action: "startNewGame:", forControlEvents: .TouchUpInside)
        returnButton.addTarget(self, action:"stopPlayWithColors:", forControlEvents: .TouchUpInside)
        evaluationView.backgroundColor = UIColor.clearColor()
        evaluationView.layer.borderColor = UIColor.blackColor().CGColor
        evaluationView.layer.borderWidth = 2.0
        headTableNameLabel.layer.borderColor = UIColor.clearColor().CGColor
        headTableNameLabel.layer.borderWidth = 0
        

        for row in 0..<4 {
            for column in 0..<4 {
                if row == 0 {
                   evaluateTable.append(MyLabel(text: headerRow[column]))
                } else {
                    if column == 0 {
                        evaluateTable.append(MyLabel(text: headerColumn[row]))
                    } else {
                        evaluateTable.append(MyLabel())
                    }
                }
                evaluationView.addSubview(evaluateTable[4 * row + column])
            }
        }
        generateNewGame()
        playingView = MyColorChooseView(returnWhenEnded: goHearWhenColorChoosed, sliderMoved: sliderMoved, withOKButton: false, colorInCenter: generatedColor)

        self.view.addSubview(playingView!)
        playingView!.addSubview(answerView)
        //playingView!.addSubview(generatedColorView)
        self.view.addSubview(evaluationView)
        self.view.addSubview(headTableNameLabel)
        self.view.addSubview(checkButton)
        self.view.addSubview(newGameButton)
        self.view.addSubview(returnButton)
        
        setupLayout()
    }

    func stopPlayWithColors(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: {self.goWhenEnd()})
    }
    
    func goHearWhenColorChoosed(color: UIColor) {
        
    }

    func startNewGame(sender: UIButton) {
        generateNewGame()
        answerView.backgroundColor = UIColor.clearColor()
        answerView.layer.borderColor = UIColor.blackColor().CGColor
        playingView!.reset(generatedColor)

    }

    func sliderMoved(color: UIColor) {
        
    }
    func checkResults(sender: UIButton) {
        var alpha: CGFloat = 0
        //choosedTab[index] = CGFloat(sliderTab[index].value) / 255
        choosedTab = playingView!.getChoosedColorCompnents()
        for index in 0..<choosedTab.count {
            let colorIndex = index + 1
            let components = playingView!.getChoosedColorCompnents()
            evaluateTable[colorIndex * countColumns + choosedIndex].text = String(NSString(format:"%.3f", choosedTab[index]))
            evaluateTable[colorIndex * countColumns + generatedIndex].text = String(NSString(format:"%.3f", generatedTab[index]))
            evaluateTable[colorIndex * countColumns + differenceIndex].text = String(NSString(format:"%.3f", abs(generatedTab[index] - choosedTab[index])))
            let difference = abs(generatedTab[index] - choosedTab[index])
            if  difference < 0.05 {
                alpha = (0.05 - difference) * 20
                evaluateTable[colorIndex * countColumns + differenceIndex].backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: alpha)
            } else {
                alpha = 1
                evaluateTable[colorIndex * countColumns + differenceIndex].backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: alpha)
            }
        }
        playingView!.disable()
        checkButton.enabled = false
        checkButton.alpha = 0.5
    }
    func updateLanguage() {
        //checkButton.setTitle(GV.language.getText("checkResult"), forState: .Normal)
    }

    func generateNewGame() {
        // generate a new random Color
        checkButton.enabled = true
        checkButton.alpha = 1.0
        for index in 0..<countColors {
            generatedTab[index] = CGFloat(random(0, max: 255)) / 255
        }
        generatedColor = UIColor(red: generatedTab[redIndex - 1], green: generatedTab[greenIndex - 1], blue: generatedTab[blueIndex - 1], alpha: 1)

        for row in 1..<countColumns {
            for column in 1..<countColumns {
                evaluateTable[row * countColumns + column].text = ""
                evaluateTable[row * countColumns + column].backgroundColor = UIColor.clearColor()
            }
        }

        //generatedColorView.backgroundColor = generatedColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func random(min: Int, max: Int) -> Int {
        let randomInt = min + Int(arc4random_uniform(UInt32(max + 1 - min)))
        return randomInt
    }
    func setupLayout() {
        var constraintsArray = Array<NSObject>()
        
        playingView!.setTranslatesAutoresizingMaskIntoConstraints(false)
        //generatedColorView.setTranslatesAutoresizingMaskIntoConstraints(false)
        answerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        checkButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        newGameButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        returnButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        evaluationView.setTranslatesAutoresizingMaskIntoConstraints(false)
        headTableNameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        for row in 0..<4 {
            for column in 0..<4 {
                evaluateTable[4 * row + column].setTranslatesAutoresizingMaskIntoConstraints(false)
            }
        }
        
        let slidersHeight = GV.dX * 15
        let playingViewHeight = 50 * GV.dX
        let rowHeight = 8 * GV.dX
    
        
        // playingView
        constraintsArray.append(NSLayoutConstraint(item: playingView!, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: playingView!, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 10 * GV.dX))
        
        constraintsArray.append(NSLayoutConstraint(item: playingView!, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.95, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: playingView!, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.4, constant: 0))
        

        // answerView
        constraintsArray.append(NSLayoutConstraint(item: answerView, attribute: .CenterX, relatedBy: .Equal, toItem: playingView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: answerView, attribute: .Top, relatedBy: .Equal, toItem: playingView, attribute: .Top, multiplier: 1.0, constant: 1 * viewRadius))
        
        constraintsArray.append(NSLayoutConstraint(item: answerView, attribute: .Width, relatedBy: .Equal, toItem: playingView, attribute: .Width, multiplier: 0.9, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: answerView, attribute: .Height, relatedBy: .Equal, toItem: playingView, attribute: .Height, multiplier: 0.4, constant: 0))
        
        // generatedColorView
        //constraintsArray.append(NSLayoutConstraint(item: generatedColorView, attribute: .CenterX, relatedBy: .Equal, toItem: answerView, attribute: .CenterX, multiplier: 1.0, constant: 4 * GV.dX))
        
        //constraintsArray.append(NSLayoutConstraint(item: generatedColorView, attribute: .CenterY, relatedBy: .Equal, toItem: answerView, attribute: .CenterY, multiplier: 1.0, constant:0))
        
        //constraintsArray.append(NSLayoutConstraint(item: generatedColorView, attribute: .Width, relatedBy: .Equal, toItem: answerView, attribute: .Width, multiplier: 0.6, constant: 0))
        
        //constraintsArray.append(NSLayoutConstraint(item: generatedColorView, attribute: .Height, relatedBy: .Equal, toItem: answerView, attribute: .Height, multiplier: 0.6, constant: 0))
        
        // evaluationView
        constraintsArray.append(NSLayoutConstraint(item: evaluationView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: evaluationView, attribute: .Top, relatedBy: .Equal, toItem: playingView, attribute: .Bottom, multiplier: 1.0, constant: 15 * GV.dX))
        
        constraintsArray.append(NSLayoutConstraint(item: evaluationView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.95, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: evaluationView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: playingViewHeight * GV.ipadKorrektur))

        // headTableNameLabel
        constraintsArray.append(NSLayoutConstraint(item: headTableNameLabel, attribute: .CenterX, relatedBy: .Equal, toItem: evaluationView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: headTableNameLabel, attribute: .Top, relatedBy: .Equal, toItem: evaluationView, attribute: .Top, multiplier: 1.0, constant: -10 * GV.dX))
        
        constraintsArray.append(NSLayoutConstraint(item: headTableNameLabel, attribute: .Width, relatedBy: .Equal, toItem: evaluationView, attribute: .Width, multiplier: 1.0, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: headTableNameLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: rowHeight))

        // evalueateLabels
        for row in 0..<4 {
            for column in 0..<4 {
                if column == 0 {
                    constraintsArray.append(NSLayoutConstraint(item: evaluateTable[4 * row + column], attribute: .Left, relatedBy: .Equal, toItem: evaluationView, attribute: .Left, multiplier: 1.0, constant: 0.0))
                } else {
                    constraintsArray.append(NSLayoutConstraint(item: evaluateTable[4 * row + column], attribute: .Left, relatedBy: .Equal, toItem: evaluateTable[4 * row + column - 1], attribute: .Right, multiplier: 1.0, constant: 0.0))
                }
                if row == 0 {
                    constraintsArray.append(NSLayoutConstraint(item: evaluateTable[4 * row + column], attribute: .Top, relatedBy: .Equal, toItem: evaluationView, attribute: .Top, multiplier: 1.0, constant: 0))
                } else {
                    constraintsArray.append(NSLayoutConstraint(item: evaluateTable[4 * row + column], attribute: .Top, relatedBy: .Equal, toItem: evaluateTable[4 * (row - 1) + column], attribute: .Bottom, multiplier: 1.0, constant: 0))
                }
                constraintsArray.append(NSLayoutConstraint(item: evaluateTable[4 * row + column], attribute: .Width, relatedBy: .Equal, toItem: evaluationView, attribute: .Width, multiplier: 0.25, constant: 0))
                
                constraintsArray.append(NSLayoutConstraint(item: evaluateTable[4 * row + column], attribute: .Height, relatedBy: .Equal, toItem: evaluationView, attribute: .Height, multiplier: 0.25, constant: 0))
            }
        }

       
        // returnButton
        
        constraintsArray.append(NSLayoutConstraint(item: returnButton, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 0.4, constant: 1))
        
        constraintsArray.append(NSLayoutConstraint(item: returnButton, attribute: .Top, relatedBy: .Equal, toItem: evaluationView, attribute: .Bottom, multiplier: 1.0, constant: viewRadius))
        
        constraintsArray.append(NSLayoutConstraint(item: returnButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 7 * viewRadius))
        
        constraintsArray.append(NSLayoutConstraint(item: returnButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 2 * viewRadius))
        
        
        // checkButton
        constraintsArray.append(NSLayoutConstraint(item: checkButton, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 1))
        
        constraintsArray.append(NSLayoutConstraint(item: checkButton, attribute: .Top, relatedBy: .Equal, toItem: evaluationView, attribute: .Bottom, multiplier: 1.0, constant: viewRadius))
        
        constraintsArray.append(NSLayoutConstraint(item: checkButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 7 * viewRadius))
        
        constraintsArray.append(NSLayoutConstraint(item: checkButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 2 * viewRadius))

        // newGameButton
        constraintsArray.append(NSLayoutConstraint(item: newGameButton, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.6, constant: 1))
        
        constraintsArray.append(NSLayoutConstraint(item: newGameButton, attribute: .Top, relatedBy: .Equal, toItem: evaluationView, attribute: .Bottom, multiplier: 1.0, constant: viewRadius))
        
        constraintsArray.append(NSLayoutConstraint(item: newGameButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 7 * viewRadius))
        
        constraintsArray.append(NSLayoutConstraint(item: newGameButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 2 * viewRadius))

        self.view.addConstraints(constraintsArray)

    }
    

}