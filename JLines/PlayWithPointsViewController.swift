//
//  PlayWithPointsViewController.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 01.07.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit

class PlayWithPointsViewController: UIViewController {

    var goWhenEnd: ()->()
    var gameBoardView = UIView()
    var buttonsView: MyButtonsView?
    let buttonsViewParamTab = ["return"]
    var collectViews = [UIView]()
    let countCollectViews = 4

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
            collectViews.append(UIView())
            collectViews[index].backgroundColor = UIColor.whiteColor()
            collectViews[index].layer.borderColor = UIColor.blackColor().CGColor
            collectViews[index].layer.borderWidth = 1
            collectViews[index].layer.cornerRadius = 10
            gameBoardView.addSubview(collectViews[index])
        }
        setupLayout()
        

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

        let multiplierXTab: [CGFloat] = [0.2, 1.8, 0.2, 1.8]
        let multiplierYTab: [CGFloat] = [0.2, 0.2, 1.8, 1.8]

        for index in 0..<collectViews.count {
            collectViews[index].setTranslatesAutoresizingMaskIntoConstraints(false)
            
            constraintsArray.append(NSLayoutConstraint(item: collectViews[index], attribute: .CenterX, relatedBy: .Equal, toItem: gameBoardView, attribute: .CenterX, multiplier:multiplierXTab[index], constant: 0.0))

            constraintsArray.append(NSLayoutConstraint(item: collectViews[index], attribute: .CenterY, relatedBy: .Equal, toItem: gameBoardView, attribute: .CenterY, multiplier: multiplierYTab[index], constant: 0.0))
            
            constraintsArray.append(NSLayoutConstraint(item: collectViews[index], attribute: .Width, relatedBy: .Equal, toItem: gameBoardView, attribute: .Width, multiplier: 0.1, constant: 0.0))
            
            constraintsArray.append(NSLayoutConstraint(item: collectViews[index], attribute: .Height, relatedBy: .Equal, toItem: gameBoardView, attribute: .Height, multiplier: 0.1, constant: 0.0))
            
            
        }

        self.view.addConstraints(constraintsArray)
        
    }
    
    
}


