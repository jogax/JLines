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

    var gameBoard = UIView()
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
        //gameBoard.frame = CGRectMake(self.view.frame.width / 3, self.view.frame.origin.y, self.view.frame.width * 2 / 3, self.view.frame.height)
        //gameBoard.layer.borderColor = UIColor.blackColor().CGColor
        //gameBoard.layer.borderWidth = 2
        //println("frame:\(gameBoard.frame)")
        let scene:SKScene = GameScene(size: view.bounds.size)
        let skView = SKView(frame: self.view.frame)
        self.view.addSubview(skView)
        //let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
    }
}

