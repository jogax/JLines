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
    static let Sprite       : UInt32 = 0b1      // 1
    static let Container    : UInt32 = 0b10       // 2
    static let MovingSprite : UInt32 = 0b100     // 4
}

struct MyNodeTypes {
    static let none:            UInt32 = 0
    static let GameScene:       UInt32 = 0b1
    static let LabelNode:       UInt32 = 0b10
    static let SpriteNode:      UInt32 = 0b100
    static let ContainerNode:   UInt32 = 0b1000
}

struct Container {
    let mySKNode: MySKNode
    var label: SKLabelNode
    var countHits: Int
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Values from json File
    var params = ""
    var maxGeneratedColorCount: Int?
    var tableColumns = 0
    var tableRows = 0
    var countContainers = 0
    var tableCellSize: CGFloat = 0
    var containerSize:CGFloat = 0
    var spriteSize:CGFloat = 0
    var minProzent = 0
    var maxProzent = 0

    let timeLimitKorr = 10 // sec for pro Sprite
    var timeLimit = 0 // seconds

    var timer: NSTimer?
    var countDown: NSTimer?
    var colorSet = [Int]()
    var containers = [Container]()
    //var countColorsProContainer = [Int]()
    var movedFromNode: MySKNode!
    var backButton: SKButton?
    var gameArray = [[Bool]]() // true if Cell used
    var collisionActive = false
    var levelIndex = 5
    var gameScore = 0
    var levelScore = 0
    let deviceIndex = GV.onIpad ? 0 : 1
    var parentViewController: UIViewController?
    var levelLabel = SKLabelNode()
    var gameScoreLabel = SKLabelNode()
    var levelScoreLabel = SKLabelNode()
    var countdownLabel = SKLabelNode()
    

    
    var packageOfLevels: Dictionary<String, AnyObject>?
    var json: JSON?
    var myView = SKView()
    //var packageName: AnyObject
/*
    override init(size: CGSize) {
        
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
*/
    override func didMoveToView(view: SKView) {
        GV.currentTime = NSDate()
        GV.elapsedTime = GV.currentTime.timeIntervalSinceDate(GV.startTime) * 1000
        println("GameScene start: \(GV.elapsedTime)")
        myView = view
        let (package, data) = Dictionary<String, AnyObject>.loadJSONFromBundle("LevelsForPlayWithSprites")
        json = JSON(data: data!)
        prepareNextGame()
        generateSprites()
        
       
    }
    
    func restartButtonPressed() {
        newGame(false)
    }

    func prepareNextGame() {
        //var currentTime = NSDate()
        GV.startTime = NSDate()
        if countDown != nil {
            countDown!.invalidate()
            countDown = nil
        }
        if let testWert = json!["levels"][levelIndex]["maxGeneratedColorCount"][deviceIndex].int {
            maxGeneratedColorCount = testWert
        } else {
            levelIndex = 0
            maxGeneratedColorCount = json!["levels"][levelIndex]["maxGeneratedColorCount"][deviceIndex].int!
        }
        tableColumns = json!["levels"][levelIndex]["tableColumns"][deviceIndex].int!
        tableRows = json!["levels"][levelIndex]["tableRows"][deviceIndex].int!
        countContainers = json!["levels"][levelIndex]["countContainers"][deviceIndex].int!
        tableCellSize = CGFloat(countContainers) / CGFloat(tableColumns)
        
        containerSize = CGFloat(json!["levels"][levelIndex]["containerSize"][deviceIndex].int!)
        spriteSize = CGFloat(json!["levels"][levelIndex]["spriteSize"][deviceIndex].int!)
        minProzent = json!["levels"][levelIndex]["minProzent"][deviceIndex].int! * tableColumns * tableRows / 100
        maxProzent = json!["levels"][levelIndex]["maxProzent"][deviceIndex].int! * tableColumns * tableRows / 100
       
        timeLimit = countContainers * maxGeneratedColorCount! * timeLimitKorr
        println("timeLimit: \(timeLimit)")
        
        for column in 0..<tableRows {
            gameArray.append(Array(count: tableRows, repeatedValue:false))
        }
        let xDelta = size.width / CGFloat(countContainers)
        tableCellSize = size.width / CGFloat(tableRows)
        for index in 0..<countContainers {
            let aktColor = GV.colorSets[GV.colorSetIndex][index + 1].CGColor
            let containerTexture = SKTexture(image: GV.drawCircle(CGSizeMake(containerSize, containerSize), imageColor: aktColor))
            let centerX = (size.width / CGFloat(countContainers)) * CGFloat(index) + xDelta / 2
            let centerY = size.height * 0.88
            let cont: Container = Container(mySKNode: MySKNode(texture: containerTexture, type: .ContainerType), label: SKLabelNode(), countHits: 0)
            containers.append(cont)
            containers[index].mySKNode.position = CGPoint(x: centerX, y: centerY)
            containers[index].label.text = "0"
            containers[index].label.fontSize = 20;
            //containers[index].label.fontName = "ArielBold"
            containers[index].label.position = CGPointMake(CGRectGetMidX(containers[index].mySKNode.frame), CGRectGetMidY(containers[index].mySKNode.frame) * 1.05)
            containers[index].label.name = "label"
            containers[index].label.fontColor = SKColor.blackColor()
            //self.addChild(containers[index].label)
            
            containers[index].mySKNode.colorIndex = index
            containers[index].mySKNode.physicsBody = SKPhysicsBody(circleOfRadius: containers[index].mySKNode.size.width / 3) // 1
            containers[index].mySKNode.physicsBody?.dynamic = true // 2
            containers[index].mySKNode.physicsBody?.categoryBitMask = PhysicsCategory.Container
            containers[index].mySKNode.physicsBody?.contactTestBitMask = PhysicsCategory.MovingSprite
            containers[index].mySKNode.physicsBody?.collisionBitMask = PhysicsCategory.None
            //countColorsProContainer.append(maxGeneratedColorCount!)
            addChild(containers[index].mySKNode)
        }
        GV.currentTime = NSDate()
        GV.elapsedTime = GV.currentTime.timeIntervalSinceDate(GV.startTime) //* 1000
        println("befüllung Containers: \(GV.elapsedTime)")
        GV.startTime = GV.currentTime
        levelLabel.text = GV.language.getText("level") + ": \(levelIndex + 1)"
        levelLabel.position = CGPointMake(self.position.x + self.size.width * 0.5, self.position.y + self.size.height * 0.99)
        levelLabel.fontColor = SKColor.blackColor()
        levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        levelLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        levelLabel.fontSize = 15;
        //levelLabel.fontName = "ArielBold"
        self.addChild(levelLabel)
        
        gameScoreLabel.position = CGPointMake(self.position.x + self.size.width * 0.1, self.position.y + self.size.height * 0.99)
        gameScoreLabel.fontColor = SKColor.blackColor()
        gameScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        gameScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        gameScoreLabel.fontSize = 15;
        //gameScoreLabel.fontName = "ArielBold"
        self.addChild(gameScoreLabel)
        
        levelScoreLabel.position = CGPointMake(self.position.x + self.size.width * 0.1, self.position.y + self.size.height * 0.94)
        levelScoreLabel.fontColor = SKColor.blackColor()
        levelScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        levelScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        levelScoreLabel.fontSize = 15;
        //levelScoreLabel.fontName = "ArielBold"
        self.addChild(levelScoreLabel)
        showScore()
        
        countdownLabel.position = CGPointMake(self.position.x + self.size.width * 0.9, self.position.y + self.size.height * 0.99)
        countdownLabel.fontColor = SKColor.blackColor()
        countdownLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        countdownLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        countdownLabel.fontSize = 15;
        countdownLabel.fontName = "countdownLabel"
        self.addChild(countdownLabel)
        
        let buttonTextureNormal = SKTexture(image: GV.drawButton(CGSizeMake(100,40), imageColor: UIColor.blueColor().CGColor))
        let buttonTextureSelected = SKTexture(image: GV.drawButton(CGSizeMake(95,38), imageColor: UIColor.blueColor().CGColor))
        backButton = SKButton(normalTexture: buttonTextureNormal, selectedTexture: buttonTextureSelected, disabledTexture: buttonTextureNormal)
        backButton!.position = CGPointMake(myView.frame.width / 2, myView.frame.height * 0.10)
        backButton!.size = CGSizeMake(myView.frame.width / 5, myView.frame.height / 15)
        backButton!.setButtonLabel(title: "Restart", font: "HelveticaBold", fontSize: 15)
        backButton!.setButtonAction(self, triggerEvent: .TouchUpInside, action:"restartButtonPressed")
        addChild(backButton!)
        backgroundColor = UIColor.whiteColor() //SKColor.whiteColor()
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        self.countDown = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("doCountDown"), userInfo: nil, repeats: true)
        GV.currentTime = NSDate()
        GV.elapsedTime = GV.currentTime.timeIntervalSinceDate(GV.startTime) //* 1000
        println("prepareNextGame Laufzeit: \(GV.elapsedTime)")
    }
    
    func analyzeNode (node: AnyObject) -> UInt32 {
        let testNode = node as! SKNode
        switch node  {
        case is GameScene: return MyNodeTypes.GameScene
        case is SKLabelNode: return MyNodeTypes.LabelNode
        case is MySKNode:
            if (testNode as! MySKNode).type == .ContainerType {
                return MyNodeTypes.ContainerNode
            } else {
                return MyNodeTypes.SpriteNode
            }
        default: return MyNodeTypes.none
        }
    }
    
    func newGame(next: Bool) {
        if next {
            levelIndex++
            gameScore += levelScore
        }
        //self.children.removeAll(keepCapacity: false)
        for index in 0..<self.children.count {
            let testNode = children[self.children.count - 1] as! SKNode
            testNode.removeFromParent()
        }
        gameArray.removeAll(keepCapacity: false)
        //countColorsProContainer.removeAll(keepCapacity: false)
        containers.removeAll(keepCapacity: false)
        if countDown != nil {
            countDown!.invalidate()
            countDown = nil
        }
        prepareNextGame()
        generateSprites()
    }

    func generateSprites() {
        
       
        for colorIndex in 0..<countContainers {
            for index in 0..<maxGeneratedColorCount! {
                colorSet.append(colorIndex)
            }
        }
        do {
        
        } while colorSet.count == 0 || countFilledCells > maxProzent 
    }

/*
    func generateSprites() {
        let nextTime = 0.01 //Double(GV.random(1, max: 1)) / 25
        var colorTab = [Int]()
        for index in 0..<countColorsProContainer.count {
            if countColorsProContainer[index] > 0 {
                colorTab.append(index)
            }
        }
        
        var positionsTab = [(CGFloat, CGFloat, Int, Int)]()
        for column in 0..<tableColumns {
            for row in 0..<tableRows {
                if !gameArray[column][row] {
                    let appendValue = (CGFloat(column) * tableCellSize + tableCellSize / 2, CGFloat(row) * tableCellSize * 0.9 + tableCellSize * 2.7, column, row)
                    positionsTab.append(appendValue)
                }
            }
        }
        
        
        do {
            if colorTab.count > 0 {
                let colorIndex = colorTab[GV.random(0, max: colorTab.count - 1)]
                countColorsProContainer[colorIndex]--
                let aktColor = GV.colorSets[GV.colorSetIndex][colorIndex + 1].CGColor
                self.timer = NSTimer.scheduledTimerWithTimeInterval(nextTime, target: self, selector: Selector("generateSprites"), userInfo: nil, repeats: false)
                let containerTexture = SKTexture(image: GV.drawCircle(CGSizeMake(spriteSize,spriteSize), imageColor: aktColor))
                let sprite = MySKNode(texture: containerTexture, type: .MovingSpriteType)
                let index = GV.random(0, max: positionsTab.count - 1)
                //let xPosition = size.width * CGFloat(GV.random(20, max: 80)) / 100
                //let yPosition = size.height * CGFloat(GV.random(20, max: 80)) / 100
                let (xPosition, yPosition, aktColumn, aktRow) = positionsTab[index]
                sprite.position = CGPoint(x: xPosition, y: yPosition)
                gameArray[aktColumn][aktRow] = true
                //sprite.name = "\(100 + colorIndex)"
                //let generatedName = sprite.name
                sprite.column = aktColumn
                sprite.row = aktRow
                sprite.colorIndex = colorIndex
                sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
                sprite.physicsBody?.dynamic = true
                sprite.physicsBody?.categoryBitMask = PhysicsCategory.Sprite
                sprite.physicsBody?.contactTestBitMask = PhysicsCategory.MovingSprite
                sprite.physicsBody?.collisionBitMask = PhysicsCategory.None
                sprite.physicsBody?.usesPreciseCollisionDetection = true
                addChild(sprite)
            }
        } while false
    }
    
*/
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let countTouches = touches.count
        let firstTouch = touches.first as! UITouch
        let touchLocation = firstTouch.locationInNode(self)
        let testNode = self.nodeAtPoint(touchLocation)
        let aktNodeType = analyzeNode(testNode)
        switch aktNodeType {
            case MyNodeTypes.LabelNode: movedFromNode = self.nodeAtPoint(touchLocation).parent as! MySKNode
            case MyNodeTypes.SpriteNode: movedFromNode = self.nodeAtPoint(touchLocation) as! MySKNode
            case MyNodeTypes.ContainerNode: movedFromNode = nil
            default: movedFromNode = nil
        }
        /*
        switch testNode {
            case is SKLabelNode: movedFromNode = self.nodeAtPoint(touchLocation).parent as! MySKNode
            case is MySKNode: movedFromNode = self.nodeAtPoint(touchLocation) as! MySKNode
            default: movedFromNode = nil
        }
        if movedFromNode != nil && movedFromNode.type == .ContainerType {
            movedFromNode = nil
        }
        */
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if movedFromNode != nil {
            if self.childNodeWithName("myLine") != nil {
                self.childNodeWithName("myLine")!.removeFromParent()
            }
            let countTouches = touches.count
            let firstTouch = touches.first as! UITouch
            let touchLocation = firstTouch.locationInNode(self)
            let testNode = self.nodeAtPoint(touchLocation)
            let aktNodeType = analyzeNode(testNode)
            var aktNode: SKNode? = movedFromNode
            switch aktNodeType {
                case MyNodeTypes.LabelNode: aktNode = self.nodeAtPoint(touchLocation).parent as! MySKNode
                case MyNodeTypes.SpriteNode: aktNode = self.nodeAtPoint(touchLocation) as! MySKNode
                default: aktNode = nil
            }
            if movedFromNode != aktNode {
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
                //let name = movedFromNode.name!
                //let colorIndex = name.toInt()! - 100
                let colorIndex = movedFromNode.colorIndex
                
                myLine.strokeColor = GV.colorSets[GV.colorSetIndex][colorIndex + 1]
                self.addChild(myLine)
            }
            
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
            let testNode = self.nodeAtPoint(touchLocation)
            
            let aktNodeType = analyzeNode(testNode)
            var aktNode: SKNode? = movedFromNode
            switch aktNodeType {
                case MyNodeTypes.LabelNode: aktNode = self.nodeAtPoint(touchLocation).parent as! MySKNode
                case MyNodeTypes.SpriteNode: aktNode = self.nodeAtPoint(touchLocation) as! MySKNode
                default: aktNode = nil
            }

            if aktNode == nil || (aktNode as! MySKNode) != movedFromNode {
                let node = movedFromNode// as! SKSpriteNode
                node!.physicsBody = SKPhysicsBody(circleOfRadius: node!.size.width/2)
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
                //let actionMoveDone = SKAction.removeFromParent()
                collisionActive = true
                movedFromNode.runAction(SKAction.sequence([actionMove]))//, actionMoveDone]))
            }
        }
    }
        
    
    func showScore() {
        levelScore = 0
        var gameScore = 0
        for index in 0..<containers.count {
            levelScore += containers[index].mySKNode.hitCounter
            gameScore = self.gameScore + levelScore
        }
        let levelScoreText: String = GV.language.getText("levelScore")
        levelScoreLabel.text = "\(levelScoreText) \(levelScore)"
        let gameScoreText: String = GV.language.getText("gameScore")
        gameScoreLabel.text = "\(gameScoreText) \(gameScore)"
        

    }
    
    func spriteDidCollideWithContainer(node1:MySKNode, node2:MySKNode) {
        let movingSprite = node1
        let container = node2
        
        let containerColorIndex = container.colorIndex
        let spriteColorIndex = movingSprite.colorIndex
        var OK = containerColorIndex == spriteColorIndex
        //println("spriteName: \(containerColorIndex), containerName: \(spriteColorIndex)")
        if OK {
            //containers[containerColorIndex].countHits += movingSprite.hitCounter
            //containers[containerColorIndex].label.text = "\(containers[containerColorIndex].countHits)"
            container.hitCounter += movingSprite.hitCounter
            showScore()
        } else {
            //containers[containerColorIndex].countHits -= movingSprite.hitCounter
            //containers[containerColorIndex].label.text = "\(containers[containerColorIndex].countHits)"
            container.hitCounter -= movingSprite.hitCounter
            showScore()
        }
        collisionActive = false
        movingSprite.removeFromParent()
        gameArray[movingSprite.column][movingSprite.row] = false
        checkGameArray()
    }
    
    
    func spriteDidCollideWithMovingSprite(node1:MySKNode, node2:MySKNode) {
        let movingSprite = node1
        let sprite = node2
        let movingSpriteColorIndex = movingSprite.colorIndex
        let spriteColorIndex = sprite.colorIndex
        collisionActive = false
        var OK = movingSpriteColorIndex == spriteColorIndex
        //println("spriteName: \(containerColorIndex), containerName: \(spriteColorIndex)")
        if OK {
            sprite.hitCounter = 2 * (movingSprite.hitCounter + sprite.hitCounter)
            //println("sprite.column:\(sprite.column), sprite.row:\(sprite.row),sprite.hitCounter:\(sprite.hitCounter)")
            sprite.hitLabel.zPosition = 0
            gameArray[movingSprite.column][movingSprite.row] = false
            movingSprite.removeFromParent()
        } else {
            containers[movingSprite.colorIndex].mySKNode.hitCounter -= movingSprite.hitCounter
            containers[sprite.colorIndex].mySKNode.hitCounter -= sprite.hitCounter
            //containers[sprite.colorIndex].setText()
            //println("container.countHits: \(containers[sprite.colorIndex].countHits)")
            var movingSpriteDest = CGPointMake(movingSprite.position.x * 0.5, 0)
            let movingSpriteAction = SKAction.moveTo(movingSpriteDest, duration: 1.0)
            let actionMoveDone = SKAction.removeFromParent()
            movingSprite.runAction(SKAction.sequence([movingSpriteAction, actionMoveDone]))
            var spriteDest = CGPointMake(sprite.position.x * 1.5, 0)
            let actionMove2 = SKAction.moveTo(spriteDest, duration: 1.5)
            sprite.runAction(SKAction.sequence([actionMove2, actionMoveDone]))
            gameArray[movingSprite.column][movingSprite.row] = false
            gameArray[sprite.column][sprite.row] = false
        }
        checkGameArray()
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1
        var movingSprite: SKPhysicsBody
        var partner: SKPhysicsBody
        
        if collisionActive {
        
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                movingSprite = contact.bodyB
                partner = contact.bodyA
            } else {
                movingSprite = contact.bodyA
                partner = contact.bodyB
            }
            
            if partner.categoryBitMask == PhysicsCategory.Container {
                spriteDidCollideWithContainer(movingSprite.node as! MySKNode, node2: partner.node as! MySKNode)
            }  else {
                spriteDidCollideWithMovingSprite(movingSprite.node as! MySKNode, node2: partner.node as! MySKNode)
            }
            
        }
    }
    
    func checkGameArray() {
        var usedCellCount = 0
        for column in 0..<tableColumns {
            for row in 0..<tableRows {
                if gameArray[column][row] {
                    usedCellCount++
                }
            }
        }
        
        if usedCellCount == 0 { // Level completed, start a new game
            let alert = UIAlertController(title: GV.language.getText("levelComplete"),
                message: GV.language.getText("no Message"),
                preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: GV.language.getText("return"), style: .Cancel, handler: nil)
            let againAction = UIAlertAction(title: GV.language.getText("next level"), style: .Default,
                handler: {(paramAction:UIAlertAction!) in
                    self.newGame(true)
            })
            alert.addAction(cancelAction)
            alert.addAction(againAction)
            parentViewController!.presentViewController(alert, animated: true, completion: nil)
        } else {
            if usedCellCount < minProzent {
                generateSprites()
            }
        }
    }
    
    func doCountDown() {
        GV.currentTime = NSDate()
        GV.elapsedTime = GV.currentTime.timeIntervalSinceDate(GV.startTime)// * 1000
        println("doCountdown: \(GV.elapsedTime) sec")

        timeLimit--
        let countdownText = GV.language.getText("timeLeft")
        countdownLabel.text = "\(countdownText) \(timeLimit)"
        if timeLimit == 0 {
            //countDown!.invalidate()
            //countDown = nil
            let alert = UIAlertController(title: GV.language.getText("timeout"),
                message: GV.language.getText("gameOver"),
                preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: GV.language.getText("return"), style: .Cancel, handler: nil)
            let againAction = UIAlertAction(title: GV.language.getText("gameAgain"), style: .Default,
                handler: {(paramAction:UIAlertAction!) in
                    self.newGame(false)
                })
            alert.addAction(cancelAction)
            alert.addAction(againAction)
            parentViewController!.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    

}

