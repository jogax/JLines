//
//  ViewController.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 16.06.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var buttonsView: MyButtonsView?
    let buttonsViewParamTab = ["playWithLines","playWithColors","settings"]


    override func viewDidLoad() {
        
        let origin = self.view.frame.origin
        GV.gameSizeMultiplier = (self.view.frame.height / self.view.frame.width) / 1.8
        //GV.notificationCenter.addObserver(self, selector: "handleGameControllChanging", name: GV.notificationGameControllChanged, object: nil)
        if GV.gameSizeMultiplier > 0.8  { // IPhone?
            GV.onIpad = false
        }
        
        if GV.onIpad {
            GV.dX = self.view.frame.width / 100
            GV.dY = self.view.frame.height / 60
        } else {
            GV.dX = self.view.frame.width / 100
            GV.dY = self.view.frame.height / 100
        }
        super.viewDidLoad()
        buttonsView = MyButtonsView(paramTab: buttonsViewParamTab, callBack: callBackFromMyButtonsView)
        self.view.backgroundColor = GV.lightSalmonColor
        self.view.addSubview(buttonsView!)
        
        setupLayout()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func callPlayWithColors() {
        let playWithColorViewController = PlayWithColorViewController(callBack: continueAfterPlayWithColorViewController)
        self.presentViewController(playWithColorViewController, animated: true, completion: {})
    }

    func callSettings() {
        let settingsViewController = SettingsViewController(callBack: continueAfterSettingsViewController)
        self.presentViewController(settingsViewController, animated: true, completion: {})
    }
    
    func callChoosePlayWithLines() {
        let choosePlayWithLinesViewController = ChoosePlayWithLinesViewController(callBack: continueAfterPlayWithLinesViewController)
        self.presentViewController(choosePlayWithLinesViewController, animated: true, completion: {})
    }
    
    func callBackFromMyButtonsView(index: Int) {
        switch index {
        case 0: callChoosePlayWithLines()
        case 1: callPlayWithColors()
        case 2: callSettings()
        default: callSettings()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func continueAfterSettingsViewController() {
        
    }
    
    func continueAfterPlayWithColorViewController() {
        
    }
    
    func continueAfterPlayWithLinesViewController() {
        
    }

    func setupLayout() {
        var constraintsArray = Array<NSObject>()
        buttonsView!.setTranslatesAutoresizingMaskIntoConstraints(false)
        let buttonsHeight = 3 * GV.dX
        let gap = 3 * GV.dX
        let buttonsViewHeight = CGFloat(buttonsViewParamTab.count) * (buttonsHeight + gap) + gap
        
        
        // buttonsView
        constraintsArray.append(NSLayoutConstraint(item: buttonsView!, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: buttonsView!, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 10 * GV.dX))
        
        constraintsArray.append(NSLayoutConstraint(item: buttonsView!, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.8, constant: 0))

        self.view.addConstraints(constraintsArray)
    
    }
    

}

