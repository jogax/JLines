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
        GV.spriteGameData = GV.dataStore.getSpriteData()        
        let gameWidth = view.frame.size.width * CGFloat(GV.onIpad ? 0.7 : 0.9)
        let gameHeight = view.frame.size.height * CGFloat(GV.onIpad ? 0.95 : 0.9)
        let gameX = (view.frame.size.width - gameWidth) / 2
        let gameY = (view.frame.size.height - gameHeight) / 2
        let frame = CGRectMake(gameX, gameY, gameWidth, gameHeight)
        //println("frame:\(gameBoard.frame)")
        GV.startTime = NSDate()
        let scene:GameScene = GameScene(size: CGSizeMake(gameWidth, gameHeight))
        let skView = SKView(frame: frame)
        self.view.addSubview(skView)
        //let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        scene.parentViewController = self
        skView.presentScene(scene)
    }
}

