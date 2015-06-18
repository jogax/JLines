//
//  ViewController.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 16.06.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var buttonsView = UIView()
    var countButtons = 3
    var linesPlayButton: MyButton?
    var colorPlayButton: MyButton?
    var settingsButton: MyButton?
    


    override func viewDidLoad() {
        
        let origin = self.view.frame.origin
        GV.gameSizeMultiplier = (self.view.frame.height / self.view.frame.width) / 1.8
        GV.notificationCenter.addObserver(self, selector: "handleGameControllChanging", name: GV.notificationGameControllChanged, object: nil)
        if GV.gameSizeMultiplier > 0.8  { // IPhone?
            GV.onIpad = false
        }
        
        if GV.onIpad {
            GV.dX = self.view.frame.width / 120
        } else {
            GV.dX = self.view.frame.width / 100
        }
        linesPlayButton = MyButton(title: "playWithLines")
        colorPlayButton = MyButton(title: "playWithColors")
        settingsButton  = MyButton(title: "settings")
        
        super.viewDidLoad()
        self.view.backgroundColor = GV.lightSalmonColor
        self.view.addSubview(buttonsView)
        buttonsView.addSubview(linesPlayButton!)
        buttonsView.addSubview(colorPlayButton!)
        buttonsView.addSubview(settingsButton!)
        buttonsView.backgroundColor = GV.darkTurquoiseColor
        buttonsView.layer.cornerRadius = 10
        buttonsView.layer.shadowOpacity = 1.0
        buttonsView.layer.shadowOffset = CGSizeMake(3, 3)
        buttonsView.layer.shadowColor = UIColor.blackColor().CGColor
        
        colorPlayButton!.addTarget(self, action: "callPlayWithColors:", forControlEvents: .TouchUpInside)
        settingsButton!.addTarget(self, action: "callSettings:", forControlEvents: .TouchUpInside)
        GV.language.callBackWhenNewLanguage(self.updateLanguage)
        
        
        setupLayout()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func callPlayWithColors(sender: UIButton) {
        let playWithColorViewController = PlayWithColorViewController(callBack: continueAfterPlayWithColorViewController)
        self.presentViewController(playWithColorViewController, animated: true, completion: {})
    }

    func callSettings(sender: UIButton) {
        let settingsViewController = SettingsViewController(callBack: continueAfterSettingsViewController)
        self.presentViewController(settingsViewController, animated: true, completion: {})
    }
    func updateLanguage() {
        linesPlayButton!.setTitle(GV.language.getText("playWithLines"), forState: .Normal)
        colorPlayButton!.setTitle(GV.language.getText("playWithColors"), forState: .Normal)
        settingsButton!.setTitle(GV.language.getText("settings"), forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func continueAfterSettingsViewController() {
        
    }
    
    func continueAfterPlayWithColorViewController() {
        
    }

    func setupLayout() {
        var constraintsArray = Array<NSObject>()
        buttonsView.setTranslatesAutoresizingMaskIntoConstraints(false)
        linesPlayButton!.setTranslatesAutoresizingMaskIntoConstraints(false)
        colorPlayButton!.setTranslatesAutoresizingMaskIntoConstraints(false)
        settingsButton!.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        
        let buttonsHeight = GV.dX * 15
        let buttonsGap = GV.dX * 3
        let buttonsViewHeight = CGFloat(countButtons) * (buttonsHeight + buttonsGap) + buttonsGap
        
        // buttonsView
        constraintsArray.append(NSLayoutConstraint(item: buttonsView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: buttonsView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 20 * GV.dX))
        
        constraintsArray.append(NSLayoutConstraint(item: buttonsView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.8, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: buttonsView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: buttonsViewHeight))

         // linesPlayButton
        constraintsArray.append(NSLayoutConstraint(item: linesPlayButton!, attribute: .CenterX, relatedBy: .Equal, toItem: buttonsView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: linesPlayButton!, attribute: .Top, relatedBy: .Equal, toItem: buttonsView, attribute: .Top, multiplier: 1.0, constant: buttonsGap))
        
        constraintsArray.append(NSLayoutConstraint(item: linesPlayButton!, attribute: .Width, relatedBy: .Equal, toItem: buttonsView, attribute: .Width, multiplier: 0.9, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: linesPlayButton!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: buttonsHeight))
        
        // colorPlayButton
        constraintsArray.append(NSLayoutConstraint(item: colorPlayButton!, attribute: .CenterX, relatedBy: .Equal, toItem: buttonsView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: colorPlayButton!, attribute: .Top, relatedBy: .Equal, toItem: linesPlayButton, attribute: .Bottom, multiplier: 1.0, constant: buttonsGap))
        
        constraintsArray.append(NSLayoutConstraint(item: colorPlayButton!, attribute: .Width, relatedBy: .Equal, toItem: buttonsView, attribute: .Width, multiplier: 0.9, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: colorPlayButton!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: buttonsHeight))
        
        // settingsButton
        constraintsArray.append(NSLayoutConstraint(item: settingsButton!, attribute: .CenterX, relatedBy: .Equal, toItem: buttonsView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: settingsButton!, attribute: .Top, relatedBy: .Equal, toItem: colorPlayButton, attribute: .Bottom, multiplier: 1.0, constant: buttonsGap))
        
        constraintsArray.append(NSLayoutConstraint(item: settingsButton!, attribute: .Width, relatedBy: .Equal, toItem: buttonsView, attribute: .Width, multiplier: 0.9, constant: 0))
        
        constraintsArray.append(NSLayoutConstraint(item: settingsButton!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: buttonsHeight))
        
        self.view.addConstraints(constraintsArray)
    
    }
    

}

