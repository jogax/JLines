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
    static let WallAround   : UInt32 = 0b1000     // 8
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


enum LinePosition: Int, Printable {
    case upperHorizontal = 0, rightVertical, bottomHorizontal, leftVertical
    var linePositionName: String {
        let linePositionNames = [
            "UH",
            "RV",
            "BH",
            "LV"
        ]
        return linePositionNames[rawValue]
    }
    
    var description: String {
        return linePositionName
    }
        
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Values from json File
    var params = ""
    var countSpritesProContainer: Int?
    var countColumns = 0
    var countRows = 0
    var countContainers = 0
    var targetScoreKorr: Double = 0
    var tableCellSize: CGFloat = 0
    var containerSize:CGFloat = 0
    var spriteSize:CGFloat = 0
    var minUsedCells = 0
    var maxUsedCells = 0

    let timeLimitKorr = 5 // sec for pro Sprite
    var timeLimit = 0 // seconds

    var timer: NSTimer?
    var countDown: NSTimer?
    var colorTab = [Int]()
    var containers = [Container]()
    var countColorsProContainer = [Int]()
    
    var movedFromNode: MySKNode!
    var backButton: SKButton?
    var gameArray = [[Bool]]() // true if Cell used
    var collisionActive = false
    var levelIndex = 0
    var gameScore = 0
    var levelScore = 0
    let deviceIndex = GV.onIpad ? 0 : 1
    var parentViewController: UIViewController?
    var levelLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var gameScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var levelScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var countdownLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var targetScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var levelArray = [Level]()
    
    let levelPosKorr = CGPointMake(GV.onIpad ? 0.5 : 0.5, GV.onIpad ? 0.97 : 0.97)
    let gameScorePosKorr = CGPointMake(GV.onIpad ? 0.1 : 0.1, GV.onIpad ? 0.95 : 0.94)
    let levelScorePosKorr = CGPointMake(GV.onIpad ? 0.1 : 0.1, GV.onIpad ? 0.93 : 0.90)
    let countdownPosKorr = CGPointMake(GV.onIpad ? 0.98 : 0.98, GV.onIpad ? 0.95 : 0.94)
    let targetPosKorr = CGPointMake(GV.onIpad ? 0.98 : 0.98, GV.onIpad ? 0.93 : 0.90)
    let containersPosCorr = CGPointMake(GV.onIpad ? 0.98 : 0.98, GV.onIpad ? 0.88 : 0.80)
    var targetScore = 0

    let yKorr1: CGFloat = GV.onIpad ? 0.9 : 0.8
    let yKorr2: CGFloat = GV.onIpad ? 2.7 : 2.0

    let scoreAddCorrected = [1:0, 2:1, 3:2, 4:4, 5:5, 6:7, 7:8, 8:10, 9:11, 10:13, 11:14, 12:16, 13:17, 14:19, 15:20, 16:22, 17:23]
    

    
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
        levelArray = GV.cloudData.readLevelDataArray()
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
        
        /*
        if let testWert = json!["levels"][levelIndex]["countSpritesProContainer"][deviceIndex].int {
            countSpritesProContainer = testWert
        } else {
            levelIndex = 0
            countSpritesProContainer = json!["levels"][levelIndex]["countSpritesProContainer"][deviceIndex].int!
        }
        countColumns = json!["levels"][levelIndex]["countColumns"][deviceIndex].int!
        countRows = json!["levels"][levelIndex]["countRows"][deviceIndex].int!
        countContainers = json!["levels"][levelIndex]["countContainers"][deviceIndex].int!
        tableCellSize = CGFloat(countContainers) / CGFloat(countColumns)
        
        containerSize = CGFloat(json!["levels"][levelIndex]["containerSize"][deviceIndex].int!)
        spriteSize = CGFloat(json!["levels"][levelIndex]["spriteSize"][deviceIndex].int!)
        minUsedCells = json!["levels"][levelIndex]["minProzent"][deviceIndex].int! * countColumns * countRows / 100
        maxUsedCells = Int(json!["levels"][levelIndex]["maxProzent"][deviceIndex].int! * countColumns * countRows / 100)
       */
        
        if levelIndex >= levelArray.count {
            levelIndex = levelArray.count - 1
        }
        countContainers = levelArray[levelIndex].countContainers
        countSpritesProContainer = levelArray[levelIndex].countSpritesProContainer
        targetScoreKorr = levelArray[levelIndex].targetScoreKorr
        countColumns = levelArray[levelIndex].countColumns
        countRows = levelArray[levelIndex].countRows
        minUsedCells = levelArray[levelIndex].minProzent * countColumns * countRows / 100
        maxUsedCells = levelArray[levelIndex].maxProzent * countColumns * countRows / 100
        containerSize = CGFloat(levelArray[levelIndex].containerSize)
        spriteSize = CGFloat(levelArray[levelIndex].spriteSize)
        
        timeLimit = countContainers * countSpritesProContainer! * timeLimitKorr
        println("timeLimit: \(timeLimit)")
        
        gameArray.removeAll(keepCapacity: false)
        containers.removeAll(keepCapacity: false)

        for column in 0..<countRows {
            gameArray.append(Array(count: countRows, repeatedValue:false))
        }
        
        colorTab.removeAll(keepCapacity: false)
        for containerIndex in 0..<countContainers {
            for index in 0..<countSpritesProContainer! {
                colorTab.append(containerIndex)
            }
        }
        
        let xDelta = size.width / CGFloat(countContainers)
        tableCellSize = size.width / CGFloat(countColumns)
        for index in 0..<countContainers {
            let aktColor = GV.colorSets[GV.colorSetIndex][index + 1].CGColor
            let containerTexture = SKTexture(image: GV.drawCircle(CGSizeMake(containerSize, containerSize), imageColor: aktColor))
            let centerX = (size.width / CGFloat(countContainers)) * CGFloat(index) + xDelta / 2
            let centerY = size.height * containersPosCorr.y
            let cont: Container
            //if index == 0 {
                cont = Container(mySKNode: MySKNode(texture: SKTexture(imageNamed:"sprite\(index)"), type: .ContainerType), label: SKLabelNode(), countHits: 0)
/*
        } else {
                cont = Container(mySKNode: MySKNode(texture: containerTexture, type: .ContainerType), label: SKLabelNode(), countHits: 0)
            }
*/
            containers.append(cont)
            containers[index].mySKNode.position = CGPoint(x: centerX, y: centerY)
            containers[index].mySKNode.size.width = containerSize
            containers[index].mySKNode.size.height = containerSize
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
            countColorsProContainer.append(countSpritesProContainer!)
            addChild(containers[index].mySKNode)
        }
        GV.currentTime = NSDate()
        GV.elapsedTime = GV.currentTime.timeIntervalSinceDate(GV.startTime) //* 1000
        println("befüllung Containers: \(GV.elapsedTime)")
        GV.startTime = GV.currentTime
        levelLabel.text = GV.language.getText("level") + ": \(levelIndex + 1)"
        levelLabel.position = CGPointMake(self.position.x + self.size.width * levelPosKorr.x, self.position.y + self.size.height * levelPosKorr.y)
        levelLabel.fontColor = SKColor.blackColor()
        levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        levelLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        levelLabel.fontSize = 15;
        //levelLabel.fontName = "ArielBold"
        self.addChild(levelLabel)
        
        let gameScoreText: String = GV.language.getText("gameScore")
        gameScoreLabel.text = "\(gameScoreText) \(gameScore)"
        gameScoreLabel.position = CGPointMake(self.position.x + self.size.width * gameScorePosKorr.x, self.position.y + self.size.height * gameScorePosKorr.y)
        gameScoreLabel.fontColor = SKColor.blackColor()
        gameScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        gameScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        gameScoreLabel.fontSize = 15;
        //gameScoreLabel.fontName = "ArielBold"
        self.addChild(gameScoreLabel)
        
        levelScoreLabel.position = CGPointMake(self.position.x + self.size.width * levelScorePosKorr.x, self.position.y + self.size.height * levelScorePosKorr.y)
        levelScoreLabel.fontColor = SKColor.blackColor()
        levelScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        levelScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        levelScoreLabel.fontSize = 15;
        //levelScoreLabel.fontName = "ArielBold"
        self.addChild(levelScoreLabel)
        showScore()
        
        countdownLabel.position = CGPointMake(self.position.x + self.size.width * countdownPosKorr.x, self.position.y + self.size.height * countdownPosKorr.y)
        countdownLabel.fontColor = SKColor.blackColor()
        countdownLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        countdownLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        countdownLabel.fontSize = 15;
        self.addChild(countdownLabel)
        showTimeLeft()

        
        targetScoreLabel.position = CGPointMake(self.position.x + self.size.width * targetPosKorr.x, self.position.y + self.size.height * targetPosKorr.y)
        targetScoreLabel.fontColor = SKColor.blackColor()
        targetScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        targetScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        targetScoreLabel.fontSize = 15;
        targetScore = Int(CGFloat(countContainers * countSpritesProContainer!) * CGFloat(targetScoreKorr))
        let targetScoreText: String = GV.language.getText("targetScore")
        targetScoreLabel.text = "\(targetScoreText) \(targetScore)"
        self.addChild(targetScoreLabel)
        
        
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
        makeLineAroundGameboard(.upperHorizontal)
        makeLineAroundGameboard(.rightVertical)
        makeLineAroundGameboard(.bottomHorizontal)
        makeLineAroundGameboard(.leftVertical)
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
            let gameScoreText: String = GV.language.getText("gameScore")
            gameScoreLabel.text = "\(gameScoreText) \(gameScore)"
        }
        //self.children.removeAll(keepCapacity: false)
        for index in 0..<self.children.count {
            let testNode = children[self.children.count - 1] as! SKNode
            testNode.removeFromParent()
        }
        
        if countDown != nil {
            countDown!.invalidate()
            countDown = nil
        }
        prepareNextGame()
        generateSprites()
    }

    func generateSprites() {
        
        var positionsTab = [(Int, Int)]() // all available Positions
        for column in 0..<countColumns {
            for row in 0..<countRows {
                if !gameArray[column][row] {
                    let appendValue = (column, row)
                    positionsTab.append(appendValue)
                }
            }
        }

        while colorTab.count > 0 && checkGameArray() < maxUsedCells {
            let colorTabIndex = GV.random(0, max: colorTab.count - 1)
            let colorIndex = colorTab[colorTabIndex]
            colorTab.removeAtIndex(colorTabIndex)
            
            let aktColor = GV.colorSets[GV.colorSetIndex][colorIndex + 1].CGColor
            var containerTexture = SKTexture()
//            if colorIndex == 0 {
                containerTexture = SKTexture(imageNamed: "sprite\(colorIndex)")
//            } else {
//                containerTexture = SKTexture(image: GV.drawCircle(CGSizeMake(spriteSize,spriteSize), imageColor: aktColor))
//            }
            let sprite = MySKNode(texture: containerTexture, type: .SpriteType)
            sprite.size.width = spriteSize
            sprite.size.height = spriteSize
            let index = GV.random(0, max: positionsTab.count - 1)
            let (aktColumn, aktRow) = positionsTab[index]
            let xPosition = CGFloat(aktColumn) * tableCellSize + tableCellSize / 2
            let yPosition = CGFloat(aktRow) * tableCellSize * yKorr1 + tableCellSize * yKorr2
            sprite.position = CGPoint(x: xPosition, y: yPosition)
            gameArray[aktColumn][aktRow] = true
            positionsTab.removeAtIndex(index)
            
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
    }

    func makeLineAroundGameboard(linePosition: LinePosition) {
        var point1: CGPoint
        var point2: CGPoint
        var myWallRect: CGRect

        var width: CGFloat = 4
        var length: CGFloat = 0
        switch linePosition {
        case .upperHorizontal:  myWallRect = CGRectMake(position.x, position.y, size.width, 1)
        case .rightVertical:    myWallRect = CGRectMake(position.x + size.width, position.y,  1, size.height)
        case .bottomHorizontal: myWallRect = CGRectMake(position.x, position.y + size.height,  size.width, 1)
        case .leftVertical:     myWallRect = CGRectMake(position.x, position.y,  1, size.height)
        default:                myWallRect = CGRectZero
        }
        
        let myWall = SKNode()
        myWall.name = linePosition.linePositionName
        myWall.physicsBody = SKPhysicsBody(edgeLoopFromRect: myWallRect)
        myWall.physicsBody?.dynamic = true
        myWall.physicsBody?.categoryBitMask = PhysicsCategory.WallAround
        myWall.physicsBody?.contactTestBitMask = PhysicsCategory.MovingSprite
        myWall.physicsBody?.collisionBitMask = PhysicsCategory.None
        myWall.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(myWall)
    }
    
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
                node.physicsBody?.contactTestBitMask = PhysicsCategory.Sprite | PhysicsCategory.Container | PhysicsCategory.WallAround
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
            //gameScore = self.gameScore + levelScore
        }
        let levelScoreText: String = GV.language.getText("levelScore")
        levelScoreLabel.text = "\(levelScoreText) \(levelScore)"
        

    }
    
    func spriteDidCollideWithContainer(node1:MySKNode, node2:MySKNode) {
        let movingSprite = node1
        let container = node2
        
        let containerColorIndex = container.colorIndex
        let spriteColorIndex = movingSprite.colorIndex
        var OK = containerColorIndex == spriteColorIndex
        //println("spriteName: \(containerColorIndex), containerName: \(spriteColorIndex)")
        if OK {
            container.hitCounter += scoreAddCorrected[movingSprite.hitCounter]! // when only 1 sprite, then add 0
            showScore()
        } else {
            container.hitCounter -= movingSprite.hitCounter
            showScore()
        }
        collisionActive = false
        movingSprite.removeFromParent()
        gameArray[movingSprite.column][movingSprite.row] = false
        checkGameArrayEmpty()
    }
    
    
    func spriteDidCollideWithMovingSprite(node1:MySKNode, node2:MySKNode) {
        let movingSprite = node1
        let sprite = node2
        let movingSpriteColorIndex = movingSprite.colorIndex
        let spriteColorIndex = sprite.colorIndex
        let aktColor = GV.colorSets[GV.colorSetIndex][sprite.colorIndex + 1].CGColor
        collisionActive = false
        var OK = movingSpriteColorIndex == spriteColorIndex
        if OK {
            sprite.hitCounter = movingSprite.hitCounter + sprite.hitCounter
            let aktSize = spriteSize + 2 * CGFloat(sprite.hitCounter)
            sprite.size.width = aktSize
            sprite.size.height = aktSize
            
            println("sprite.column:\(sprite.column), sprite.row:\(sprite.row),sprite.hitCounter:\(sprite.hitCounter), size: \(sprite.size)")
            gameArray[movingSprite.column][movingSprite.row] = false
            movingSprite.removeFromParent()
        } else {
            containers[movingSprite.colorIndex].mySKNode.hitCounter -= movingSprite.hitCounter
            containers[sprite.colorIndex].mySKNode.hitCounter -= sprite.hitCounter
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
        checkGameArrayEmpty()
    }
    
    func wallAroundDidCollideWithMovingSprite(node1: MySKNode, node2: SKNode) {
        let movingSprite = node1
        let lineAround = node2

        let xPosition = CGFloat(movingSprite.column) * tableCellSize + tableCellSize / 2
        let yPosition = CGFloat(movingSprite.row) * tableCellSize * yKorr1 + tableCellSize * yKorr2
        let originalPosition = CGPoint(x: xPosition, y: yPosition)
        let offsetOrig = movingSprite.position - originalPosition

        var zielPosition = CGPointZero
        switch lineAround.name! {
            case "BH": zielPosition = CGPointMake(movingSprite.position.x + offsetOrig.x, originalPosition.y)
            case "LV": zielPosition = CGPointMake(originalPosition.x, movingSprite.position.y + offsetOrig.y)
            case "UH": zielPosition = CGPointMake(movingSprite.position.x + offsetOrig.x, originalPosition.y)
            case "RV": zielPosition = CGPointMake(originalPosition.x, movingSprite.position.y + offsetOrig.y)
            default: break
        }

        let offsetNew = zielPosition - movingSprite.position
        let direction = offsetNew.normalized()
        
        let shootAmount = direction * 1000
        
        let realDest = shootAmount + movingSprite.position
        
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        collisionActive = true
        movingSprite.runAction(SKAction.sequence([actionMove]))//, actionMoveDone]))
        checkGameArrayEmpty()
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1
        var movingSprite: SKPhysicsBody
        var partner: SKPhysicsBody
        
        switch (contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask) {
        case (PhysicsCategory.Sprite, PhysicsCategory.MovingSprite):
            movingSprite = contact.bodyB
            partner = contact.bodyA
            spriteDidCollideWithMovingSprite(movingSprite.node as! MySKNode, node2: partner.node as! MySKNode)
            
        case (PhysicsCategory.MovingSprite, PhysicsCategory.Sprite):
            movingSprite = contact.bodyA
            partner = contact.bodyB
            spriteDidCollideWithMovingSprite(movingSprite.node as! MySKNode, node2: partner.node as! MySKNode)
            
        case (PhysicsCategory.Container, PhysicsCategory.MovingSprite):
            movingSprite = contact.bodyB
            partner = contact.bodyA
            spriteDidCollideWithContainer(movingSprite.node as! MySKNode, node2: partner.node as! MySKNode)

        case (PhysicsCategory.MovingSprite, PhysicsCategory.Container):
            movingSprite = contact.bodyA
            partner = contact.bodyB
            spriteDidCollideWithContainer(movingSprite.node as! MySKNode, node2: partner.node as! MySKNode)

        case (PhysicsCategory.WallAround, PhysicsCategory.MovingSprite):
            movingSprite = contact.bodyB
            partner = contact.bodyA
            wallAroundDidCollideWithMovingSprite(movingSprite.node as! MySKNode, node2: partner.node!)
            
        case (PhysicsCategory.MovingSprite, PhysicsCategory.WallAround):
            movingSprite = contact.bodyA
            partner = contact.bodyB
            wallAroundDidCollideWithMovingSprite(movingSprite.node as! MySKNode, node2: partner.node!)
        default: let a = 0
            
       }
    }
    
    func checkGameArray() -> Int {
        var usedCellCount = 0
        for column in 0..<countColumns {
            for row in 0..<countRows {
                if gameArray[column][row] {
                    usedCellCount++
                }
            }
        }
        return usedCellCount
    }
    
    func checkGameArrayEmpty() {
        
        let usedCellCount = checkGameArray()
        if usedCellCount == 0 { // Level completed, start a new game
            
            // hier checken, ob target Score erreicht!!!
            
            if levelScore < targetScore {
                let alert = UIAlertController(title: GV.language.getText("gameLost"),
                    message: GV.language.getText("targetNotReached"),
                    preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: GV.language.getText("return"), style: .Cancel, handler: nil)
                let againAction = UIAlertAction(title: GV.language.getText("OK"), style: .Default,
                    handler: {(paramAction:UIAlertAction!) in
                        self.newGame(false)
                })
                alert.addAction(cancelAction)
                alert.addAction(againAction)
                parentViewController!.presentViewController(alert, animated: true, completion: nil)
            }
            
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
        }
        
        if usedCellCount < minUsedCells {
            generateSprites()
        }
    }
    
    func doCountDown() {
        GV.currentTime = NSDate()
        GV.elapsedTime = GV.currentTime.timeIntervalSinceDate(GV.startTime)// * 1000
        //println("doCountdown: \(GV.elapsedTime) sec")

        timeLimit--
        showTimeLeft()
        if timeLimit == 0 {
            countDown!.invalidate()
            countDown = nil
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
    
    func showTimeLeft() {
        let countdownText = GV.language.getText("timeLeft")
        let minutes = Int(timeLimit / 60)
        var seconds = "\(Int(timeLimit % 60))"
        seconds = count(seconds) == 1 ? "0\(seconds)" : seconds
        countdownLabel.text = "\(countdownText) \(minutes):\(seconds)"
    }
    
    func printGameArray() {
        for column in 0..<countColumns {
            for row in 0..<countRows {
                print(gameArray[row][countColumns - 1 - column] ? "T " : "F ")
            }
            println()
        }
    }
    

}

