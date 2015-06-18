//
//  PlayWithColorViewController.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 16.06.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit

class PlayWithColorViewController: UIViewController {

    var playingView = UIView()
    var evaluationView = UIView()
    var generatedColorView = UIView()
    var answerView = UIView()
    /*
    var redSliderView = UISlider()
    var greenSliderView = UISlider()
    var blueSliderView = UISlider()
*/
    var checkButton = MyButton(title: "checkResult")
    var newGameButton = MyButton(title: "newGame")
    var returnButton = MyButton(title: "return")
    var generatedRed:CGFloat = 0
    var generatedGreen:CGFloat = 0
    var generatedBlue:CGFloat = 0
    var choosedRed: CGFloat = 0
    var choosedGreen: CGFloat = 0
    var choosedBlue: CGFloat = 0
    var goWhenEnd: ()->()
    let viewRadius = 4 * GV.dX

    let countSliders = 3
    let countColumns = 4

    let redIndex = 1
    let greenIndex = 2
    let blueIndex = 3
    let generatedIndex = 1
    let choosedIndex = 2
    let differenceIndex = 3


    var sliderTab = [UISlider]()
    var evaluateTable = [MyLabel]()
    let headerRow: [String] = ["color", "generatedColor","choosedColor", "difference"]
    let headerColumn: [String] = ["", "red","green", "blue"]
    let colorTab: [UIColor] = [UIColor.redColor(), UIColor.greenColor(), UIColor.blueColor()]
    let sliderNameTab: [String] = ["redSliderView", "greenSliderView", "blueSliderView"]


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
        
        playingView.backgroundColor = UIColor.whiteColor()
        playingView.layer.cornerRadius = 5 * GV.dX
        playingView.layer.shadowColor = UIColor.blackColor().CGColor
        playingView.layer.shadowOffset = CGSizeMake(3,3)
        self.view.backgroundColor = GV.lightSalmonColor
        
        for index in 0..<countSliders {
            sliderTab.append(UISlider())
            sliderTab[index].backgroundColor = colorTab[index]
            sliderTab[index].minimumValue = 0
            sliderTab[index].maximumValue = 255
            sliderTab[index].layer.name = sliderNameTab[index]
            sliderTab[index].addTarget(self, action: "sliderMoved:", forControlEvents: UIControlEvents.ValueChanged)
            
        }
        //redSliderView.backgroundColor = UIColor.redColor()
        //greenSliderView.backgroundColor = UIColor.greenColor()
        //blueSliderView.backgroundColor = UIColor.blueColor()
        //redSliderView.minimumValue = 0
        //redSliderView.maximumValue = 255
        //greenSliderView.minimumValue = 0
        //greenSliderView.maximumValue = 255
        //blueSliderView.minimumValue = 0
        //blueSliderView.maximumValue = 255
        //redSliderView.setThumbImage(nil, forState:.Normal)
        //redSliderView.layer.name = "redSliderView"
        //greenSliderView.layer.name = "greenSliderView"
        //blueSliderView.layer.name = "blueSliderView"
        
        generatedColorView.layer.cornerRadius = viewRadius / 5
        answerView.backgroundColor = UIColor.clearColor()
        answerView.layer.borderWidth = 1
        answerView.layer.borderColor = UIColor.blackColor().CGColor
        answerView.layer.cornerRadius = viewRadius / 5
        checkButton.addTarget(self, action: "checkResults:", forControlEvents: .TouchUpInside)
        newGameButton.addTarget(self, action: "startNewGame:", forControlEvents: .TouchUpInside)
        returnButton.addTarget(self, action:"stopPlayWithColors:", forControlEvents: .TouchUpInside)
        //redSliderView.addTarget(self, action: "sliderMoved:", forControlEvents: UIControlEvents.ValueChanged)
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

        self.view.addSubview(playingView)
        playingView.addSubview(generatedColorView)
        playingView.addSubview(answerView)
        playingView.addSubview(sliderTab[redIndex - 1])
        playingView.addSubview(sliderTab[greenIndex - 1])
        playingView.addSubview(sliderTab[blueIndex - 1])
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
    
    func sliderMoved(sender: UISlider) {
        let name = sender.layer.name
        
        let sliderValue = "\(lroundf(sender.value))"
        //println("text: \(text), sliderValue: \(sliderValue)")
    }
    
    func startNewGame(sender: UIButton) {
        generateNewGame()
        answerView.backgroundColor = UIColor.clearColor()
        answerView.layer.borderColor = UIColor.blackColor().CGColor
        for index in 0..<countSliders {
            sliderTab[index].value = 0
        }
        //redSliderView.value = 0
        //greenSliderView.value = 0
        //blueSliderView.value = 0
    
    }
    
    func checkResults(sender: UIButton) {
        choosedRed = CGFloat(sliderTab[redIndex - 1].value) / 255
        choosedGreen = CGFloat(sliderTab[greenIndex - 1].value) / 255
        choosedBlue = CGFloat(sliderTab[blueIndex - 1].value) / 255
        answerView.backgroundColor = UIColor(red: choosedRed, green: choosedGreen, blue: choosedBlue, alpha: 1)
        answerView.layer.borderColor = UIColor(red: choosedRed, green: choosedGreen, blue: choosedBlue, alpha: 1).CGColor
        evaluateTable[redIndex * countColumns + choosedIndex].text = String(NSString(format:"%.3f", choosedRed))
        evaluateTable[greenIndex * countColumns + choosedIndex].text = String(NSString(format:"%.3f", choosedGreen))
        evaluateTable[blueIndex * countColumns + choosedIndex].text = String(NSString(format:"%.3f", choosedBlue))
        evaluateTable[redIndex * countColumns + generatedIndex].text = String(NSString(format:"%.3f", generatedRed))
        evaluateTable[greenIndex * countColumns + generatedIndex].text = String(NSString(format:"%.3f", generatedGreen))
        evaluateTable[blueIndex * countColumns + generatedIndex].text = String(NSString(format:"%.3f", generatedBlue))
        evaluateTable[redIndex * countColumns + differenceIndex].text = String(NSString(format:"%.3f", abs(generatedRed - choosedRed)))
        evaluateTable[greenIndex * countColumns + differenceIndex].text = String(NSString(format:"%.3f", abs(generatedGreen - choosedGreen)))
        evaluateTable[blueIndex * countColumns + differenceIndex].text = String(NSString(format:"%.3f", abs(generatedBlue - choosedBlue)))
        
    }

    func updateLanguage() {
        checkButton.setTitle(GV.language.getText("checkResult"), forState: .Normal)
    }

    func generateNewGame() {
        // generate a new random Color
        
        generatedRed = CGFloat(random(0, max: 255)) / 255
        generatedGreen = CGFloat(random(0, max: 255)) / 255
        generatedBlue = CGFloat(random(0, max: 255)) / 255
        let generatedColor = UIColor(red: generatedRed, green: generatedGreen, blue: generatedBlue, alpha: 1)

        for row in 1..<countColumns {
            for column in 1..<countColumns {
                println("row: \(row), column:\(column), index: \(row * countColumns + column)")
                evaluateTable[row * countColumns + column].text = ""
            }
        }

        generatedColorView.backgroundColor = generatedColor
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
        
        playingView.setTranslatesAutoresizingMaskIntoConstraints(false)
        generatedColorView.setTranslatesAutoresizingMaskIntoConstraints(false)
        answerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        for index in 0..<countSliders {
            sliderTab[index].setTranslatesAutoresizingMaskIntoConstraints(false)
        }
        //redSliderView.setTranslatesAutoresizingMaskIntoConstraints(false)
        //greenSliderView.setTranslatesAutoresizingMaskIntoConstraints(false)
        //blueSliderView.setTranslatesAutoresizingMaskIntoConstraints(false)
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
        constraintsArray.append(NSLayoutConstraint(item: playingView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: playingView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 20 * GV.dX))
        
        constraintsArray.append(NSLayoutConstraint(item: playingView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.95, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: playingView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: playingViewHeight))

        // generatedColorView
        constraintsArray.append(NSLayoutConstraint(item: generatedColorView, attribute: .Left, relatedBy: .Equal, toItem: playingView, attribute: .Left, multiplier: 1.0, constant: 4 * GV.dX))
        
        constraintsArray.append(NSLayoutConstraint(item: generatedColorView, attribute: .Bottom, relatedBy: .Equal, toItem: playingView, attribute: .Bottom, multiplier: 1.0, constant: -viewRadius))
        
        constraintsArray.append(NSLayoutConstraint(item: generatedColorView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 2 * viewRadius))
        
        constraintsArray.append(NSLayoutConstraint(item: generatedColorView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 2 * viewRadius))
        
        // answerView
        constraintsArray.append(NSLayoutConstraint(item: answerView, attribute: .Left, relatedBy: .Equal, toItem: generatedColorView, attribute: .Right, multiplier: 1.0, constant: viewRadius / 10))
        
        constraintsArray.append(NSLayoutConstraint(item: answerView, attribute: .CenterY, relatedBy: .Equal, toItem: generatedColorView, attribute: .CenterY, multiplier: 1.0, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: answerView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 2 * viewRadius))
        
        constraintsArray.append(NSLayoutConstraint(item: answerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 2 * viewRadius))

        for index in 0..<countSliders {
            constraintsArray.append(NSLayoutConstraint(item: sliderTab[index], attribute: .Left, relatedBy: .Equal, toItem: playingView, attribute: .Left, multiplier: 1.0, constant: viewRadius))
            if index == 0 {
                constraintsArray.append(NSLayoutConstraint(item: sliderTab[index], attribute: .Top, relatedBy: .Equal, toItem: playingView, attribute: .Top, multiplier: 1.0, constant: viewRadius))
            } else {
                constraintsArray.append(NSLayoutConstraint(item: sliderTab[index], attribute: .Top, relatedBy: .Equal, toItem: sliderTab[index - 1], attribute: .Bottom, multiplier: 1.0, constant: viewRadius))
            }
            
            constraintsArray.append(NSLayoutConstraint(item: sliderTab[index], attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 16 * viewRadius))
            
            constraintsArray.append(NSLayoutConstraint(item: sliderTab[index], attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 1.0 * viewRadius))
        }
/*
        // redSliderView
        constraintsArray.append(NSLayoutConstraint(item: redSliderView, attribute: .Left, relatedBy: .Equal, toItem: playingView, attribute: .Left, multiplier: 1.0, constant: viewRadius))
        
        constraintsArray.append(NSLayoutConstraint(item: redSliderView, attribute: .Top, relatedBy: .Equal, toItem: playingView, attribute: .Top, multiplier: 1.0, constant: 1 * viewRadius))
        
        constraintsArray.append(NSLayoutConstraint(item: redSliderView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 16 * viewRadius))
        
        constraintsArray.append(NSLayoutConstraint(item: redSliderView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 1.0 * viewRadius))
       
        // greenSliderView
        constraintsArray.append(NSLayoutConstraint(item: greenSliderView, attribute: .Left, relatedBy: .Equal, toItem: playingView, attribute: .Left, multiplier: 1.0, constant: viewRadius))
        
        constraintsArray.append(NSLayoutConstraint(item: greenSliderView, attribute: .Top, relatedBy: .Equal, toItem: redSliderView, attribute: .Bottom, multiplier: 1.0, constant: viewRadius))
        
        constraintsArray.append(NSLayoutConstraint(item: greenSliderView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 16 * viewRadius))
        
        constraintsArray.append(NSLayoutConstraint(item: greenSliderView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 1.0 * viewRadius))
        
        // blueSliderView
        constraintsArray.append(NSLayoutConstraint(item: blueSliderView, attribute: .Left, relatedBy: .Equal, toItem: playingView, attribute: .Left, multiplier: 1.0, constant: viewRadius))
        
        constraintsArray.append(NSLayoutConstraint(item: blueSliderView, attribute: .Top, relatedBy: .Equal, toItem: greenSliderView, attribute: .Bottom, multiplier: 1.0, constant: viewRadius))
        
        constraintsArray.append(NSLayoutConstraint(item: blueSliderView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 16 * viewRadius))
        
        constraintsArray.append(NSLayoutConstraint(item: blueSliderView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 1.0 * viewRadius))
*/
        // evaluationView
        constraintsArray.append(NSLayoutConstraint(item: evaluationView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: evaluationView, attribute: .Top, relatedBy: .Equal, toItem: playingView, attribute: .Bottom, multiplier: 1.0, constant: 15 * GV.dX))
        
        constraintsArray.append(NSLayoutConstraint(item: evaluationView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.95, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: evaluationView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: playingViewHeight))

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
