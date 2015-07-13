//
//  ChoosePlayViewController.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 01.07.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit

class ChoosePlayViewController: UIViewController {
    var goWhenEnd: ()->()
    let buttonsViewParamTab = [
        ["firstPackButton","bonusPackButton","greenPackButton","return"],
        ["playWithColors","playWithPoints","playWithSprites","return"]
    ]
    let arrayIndex: Int
    
    var buttonsView: MyButtonsView?
    
    
    init(index: Int, callBack: ()->()) {
        
        self.arrayIndex = index
        goWhenEnd = callBack
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func callBackFromMyButtonsView(index: Int) {
        switch (arrayIndex, index) {
        case (0, 0): callFirstPack()
        case (0, 1): callBonusPack()
        case (0, 2): callGreenPack()
        case (0, 3): returnToCaller()
        case (1, 0): callPlayWithColors()
        case (1, 1): callPlayWithPoints()
        case (1, 2): callPlayWithSprites()
        default: returnToCaller()
        }
    }
    
    func callFirstPack() {
        let pagedViewController = PagedViewController(packageName: "FirstPack", callBack: continueAfterViewController)
        self.presentViewController(pagedViewController, animated: true, completion: {})
    }
    
    func callBonusPack() {
        
    }
    
    func callGreenPack() {
        
    }
    
    func callPlayWithColors() {
        let playWithColorViewController = PlayWithColorViewController(callBack: continueAfterViewController)
        self.presentViewController(playWithColorViewController, animated: true, completion: {})
    }
    
    func callPlayWithPoints(){
        let playWithPointsViewController = PlayWithPointsViewController(callBack: continueAfterViewController)
        self.presentViewController(playWithPointsViewController, animated: true, completion: {})
    }

    func callPlayWithSprites(){
        let playWithSpritesViewController = PlayWithSpritesViewController(callBack: continueAfterViewController)
        self.presentViewController(playWithSpritesViewController, animated: true, completion: {})
    }
    
    func continueAfterViewController() {
        
    }
    
    func returnToCaller() {
        self.dismissViewControllerAnimated(true, completion: {self.goWhenEnd()})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = GV.backgroundColor //GV.lightSalmonColor
        buttonsView = MyButtonsView(verticalButtons: true, paramTab: buttonsViewParamTab[arrayIndex], callBack: callBackFromMyButtonsView)
        
        self.view.addSubview(buttonsView!)
        setupLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func callBack(sender: UIButton) {
        
    }
    
    func setupLayout() {
        var constraintsArray = Array<NSObject>()
        
        let countButtons: CGFloat = 5
        let buttonsHeight = self.view.frame.height * 0.08
        let buttonsGap = buttonsHeight / 5
        let buttonsViewHeight = countButtons * (buttonsHeight + buttonsGap) + buttonsGap
        
        
        buttonsView!.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // buttonsView
        constraintsArray.append(NSLayoutConstraint(item: buttonsView!, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        
        constraintsArray.append(NSLayoutConstraint(item: buttonsView!, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 10 * GV.dX))
        
        constraintsArray.append(NSLayoutConstraint(item: buttonsView!, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.8, constant: 0))
        
        self.view.addConstraints(constraintsArray)
        
    }
    
    
}
