//
//  GameViewController.swift
//  JSprites
//
//  Created by Jozsef Romhanyi on 11.07.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit
import SpriteKit


class PlayWithSpritesViewController: UIViewController {

    var goWhenEnd: ()->()
    var restartButton = UIButton()
    var undoButton = UIButton()

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
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Holz.png")!) //UIColor.whiteColor()
        let restartImage = UIImage(named: "restart") as UIImage?
        restartButton.setImage(restartImage, forState: UIControlState.Normal)
        let restartSelectedImage = UIImage(named: "restartPressed") as UIImage?
        restartButton.setImage(restartSelectedImage, forState: UIControlState.Selected)
        restartButton.bounds.origin = CGPointMake(30, view.frame.size.height - 20)
        
        view.addSubview(restartButton)
        view.addSubview(undoButton)
        
        GV.spriteGameData = GV.dataStore.getSpriteData()        
        let gameWidth = view.frame.size.width * CGFloat(GV.onIpad ? 0.7 : 0.9)
        let gameHeight = view.frame.size.height * CGFloat(GV.onIpad ? 0.85 : 0.85)
        let gameX = (view.frame.size.width - gameWidth) / 2
        let gameY = (view.frame.size.height - gameHeight) / 3
        let frame = CGRectMake(gameX, gameY, gameWidth, gameHeight)
        //println("frame:\(gameBoard.frame)")
        GV.startTime = NSDate()
        let scene:GameScene = GameScene(size: CGSizeMake(gameWidth, gameHeight))
        let skView = SKView(frame: frame)
        self.view.addSubview(skView)
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        scene.parentViewController = self
        skView.presentScene(scene)

        
    }
    
}

