//
//  MySKContainer.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 13.07.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

enum MySKNodeType: Int {
    case SpriteType = 0, MovingSpriteType, ContainerType
}
import SpriteKit

class MySKNode: SKSpriteNode {
    var hitCounter: Int {
        didSet {
            hitLabel.text = "\(hitCounter)"
        }
    }
    var column = 0
    var row = 0
    var colorIndex = 0
    
    let type: MySKNodeType
    var hitLabel = SKLabelNode()
    

    init(texture: SKTexture, type:MySKNodeType) {
        self.type = type
        hitCounter = type == .ContainerType ? 0 : 1  // Sprites have a Startvalue 1
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        hitLabel.position = self.position
        //hitLabel.size = self.size
        hitLabel.fontSize = 15;
        hitLabel.fontName = "ArielBold"
        hitLabel.fontColor = SKColor.blackColor()
        hitLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        hitLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        hitLabel.text = "\(hitCounter)"
        hitLabel.userInteractionEnabled = false
        self.addChild(hitLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText() {
        hitLabel.text = "\(hitCounter)"
    }
}
