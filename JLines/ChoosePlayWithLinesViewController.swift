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
        GV.language.callBackWhenNewLanguage(self.updateLanguage)
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
        
    }
    
    func callBonusPack() {
        
    }
    
    func callGreenPack() {
        
    }
    
    func returnToCaller() {
        self.dismissViewControllerAnimated(true, completion: {self.goWhenEnd()})        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = GV.lightSalmonColor
        buttonsView = MyButtonsView(paramTab: buttonsViewParamTab, callBack: callBackFromMyButtonsView)
        
        self.view.addSubview(buttonsView!)
        /*
        buttonsView!.backgroundColor = GV.darkTurquoiseColor
        buttonsView!.layer.cornerRadius = 10
        buttonsView!.layer.shadowOpacity = 1.0
        buttonsView!.layer.shadowOffset = CGSizeMake(3, 3)
        buttonsView!.layer.shadowColor = UIColor.blackColor().CGColor
    */
        setupLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateLanguage() {
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
        
        //constraintsArray.append(NSLayoutConstraint(item: buttonsView!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: buttonsViewHeight))
        
        self.view.addConstraints(constraintsArray)
        
    }


}
