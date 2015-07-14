//
//  GameScene.swift
//  JSprites
//
//  Created by Jozsef Romhanyi on 11.07.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

struct PhysicsCategory {
    static let None         : UInt32 = 0
    static let All          : UInt32 = UInt32.max
    static let Sprite       : UInt32 = 0b1      // 2
    static let Container    : UInt32 = 0b10       // 1
    static let MovingSprite : UInt32 = 0b100     // 4
}

struct Container {
    let mySKNode: MySKNode
    var label: SKLabelNode
    var countHits: Int
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let maxGeneratedColorCount = 10
    let countContainers = GV.onIpad ? 8 : 6
    var timer: NSTimer?
    var containers = [Container]()
    var countColorsProContainer = [Int]()
    var movedFromNode: SKNode!
    var backButton: SKButton?
    let tableColumns = 10
    let tableRows = 10
    var gameArray = [[Bool]]()
    var tableCellSize: CGFloat = 0

    /*
    override init(size: CGSize) {
        tableCellSize = size.width / CGFloat(tableColumns)
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    */
    override func didMoveToView(view: SKView) {
        for column in 0..<tableRows {
            gameArray.append(Array(count: tableRows, repeatedValue:true))
         }
        let xDelta = size.width / CGFloat(countContainers)
        tableCellSize = size.width / CGFloat(tableRows)
        for index in 0..<countContainers {
            let aktColor = GV.colorSets[GV.colorSetIndex][index + 1].CGColor
            let containerTexture = SKTexture(image: GV.drawCircle(CGSizeMake(50,50), imageColor: aktColor))
            let centerX = (size.width / CGFloat(countContainers)) * CGFloat(index) + xDelta / 2
            let centerY = size.height * 0.88
            let cont: Container = Container(mySKNode: MySKNode(texture: containerTexture, type: .ContainerType), label: SKLabelNode(), countHits: 0)
            containers.append(cont)
            containers[index].mySKNode.position = CGPoint(x: centerX, y: centerY)
            let myLabel = SKLabelNode()
            containers[index].label.text = "0"
            containers[index].label.fontSize = 20;
            containers[index].label.fontName = "ArielBold"
            //myLabel.color = SKColor.blackColor()
            containers[index].label.position = CGPointMake(CGRectGetMidX(containers[index].mySKNode.frame), CGRectGetMidY(containers[index].mySKNode.frame) * 1.05)
            containers[index].label.name = "label"
            containers[index].label.fontColor = SKColor.blackColor()
            //myLabel.colorBlendFactor = 1
            self.addChild(containers[index].label)
            
            containers[index].mySKNode.name = "\(index)"
            containers[index].mySKNode.physicsBody = SKPhysicsBody(circleOfRadius: containers[index].mySKNode.size.width / 3) // 1
            containers[index].mySKNode.physicsBody?.dynamic = true // 2
            containers[index].mySKNode.physicsBody?.categoryBitMask = PhysicsCategory.Container
            containers[index].mySKNode.physicsBody?.contactTestBitMask = PhysicsCategory.MovingSprite
            containers[index].mySKNode.physicsBody?.collisionBitMask = PhysicsCategory.None
            countColorsProContainer.append(maxGeneratedColorCount)
            addChild(containers[index].mySKNode)
        }
        let buttonTextureNormal = SKTexture(image: GV.drawButton(CGSizeMake(100,40), imageColor: UIColor.blueColor().CGColor))
        let buttonTextureSelected = SKTexture(image: GV.drawButton(CGSizeMake(95,38), imageColor: UIColor.blueColor().CGColor))
        backButton = SKButton(normalTexture: buttonTextureNormal, selectedTexture: buttonTextureSelected, disabledTexture: buttonTextureNormal)
        backButton!.position = CGPointMake(view.frame.width / 2, view.frame.height * 0.10)
        backButton!.size = CGSizeMake(view.frame.width / 5, view.frame.height / 15)
        backButton!.setButtonLabel(title: "Restart", font: "HelveticaBold", fontSize: 15)
        backButton!.setButtonAction(self, triggerEvent: .TouchUpInside, action:"backButtonPressed")
        addChild(backButton!)
        backgroundColor = UIColor.whiteColor() //SKColor.whiteColor()
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        generateSprite()
    }

    func backButtonPressed() {
        countColorsProContainer.removeAll(keepCapacity: false)
        for index in 0..<countContainers {
            countColorsProContainer.append(maxGeneratedColorCount)
        }
        generateSprite()
    }
    
    func generateSprite() {
        let nextTime = Double(GV.random(1, max: 2)) / 25
        var colorTab = [Int]()
        for index in 0..<countColorsProContainer.count {
            if countColorsProContainer[index] > 0 {
                colorTab.append(index)
            }
        }
        var positionsTab = [(CGFloat, CGFloat, Int, Int)]()
        for column in 0..<tableColumns {
            for row in 0..<tableRows {
                if gameArray[column][row] {
                    let appendValue = (CGFloat(column) * tableCellSize + tableCellSize / 2, CGFloat(row) * tableCellSize * 0.75 + tableCellSize * 2.7, column, row)
                    positionsTab.append(appendValue)
                }
            }
        }
        
        
        if colorTab.count > 0 {
            let colorIndex = colorTab[GV.random(0, max: colorTab.count - 1)]
            countColorsProContainer[colorIndex]--
            let aktColor = GV.colorSets[GV.colorSetIndex][colorIndex + 1].CGColor
            self.timer = NSTimer.scheduledTimerWithTimeInterval(nextTime, target: self, selector: Selector("generateSprite"), userInfo: nil, repeats: false)
            let containerTexture = SKTexture(image: GV.drawCircle(CGSizeMake(30,30), imageColor: aktColor))
            let sprite = MySKNode(texture: containerTexture, type: .MovingSpriteType)
            let index = GV.random(0, max: positionsTab.count - 1)
            //let xPosition = size.width * CGFloat(GV.random(20, max: 80)) / 100
            //let yPosition = size.height * CGFloat(GV.random(20, max: 80)) / 100
            let (xPosition, yPosition, aktColumn, aktRow) = positionsTab[index]
            sprite.position = CGPoint(x: xPosition, y: yPosition)
            gameArray[aktColumn][aktRow] = false
            sprite.name = "\(100 + colorIndex)"
            let generatedName = sprite.name
            sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
            sprite.physicsBody?.dynamic = true
            sprite.physicsBody?.categoryBitMask = PhysicsCategory.Sprite
            sprite.physicsBody?.contactTestBitMask = PhysicsCategory.MovingSprite
            sprite.physicsBody?.collisionBitMask = PhysicsCategory.None
            sprite.physicsBody?.usesPreciseCollisionDetection = true
            addChild(sprite)
        } else {
        }
    }
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let countTouches = touches.count
        let firstTouch = touches.first as! UITouch
        let touchLocation = firstTouch.locationInNode(self)
        let node = self.nodeAtPoint(touchLocation)
        if node.name != nil {
            if node.name!.toInt()! < 100 {
                movedFromNode = nil
            } else {
                movedFromNode = self.nodeAtPoint(touchLocation)
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if movedFromNode != nil {
            if self.childNodeWithName("myLine") != nil {
                self.childNodeWithName("myLine")!.removeFromParent()
            }
            let countTouches = touches.count
            let firstTouch = touches.first as! UITouch
            let touchLocation = firstTouch.locationInNode(self)
            let node = movedFromNode as! SKSpriteNode
            let offset = touchLocation - movedFromNode.position
            let direction = offset.normalized()
            let shootAmount = direction * 1000
            let realDest = shootAmount + movedFromNode.position
            
            
            let pathToDraw:CGMutablePathRef = CGPathCreateMutable()
            let myLine:SKShapeNode = SKShapeNode(path:pathToDraw)
            myLine.name = "myLine"
            CGPathMoveToPoint(pathToDraw, nil, movedFromNode.position.x, movedFromNode.position.y)
            CGPathAddLineToPoint(pathToDraw, nil, realDest.x, realDest.y)
            
            myLine.path = pathToDraw
            let name = movedFromNode.name!
            let colorIndex = name.toInt()! - 100
            
            myLine.strokeColor = GV.colorSets[GV.colorSetIndex][colorIndex + 1]
            
            self.addChild(myLine)
            
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if movedFromNode != nil {
            if self.childNodeWithName("myLine") != nil {
                self.childNodeWithName("myLine")!.removeFromParent()
            }
            let countTouches = touches.count
            let firstTouch = touches.first as! UITouch
            let touchLocation = firstTouch.locationInNode(self)

            let node = movedFromNode as! SKSpriteNode
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width/2)
            //println("nodeSize:\(node.size.width)")
            node.physicsBody?.dynamic = true
            node.physicsBody?.categoryBitMask = PhysicsCategory.MovingSprite
            node.physicsBody?.contactTestBitMask = PhysicsCategory.Sprite | PhysicsCategory.Container 
            node.physicsBody?.collisionBitMask = PhysicsCategory.None
            node.physicsBody?.usesPreciseCollisionDetection = true
            let offset = touchLocation - movedFromNode.position

            let direction = offset.normalized()
            
            // 7 - Make it shoot far enough to be guaranteed off screen
            let shootAmount = direction * 1000
            
            // 8 - Add the shoot amount to the current position
            let realDest = shootAmount + movedFromNode.position
            
            // 9 - Create the actions
            let actionMove = SKAction.moveTo(realDest, duration: 2.0)
            let actionMoveDone = SKAction.removeFromParent()
            movedFromNode.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        }
    }
    
    func spriteDidCollideWithContainer(node1:SKSpriteNode, node2:SKSpriteNode) {
        let movingSprite = node1
        let container = node2
        
        let containerColorIndex = container.name!.toInt()!
        let spriteColorIndex = movingSprite.name!.toInt()!
        var OK = containerColorIndex == spriteColorIndex - 100
        //println("spriteName: \(containerColorIndex), containerName: \(spriteColorIndex)")
        if OK {
            containers[containerColorIndex].countHits++
            containers[containerColorIndex].label.text = "\(containers[containerColorIndex].countHits)"
        } else {
            containers[containerColorIndex].countHits--
            containers[containerColorIndex].label.text = "\(containers[containerColorIndex].countHits)"
        }
        movingSprite.removeFromParent()
    }
    
    func spriteDidCollideWithMovingSprite(node1:MySKNode, node2:MySKNode) {
        let movingSprite = node1
        let sprite = node2
        let movingSpriteColorIndex = movingSprite.name!.toInt()!
        let spriteColorIndex = sprite.name!.toInt()!
        var OK = movingSpriteColorIndex == spriteColorIndex
        //println("spriteName: \(containerColorIndex), containerName: \(spriteColorIndex)")
        if OK {
           let aOK = true
        } else {
            let aOK = false
        }
        movingSprite.removeFromParent()
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        var movingSprite: SKPhysicsBody
        var partner: SKPhysicsBody
        
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            movingSprite = contact.bodyB
            partner = contact.bodyA
        } else {
            movingSprite = contact.bodyA
            partner = contact.bodyB
        }
        //println("firstBody:\(firstBody.categoryBitMask), secondBody:\(secondBody.categoryBitMask), PhysicsCategory.Sprite: \(PhysicsCategory.Sprite), PhysicsCategory.Container:\(PhysicsCategory.Container)")
        // 2
        
        if partner.categoryBitMask == PhysicsCategory.Container {
            spriteDidCollideWithContainer(movingSprite.node as! SKSpriteNode, node2: partner.node as! SKSpriteNode)
        }  else {
            spriteDidCollideWithMovingSprite(movingSprite.node as! MySKNode, node2: partner.node as! MySKNode)
        }
/*
        if ((movingSprite.categoryBitMask & PhysicsCategory.MovingSprite != 0) &&
            (partner.categoryBitMask & PhysicsCategory.Container != 0)) {
                spriteDidCollideWithContainer(movingSprite.node as! SKSpriteNode, node2: partner.node as! SKSpriteNode)
        } else {
            if ((movingSprite.categoryBitMask & PhysicsCategory.MovingSprite != 0) &&
                (partner.categoryBitMask & PhysicsCategory.Sprite != 0)) {
                    spriteDidCollideWithMovingSprite(movingSprite.node as! SKSpriteNode, node2: partner.node as! SKSpriteNode)
            }
        }
*/
    }
}

