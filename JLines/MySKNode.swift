//
//  MySKContainer.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 13.07.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

enum MySKNodeType: Int {
    case SpriteType = 0, ContainerType
}
import SpriteKit

class MySKNode: SKSpriteNode {
    var hitCounter: Int = 0
    let type: MySKNodeType
    

    init(texture: SKTexture, type:MySKNodeType) {
        self.type = type
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
