//
//  ChoosePlayWithLinesViewController.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 19.06.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit

class ChoosePlayWithLinesViewController: UIViewController {
    var goWhenEnd: ()->()
    let buttonsViewParamTab = ["firstPackButton","bonusPackButton","greenPackButton","return"]
    
    var buttonsView: MyButtonsView?
    

    init(callBack: ()->()) {
        goWhenEnd = callBack
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func callBackFromMyButtonsView(index: Int) {
        switch index {
            case 0: callFirstPack()
            case 1: callBonusPack()
            case 2: callGreenPack()
            case 3: returnToCaller()
            default: returnToCaller()
        }
    }
    
    func callFirstPack() {
        let pagedViewController = PagedViewController(packageName: "FirstPack", callBack: continueAfterSettingsViewController)
        self.presentViewController(pagedViewController, animated: true, completion: {})
    }
    
    func callBonusPack() {
        
    }
    
    func callGreenPack() {
        
    }
    
    func continueAfterSettingsViewController() {
        
    }
    
    func returnToCaller() {
        self.dismissViewControllerAnimated(true, completion: {self.goWhenEnd()})        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = GV.backgroundColor //GV.lightSalmonColor
        buttonsView = MyButtonsView(verticalButtons: true, paramTab: buttonsViewParamTab, callBack: callBackFromMyButtonsView)
        
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
