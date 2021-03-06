//
//  GameScene.swift
//  JSprites
//
//  Created by Jozsef Romhanyi on 11.07.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
import AVFoundation

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
    static let GameScene:       UInt32 = 0b1        // 1
    static let LabelNode:       UInt32 = 0b10       // 2
    static let SpriteNode:      UInt32 = 0b100      // 4
    static let ContainerNode:   UInt32 = 0b1000     // 8
    static let ButtonNode:      UInt32 = 0b10000    // 16
}

struct Container {
    let mySKNode: MySKNode
    var label: SKLabelNode
    var countHits: Int
}

enum SpriteStatus: Int, Printable {
    case Added = 0, MovingStarted, SizeChanged, Mirrored, FallingMovingSprite, FallingSprite, HitcounterChanged, Removed

    var statusName: String {
        let statusNames = [
            "Added",
            "MovingStarted",
            "SizeChanged",
            "Mirrored",
            "FallingMovingSprite",
            "FallingSprite",
            "HitcounterChanged",
            "Removed"
        ]
        
        return statusNames[rawValue]
    }

    var description: String {
        return statusName
    }
    
}

struct SavedSprite {
    var status: SpriteStatus = .Added
    var name: String = ""
    var startPosition: CGPoint = CGPointMake(0, 0)
    var endPosition: CGPoint = CGPointMake(0, 0)
    var colorIndex: Int = 0
    var size: CGSize = CGSizeMake(0, 0)
    var hitCounter: Int = 0
    var column: Int = 0
    var row: Int = 0
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

class GameScene: SKScene, SKPhysicsContactDelegate, AVAudioPlayerDelegate {
    
    // Values from json File
    var params = ""
    var countSpritesProContainer: Int?
    var countColumns = 0
    var countRows = 0
    var countContainers = 0
    var targetScoreKorr: Int = 0
    var tableCellSize: CGFloat = 0
    var containerSize:CGFloat = 0
    var spriteSize:CGFloat = 0
    var minUsedCells = 0
    var maxUsedCells = 0
    
    var countMovingSprites = 0
    
    let timeLimitKorr = 5 // sec for pro Sprite
    var timeLimit = 0 // seconds

    var timer: NSTimer?
    var countDown: NSTimer?
    var waitForSKActionEnded: NSTimer?
    
    struct ColorTabLine {
        var colorIndex: Int
        var spriteName: String
        init(colorIndex: Int, spriteName: String){
            self.colorIndex = colorIndex
            self.spriteName = spriteName
        }
    }
    
    var colorTab = [ColorTabLine]()
    var containers = [Container]()
    var countColorsProContainer = [Int]()
    
    var movedFromNode: MySKNode!
    var restartButton: MySKNode?
    var undoButton: MySKNode?
    var gameArray = [[Bool]]() // true if Cell used
    var collisionActive = false
    var levelIndex = Int(GV.spriteGameData.spriteLevelIndex)
    var gameScore = Int(GV.spriteGameData.spriteGameScore)
    var levelScore = 0
    let deviceIndex = GV.onIpad ? 0 : 1
    var parentViewController: UIViewController?
    var spriteCountLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var levelLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var gameScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var levelScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var countdownLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var targetScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var buttonField: SKSpriteNode?
    //var levelArray = [Level]()
    var countLostGames = 0
    var stopped = true
    
    var spriteGameLastPosition = CGPointZero
    
    let levelPosKorr = CGPointMake(GV.onIpad ? 0.5 : 0.5, GV.onIpad ? 0.97 : 0.97)
    let gameScorePosKorr = CGPointMake(GV.onIpad ? 0.1 : 0.05, GV.onIpad ? 0.95 : 0.94)
    let levelScorePosKorr = CGPointMake(GV.onIpad ? 0.1 : 0.05, GV.onIpad ? 0.93 : 0.92)
    let spriteCountPosKorr = CGPointMake(GV.onIpad ? 0.1 : 0.05, GV.onIpad ? 0.91 : 0.90)
    let countdownPosKorr = CGPointMake(GV.onIpad ? 0.98 : 0.98, GV.onIpad ? 0.95 : 0.94)
    let targetPosKorr = CGPointMake(GV.onIpad ? 0.98 : 0.98, GV.onIpad ? 0.93 : 0.92)
    let containersPosCorr = CGPointMake(GV.onIpad ? 0.98 : 0.98, GV.onIpad ? 0.85 : 0.80)
    var targetScore = 0
    var spriteCount = 0

    var levelsForPlayWithSprites = LevelsForPlayWithSprites()
    var audioPlayer: AVAudioPlayer?
    var soundPlayer: AVAudioPlayer?
    var stack:Stack<SavedSprite> = Stack()
    
    let scoreAddCorrected = [1:1, 2:2, 3:3, 4:4, 5:5, 6:7, 7:8, 8:10, 9:11, 10:13, 11:14, 12:16,13:17,14:19, 15:20, 16:22, 17:23, 18:24, 19:25, 20:27, 21:28, 22:30, 23:31, 24:33, 25:34, 26:36, 27:37, 28:39, 29:40, 30:42, 31:43, 32:45, 33:46, 34:47, 35:48, 36:50, 37:51, 38:53, 39:54, 40:54, 41:53, 42:53, 43:52, 44:52, 45:51, 46:51, 47:51, 48:50, 49:50, 50:50, 51:51, 52:52, 53:53, 54:54, 55:55, 56:56, 57:57, 58:58, 59:59, 60:60, 61:61, 62:62, 63:63, 64:64, 65:65, 66:66, 67:67, 68:68, 69:69, 70:70, 71:71, 72:72, 73:73, 74:74, 75:75, 76:76, 77:77, 78:78, 79:79, 80:80, 81:81, 82:82, 83:83, 84:84, 85:85, 86:86, 87:87, 88:88, 89:89, 90:90, 91:91, 92:92, 93:93, 94:94, 95:95, 96:96, 97:97, 98:98, 99:99, 100:100]
    

    
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
        //levelArray = GV.cloudData.readLevelDataArray()
        let url = NSURL.fileURLWithPath(
            NSBundle.mainBundle().pathForResource("MyMusic",
                ofType: "m4a")!)
        var error: NSError?
        //backgroundColor = SKColor(patternImage: UIImage(named: "aquarium.png")!)
        var bgImage = SKSpriteNode(imageNamed: "aquarium.png")
        bgImage.size = CGSizeMake(1200, 1600)
        bgImage.zPosition = -1000
        
        self.addChild(bgImage)
        audioPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
        if let err = error {
            println("audioPlayer error \(err.localizedDescription)")
        } else {
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 0.03
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        }

        GV.currentTime = NSDate()
        GV.elapsedTime = GV.currentTime.timeIntervalSinceDate(GV.startTime) * 1000
        println("GameScene start: \(GV.elapsedTime)")
        myView = view
//        let (package, data) = Dictionary<String, AnyObject>.loadJSONFromBundle("LevelsForPlayWithSprites")
//        json = JSON(data: data!)
        levelsForPlayWithSprites.setAktLevel(levelIndex)
        prepareNextGame()
        generateSprites()
        
       
    }
    
    func restartButtonPressed() {
        newGame(false)
    }

    func undoButtonPressed() {
        pull()
    }
    
    func prepareNextGame() {
        //var currentTime = NSDate()
        GV.startTime = NSDate()
        stack = Stack()
        if countDown != nil {
            countDown!.invalidate()
            countDown = nil
        }

        buttonField = SKSpriteNode(texture: nil)
        buttonField!.color = SKColor.blueColor()
        buttonField!.position = CGPointMake(self.position.x + self.size.width / 2, self.position.y)
        buttonField!.size = CGSizeMake(self.size.width, self.size.height * 0.2)
        self.addChild(buttonField!)

        countContainers = levelsForPlayWithSprites.aktLevel.countContainers
        countSpritesProContainer = levelsForPlayWithSprites.aktLevel.countSpritesProContainer
        targetScoreKorr = levelsForPlayWithSprites.aktLevel.targetScoreKorr
        countColumns = levelsForPlayWithSprites.aktLevel.countColumns
        countRows = levelsForPlayWithSprites.aktLevel.countRows
        minUsedCells = levelsForPlayWithSprites.aktLevel.minProzent * countColumns * countRows / 100
        maxUsedCells = levelsForPlayWithSprites.aktLevel.maxProzent * countColumns * countRows / 100
        containerSize = CGFloat(levelsForPlayWithSprites.aktLevel.containerSize)
        spriteSize = CGFloat(levelsForPlayWithSprites.aktLevel.spriteSize)

        timeLimit = countContainers * countSpritesProContainer! * levelsForPlayWithSprites.aktLevel.timeLimitKorr
        println("timeLimit: \(timeLimit)")
        
        gameArray.removeAll(keepCapacity: false)
        containers.removeAll(keepCapacity: false)

        for column in 0..<countRows {
            gameArray.append(Array(count: countRows, repeatedValue:false))
        }
        
        colorTab.removeAll(keepCapacity: false)
        var spriteName = 10000
        for containerIndex in 0..<countContainers {
            for index in 0..<countSpritesProContainer! {
                let colorTabLine = ColorTabLine(colorIndex: containerIndex, spriteName: "\(spriteName++)")
                colorTab.append(colorTabLine)
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
            containers[index].mySKNode.name = "\(index)"
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
        //println("befüllung Containers: \(GV.elapsedTime)")
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

        spriteCountLabel.position = CGPointMake(self.position.x + self.size.width * spriteCountPosKorr.x, self.position.y + self.size.height * spriteCountPosKorr.y)
        spriteCountLabel.fontColor = SKColor.blackColor()
        spriteCountLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        spriteCountLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        spriteCountLabel.fontSize = 15;
        spriteCount = Int(CGFloat(countContainers * countSpritesProContainer!))
        let spriteCountText: String = GV.language.getText("spriteCount")
        spriteCountLabel.text = "\(spriteCountText) \(spriteCount)"
        self.addChild(spriteCountLabel)

        
        targetScoreLabel.position = CGPointMake(self.position.x + self.size.width * targetPosKorr.x, self.position.y + self.size.height * targetPosKorr.y)
        targetScoreLabel.fontColor = SKColor.blackColor()
        targetScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        targetScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        targetScoreLabel.fontSize = 15;
        targetScore = countContainers * countSpritesProContainer! * targetScoreKorr
        let targetScoreText: String = GV.language.getText("targetScore")
        targetScoreLabel.text = "\(targetScoreText) \(targetScore)"
        self.addChild(targetScoreLabel)
        
        
        //let buttonTextureNormal = SKTexture(image: GV.drawButton(CGSizeMake(100,40), imageColor: UIColor.blueColor().CGColor))
        //let buttonTextureSelected = SKTexture(image: GV.drawButton(CGSizeMake(95,38), imageColor: UIColor.blueColor().CGColor))

        let restartTextureNormal = SKTexture(imageNamed: "restart")

        restartButton = MySKNode(texture: restartTextureNormal, type: MySKNodeType.ButtonType)
        //restartButton = SKButton(normalTexture: restartTextureNormal, selectedTexture: restartTextureSelected, disabledTexture: restartTextureNormal)
        restartButton!.position = CGPointMake(myView.frame.width / 2, myView.frame.height * 0.05)
        restartButton!.size = CGSizeMake(myView.frame.width / 10, myView.frame.width / 10)
        //restartButton!.setButtonAction(self, triggerEvent: .TouchUpInside, action:"restartButtonPressed")
        restartButton!.name = "restart"
        addChild(restartButton!)
        
        let undoTextureNormal = SKTexture(imageNamed: "undo")
        
        //undoButton = SKButton(normalTexture: undoTextureNormal, selectedTexture: undoTextureSelected, disabledTexture: undoTextureNormal)
        undoButton = MySKNode(texture: undoTextureNormal, type: MySKNodeType.ButtonType)
        undoButton!.position = CGPointMake(myView.frame.width / 3, myView.frame.height * 0.05)
        undoButton!.size = CGSizeMake(myView.frame.width / 10, myView.frame.width / 10)
        //undoButton!.setButtonAction(self, triggerEvent: .TouchUpInside, action:"undoButtonPressed")
        undoButton!.name = "undo"
        addChild(undoButton!)
        
        backgroundColor = UIColor.whiteColor() //SKColor.whiteColor()
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        self.countDown = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("doCountDown"), userInfo: nil, repeats: true)
        GV.currentTime = NSDate()
        GV.elapsedTime = GV.currentTime.timeIntervalSinceDate(GV.startTime) //* 1000
        //println("prepareNextGame Laufzeit: \(GV.elapsedTime)")
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
            switch (testNode as! MySKNode).type {
            case .ContainerType: return MyNodeTypes.ContainerNode
            case .SpriteType: return MyNodeTypes.SpriteNode
            case .ButtonType: return MyNodeTypes.ButtonNode
            default: return MyNodeTypes.none
            }
        default: return MyNodeTypes.none
        }
    }
    
    func newGame(next: Bool) {
        stopped = true
        if next {

            levelIndex = levelsForPlayWithSprites.getNextLevel()
            gameScore += levelScore
            var spriteData = SpriteGameData()
            spriteData.spriteLevelIndex = Int64(levelIndex)
            spriteData.spriteGameScore = Int64(gameScore)
            GV.dataStore.createSpriteGameRecord(spriteData)
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
            let colorIndex = colorTab[colorTabIndex].colorIndex
            let spriteName = colorTab[colorTabIndex].spriteName
            colorTab.removeAtIndex(colorTabIndex)
            
            let aktColor = GV.colorSets[GV.colorSetIndex][colorIndex + 1].CGColor
            var spriteTexture = SKTexture()
//            if colorIndex == 0 {
                spriteTexture = SKTexture(imageNamed: "sprite\(colorIndex)")
//            } else {
//                containerTexture = SKTexture(image: GV.drawCircle(CGSizeMake(spriteSize,spriteSize), imageColor: aktColor))
//            }
            let sprite = MySKNode(texture: spriteTexture, type: .SpriteType)
            sprite.size.width = spriteSize
            sprite.size.height = spriteSize
            let yKorr1: CGFloat = GV.onIpad ? 0.9 : 0.8
            let yKorr2: CGFloat = GV.onIpad ? 1.8 : 2.0

            let index = GV.random(0, max: positionsTab.count - 1)
            let (aktColumn, aktRow) = positionsTab[index]
            let xPosition = CGFloat(aktColumn) * tableCellSize + tableCellSize / 2
            let yPosition = CGFloat(aktRow) * tableCellSize * yKorr1 + tableCellSize * yKorr2
            sprite.position = CGPoint(x: xPosition, y: yPosition)
            sprite.startPosition = sprite.position
            gameArray[aktColumn][aktRow] = true
            positionsTab.removeAtIndex(index)
            
            sprite.column = aktColumn
            sprite.row = aktRow
            sprite.name = spriteName
            sprite.colorIndex = colorIndex
            
            addPhysicsBody(sprite)
            push(sprite, status: .Added)
            addChild(sprite)
        }
        stopped = false
    }
    
    func addPhysicsBody(sprite: MySKNode) {
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
        sprite.physicsBody?.dynamic = true
        sprite.physicsBody?.categoryBitMask = PhysicsCategory.Sprite
        sprite.physicsBody?.contactTestBitMask = PhysicsCategory.MovingSprite
        sprite.physicsBody?.collisionBitMask = PhysicsCategory.None
        sprite.physicsBody?.usesPreciseCollisionDetection = true
    }

    func makeLineAroundGameboard(linePosition: LinePosition) {
        var point1: CGPoint
        var point2: CGPoint
        var myWallRect: CGRect

        var width: CGFloat = 4
        var length: CGFloat = 0
        let yKorrBottom = size.height * 0.1
        switch linePosition {
        case .bottomHorizontal:  myWallRect = CGRectMake(position.x, position.y + yKorrBottom, size.width, 1)
        case .rightVertical:    myWallRect = CGRectMake(position.x + size.width, position.y + yKorrBottom,  1, size.height)
        case .upperHorizontal: myWallRect = CGRectMake(position.x, position.y + size.height,  size.width, 1)
        case .leftVertical:     myWallRect = CGRectMake(position.x, position.y + yKorrBottom,  1, size.height)
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
            case MyNodeTypes.SpriteNode:
                movedFromNode = self.nodeAtPoint(touchLocation) as! MySKNode
                let fingerNode = SKSpriteNode(imageNamed: "finger.png")
                fingerNode.name = "finger"
                fingerNode.position = touchLocation
                fingerNode.size = CGSizeMake(25,25)
                addChild(fingerNode)
            

            case MyNodeTypes.ContainerNode: movedFromNode = nil
            case MyNodeTypes.ButtonNode:
                movedFromNode = self.nodeAtPoint(touchLocation) as! MySKNode
                let textureName = "\(testNode.name!)Pressed"
                let textureSelected = SKTexture(imageNamed: textureName)
                (testNode as! MySKNode).texture = textureSelected
            default: movedFromNode = nil
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if movedFromNode != nil {
            if self.childNodeWithName("myLine") != nil {
                self.childNodeWithName("myLine")!.removeFromParent()
            }
//            if self.childNodeWithName("myLine") != nil {
//                self.childNodeWithName("myLine")!.removeFromParent()
//            }
            let countTouches = touches.count
            let firstTouch = touches.first as! UITouch
            let touchLocation = firstTouch.locationInNode(self)
            let testNode = self.nodeAtPoint(touchLocation)
            let aktNodeType = analyzeNode(testNode)
            var aktNode: SKNode? = movedFromNode
            switch aktNodeType {
                case MyNodeTypes.LabelNode: aktNode = self.nodeAtPoint(touchLocation).parent as! MySKNode
                case MyNodeTypes.SpriteNode: aktNode = self.nodeAtPoint(touchLocation) as! MySKNode
                case MyNodeTypes.ButtonNode: self.nodeAtPoint(touchLocation) as! MySKNode
                default: aktNode = nil
            }
            if movedFromNode != aktNode {
                if movedFromNode.type == .ButtonType {
                    movedFromNode.texture = SKTexture(imageNamed: "\(movedFromNode.name!)")
                } else {
                    let offset = touchLocation - movedFromNode.position
                    let direction = offset.normalized()
                    let shootAmount = direction * 1000
                    let realDest = shootAmount + movedFromNode.position
                    
                    let pathToDraw:CGMutablePathRef = CGPathCreateMutable()
                    let myLine:SKShapeNode = SKShapeNode(path:pathToDraw)
                    myLine.lineWidth = movedFromNode.size.width
                    
                    myLine.name = "myLine"
                    CGPathMoveToPoint(pathToDraw, nil, movedFromNode.position.x, movedFromNode.position.y)
                    CGPathAddLineToPoint(pathToDraw, nil, realDest.x, realDest.y)
                    
                    myLine.path = pathToDraw
                    //let name = movedFromNode.name!
                    //let colorIndex = name.toInt()! - 100
                    let colorIndex = movedFromNode.colorIndex
                    
                    myLine.strokeColor = SKColor(red: 1.0, green: 0, blue: 0, alpha: 0.05) // GV.colorSets[GV.colorSetIndex][colorIndex + 1]
                    self.addChild(myLine)
                }
            }

            let fingerNode = self.childNodeWithName("finger")! as? SKSpriteNode
            fingerNode!.position = touchLocation
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        while self.childNodeWithName("myLine") != nil {
            self.childNodeWithName("myLine")!.removeFromParent()
        }
        if movedFromNode != nil && !stopped {
            let countTouches = touches.count
            let firstTouch = touches.first as! UITouch
            let touchLocation = firstTouch.locationInNode(self)
            let testNode = self.nodeAtPoint(touchLocation)
            
            let aktNodeType = analyzeNode(testNode)
            var aktNode: SKNode? = movedFromNode
            switch aktNodeType {
                case MyNodeTypes.LabelNode: aktNode = self.nodeAtPoint(touchLocation).parent as! MySKNode
                case MyNodeTypes.SpriteNode: aktNode = self.nodeAtPoint(touchLocation) as! MySKNode
                case MyNodeTypes.ButtonNode:
                    (testNode as! MySKNode).texture = SKTexture(imageNamed: "\(testNode.name!)")
                default: aktNode = nil
            }

            if aktNode != nil && (aktNode as! MySKNode).type == .ButtonType {
                switch (aktNode as! MySKNode).name! {
                    case "restart": restartButtonPressed()
                    case "undo": undoButtonPressed()
                    default: undoButtonPressed()
                }
            } else {
                if let fingerNode = self.childNodeWithName("finger")! as? SKSpriteNode {
                    fingerNode.removeFromParent()
                }

                if aktNode == nil || (aktNode as! MySKNode) != movedFromNode {
                    let sprite = movedFromNode// as! SKSpriteNode
                    sprite!.physicsBody = SKPhysicsBody(circleOfRadius: sprite!.size.width/2)
                    //println("nodeSize:\(node.size.width)")
                    sprite.physicsBody?.dynamic = true
                    sprite.physicsBody?.categoryBitMask = PhysicsCategory.MovingSprite
                    sprite.physicsBody?.contactTestBitMask = PhysicsCategory.Sprite | PhysicsCategory.Container | PhysicsCategory.WallAround
                    sprite.physicsBody?.collisionBitMask = PhysicsCategory.None
                    
                    sprite.physicsBody?.usesPreciseCollisionDetection = true
                    let offset = touchLocation - movedFromNode.position

                    let direction = offset.normalized()
                    
                    // 7 - Make it shoot far enough to be guaranteed off screen
                    let shootAmount = direction * 1000
                    
                    // 8 - Add the shoot amount to the current position
                    let realDest = shootAmount + movedFromNode.position
                    
                    push(sprite, status: .MovingStarted)
                    // 9 - Create the actions
                    let actionMove = SKAction.moveTo(realDest, duration: 2.0)
                    //let actionMoveDone = SKAction.removeFromParent()
                    collisionActive = true
                    
                    self.userInteractionEnabled = false  // userInteraction forbidden!
                    countMovingSprites = 1
                    self.waitForSKActionEnded = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("checkCountMovingSprites"), userInfo: nil, repeats: false) // start timer for check

                    movedFromNode.runAction(SKAction.sequence([actionMove]))//, actionMoveDone]))
                }
            }
        }
    }
        
    
    func showScore() {
        levelScore = 0
        var gameScore = 0
        for index in 0..<containers.count {
            levelScore += containers[index].mySKNode.hitCounter
        }
        let levelScoreText: String = GV.language.getText("levelScore")
        levelScoreLabel.text = "\(levelScoreText) \(levelScore)"

    }
    
    func playSound(fileName: String, volume: Float) {
        let url = NSURL.fileURLWithPath(
            NSBundle.mainBundle().pathForResource(fileName, ofType: "m4a")!)
        var error: NSError?
        soundPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
        if let err = error {
            println("audioPlayer error \(err.localizedDescription)")
        } else {
            soundPlayer?.delegate = self
            soundPlayer?.prepareToPlay()
            soundPlayer?.volume = volume
            soundPlayer?.play()
        }
    }
    
    func spriteDidCollideWithContainer(node1:MySKNode, node2:MySKNode) {
        let movingSprite = node1
        let container = node2
        
        let containerColorIndex = container.colorIndex
        let spriteColorIndex = movingSprite.colorIndex
        var OK = containerColorIndex == spriteColorIndex
        
        push(container, status: .HitcounterChanged)
        push(movingSprite, status: .Removed)
        
        
        //println("spriteName: \(containerColorIndex), containerName: \(spriteColorIndex)")
        if OK {
            if movingSprite.hitCounter < 100 {
                container.hitCounter += scoreAddCorrected[movingSprite.hitCounter]! // when only 1 sprite, then add 0
            } else {
                container.hitCounter += movingSprite.hitCounter
            }
            showScore()
            playSound("Container", volume: 0.03)
        } else {
            container.hitCounter -= movingSprite.hitCounter
            showScore()
            playSound("Funk_Bot", volume: 0.03)
        }

        countMovingSprites = 0

        spriteCount--
        let spriteCountText: String = GV.language.getText("spriteCount")
        spriteCountLabel.text = "\(spriteCountText) \(spriteCount)"

        collisionActive = false
        movingSprite.removeFromParent()
        gameArray[movingSprite.column][movingSprite.row] = false
        checkGameFinished()
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
            
            push(sprite, status: .SizeChanged)
            push(movingSprite, status: .Removed)
            
            sprite.hitCounter = movingSprite.hitCounter + sprite.hitCounter
            let aktSize = spriteSize + 1.2 * CGFloat(sprite.hitCounter)
            sprite.size.width = aktSize
            sprite.size.height = aktSize
            playSound("Sprite1", volume: 0.03)
            
            gameArray[movingSprite.column][movingSprite.row] = false
            movingSprite.removeFromParent()
            countMovingSprites = 0
        } else {
            push(sprite, status: .FallingSprite)
            push(movingSprite, status: .FallingMovingSprite)
            
            sprite.zPosition = 0
            movingSprite.zPosition = 0
            movingSprite.physicsBody?.categoryBitMask = PhysicsCategory.None
            containers[movingSprite.colorIndex].mySKNode.hitCounter -= movingSprite.hitCounter
            containers[sprite.colorIndex].mySKNode.hitCounter -= sprite.hitCounter
            let movingSpriteDest = CGPointMake(movingSprite.position.x * 0.5, 0)
            
            movingSprite.startPosition = movingSprite.position
            movingSprite.position = movingSpriteDest
            push(movingSprite, status: .Removed)
            
            countMovingSprites = 2

            let movingSpriteAction = SKAction.moveTo(movingSpriteDest, duration: 1.0)
            let actionMoveDone = SKAction.removeFromParent()
            
            movingSprite.runAction(SKAction.sequence([movingSpriteAction, actionMoveDone]), completion: {countMovingSprites--})
            
            
            var spriteDest = CGPointMake(sprite.position.x * 1.5, 0)
            sprite.startPosition = sprite.position
            sprite.position = spriteDest
            push(sprite, status: .Removed)
            

            let actionMove2 = SKAction.moveTo(spriteDest, duration: 1.5)
            sprite.runAction(SKAction.sequence([actionMove2, actionMoveDone]), completion: {countMovingSprites--})
            gameArray[movingSprite.column][movingSprite.row] = false
            gameArray[sprite.column][sprite.row] = false
            spriteCount--
            playSound("Drop", volume: 0.03)
            showScore()
        }
        spriteCount--
        let spriteCountText: String = GV.language.getText("spriteCount")
        spriteCountLabel.text = "\(spriteCountText) \(spriteCount)"
        checkGameFinished()
    }

    func checkCountMovingSprites() {
        if  countMovingSprites > 0 {
            //println("countMovingSprites: \(countMovingSprites)")
            self.waitForSKActionEnded = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("checkCountMovingSprites"), userInfo: nil, repeats: false)
        } else {
            self.userInteractionEnabled = true
        }
    }
    
    func wallAroundDidCollideWithMovingSprite(node1: MySKNode, node2: SKNode) {
        let movingSprite = node1
        if spriteGameLastPosition != movingSprite.position {
            spriteGameLastPosition = movingSprite.position
            let lineAround = node2
            let originalPosition = movingSprite.startPosition
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
            
            movingSprite.startPosition = movingSprite.position
            movingSprite.hitCounter = Int(CGFloat(movingSprite.hitCounter) * 1.5)
            push(movingSprite, status: .Mirrored)
            
            let actionMove = SKAction.moveTo(realDest, duration: 2.0)
            collisionActive = true
            movingSprite.runAction(SKAction.sequence([actionMove]))//, actionMoveDone]))
            playSound("Mirror", volume: 0.03)
            checkGameFinished()
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
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
    
    func checkGameFinished() {
        
        
        let usedCellCount = checkGameArray()

        if usedCellCount == 0 || levelScore > targetScore { // Level completed, start a new game
            countDown!.invalidate()
            countDown = nil
            playSound("Lost", volume: 0.03)
            
            if levelScore < targetScore {
                countLostGames++
                let lost3Times = countLostGames > 2 && levelIndex > 1
                var alert = UIAlertController(title: GV.language.getText(lost3Times ? "gameLost3": "gameLost"),
                    message: GV.language.getText("targetNotReached"),
                    preferredStyle: .Alert)
                if lost3Times {
                    countLostGames = 0
                    levelIndex -= 2
                }
                let cancelAction = UIAlertAction(title: GV.language.getText("return"), style: .Cancel, handler: nil)
                let againAction = UIAlertAction(title: GV.language.getText("OK"), style: .Default,
                    handler: {(paramAction:UIAlertAction!) in
                        self.newGame(lost3Times)
                })
                alert.addAction(cancelAction)
                alert.addAction(againAction)
                parentViewController!.presentViewController(alert, animated: true, completion: nil)
            } else {
                
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
                playSound("Winner", volume: 0.03)
                parentViewController!.presentViewController(alert, animated: true, completion: nil)
            }
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
            stopped = true
            countLostGames++
            playSound("Timeout", volume: 0.03)
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
    
    func push(sprite: MySKNode, status: SpriteStatus) {
        var savedSprite = SavedSprite()
        savedSprite.name = sprite.name!
        savedSprite.status = status
        savedSprite.startPosition = sprite.startPosition
        savedSprite.endPosition = sprite.position
        savedSprite.colorIndex = sprite.colorIndex
        savedSprite.size = sprite.size
        savedSprite.hitCounter = sprite.hitCounter
        savedSprite.column = sprite.column
        savedSprite.row = sprite.row
        if savedSprite.status != .Added {
//            println("push -> status: \(savedSprite.status), name: \(savedSprite.name), sPos: \(savedSprite.startPosition), ePos: \(savedSprite.endPosition)" )
        }
        stack.push(savedSprite)
    }
    
    func pull() {
        let duration = 0.5
        var actionMoveArray = [SKAction]()
        if let savedSprite = stack.pull() {
            var savedSpriteInCycle = savedSprite
            var run = true
            var stopSoon = false
        
//        if savedSpriteInCycle.status != .Added {
            do {
//                println("pull -> status: \(savedSpriteInCycle.status),  name: \(savedSpriteInCycle.name), sPos: \(savedSpriteInCycle.startPosition), ePos: \(savedSpriteInCycle.endPosition)" )
                switch savedSpriteInCycle.status {
                case .Added:
                    if stack.countChangesInStack() > 0 {
                        let spriteName = savedSpriteInCycle.name
                        let colorIndex = savedSpriteInCycle.colorIndex
                        let searchName = "\(spriteName)"
                        self.childNodeWithName(searchName)!.removeFromParent()
                        let colorTabLine = ColorTabLine(colorIndex: colorIndex, spriteName: spriteName)
                        colorTab.append(colorTabLine)
                        gameArray[savedSpriteInCycle.column][savedSpriteInCycle.row] = false
                    }
                case .Removed:
                    let spriteTexture = SKTexture(imageNamed: "sprite\(savedSpriteInCycle.colorIndex)")
                    var sprite = MySKNode(texture: spriteTexture, type: .SpriteType)
                    sprite.colorIndex = savedSpriteInCycle.colorIndex
                    sprite.position = savedSpriteInCycle.endPosition
                    sprite.startPosition = savedSpriteInCycle.startPosition
                    sprite.size = savedSpriteInCycle.size
                    sprite.column = savedSpriteInCycle.column
                    sprite.row = savedSpriteInCycle.row
                    sprite.hitCounter = savedSpriteInCycle.hitCounter
                    sprite.name = savedSpriteInCycle.name
                    gameArray[savedSpriteInCycle.column][savedSpriteInCycle.row] = true
                    addPhysicsBody(sprite)
                    self.addChild(sprite)
                    spriteCount++
                    let spriteCountText: String = GV.language.getText("spriteCount")
                    spriteCountLabel.text = "\(spriteCountText) \(spriteCount)"
                    
                case .SizeChanged:
                    var sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    sprite.hitCounter = savedSpriteInCycle.hitCounter
                    sprite.size = savedSpriteInCycle.size

                case .HitcounterChanged:
                    containers[savedSpriteInCycle.colorIndex].mySKNode.hitCounter = savedSpriteInCycle.hitCounter
                    showScore()
                    
                case .MovingStarted:
                    var sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    sprite.hitCounter = savedSpriteInCycle.hitCounter
                    sprite.startPosition = savedSpriteInCycle.startPosition
                    actionMoveArray.append(SKAction.moveTo(savedSpriteInCycle.endPosition, duration: duration))
                    sprite.runAction(SKAction.sequence(actionMoveArray))

                case .FallingMovingSprite:
                    var sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    sprite.hitCounter = savedSpriteInCycle.hitCounter
                    containers[savedSpriteInCycle.colorIndex].mySKNode.hitCounter += sprite.hitCounter
                    actionMoveArray.append(SKAction.moveTo(savedSpriteInCycle.endPosition, duration: duration))
                    
                case .FallingSprite:
                    var sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    sprite.hitCounter = savedSpriteInCycle.hitCounter
                    sprite.startPosition = savedSpriteInCycle.startPosition
                    containers[savedSpriteInCycle.colorIndex].mySKNode.hitCounter += sprite.hitCounter
                    let moveFallingSprite = SKAction.moveTo(savedSpriteInCycle.startPosition, duration: duration)
                    sprite.runAction(SKAction.sequence([moveFallingSprite]))
                    
                case .Mirrored:
                    var sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    actionMoveArray.append(SKAction.moveTo(savedSpriteInCycle.endPosition, duration: duration))
                    
                default: run = false
                }
                if let savedSprite = stack.pull() {
                    savedSpriteInCycle = savedSprite
                    if (savedSpriteInCycle.status == .Added && stack.countChangesInStack() == 0) || stopSoon {
                        stack.push(savedSpriteInCycle)
                        run = false
                    }
                    if savedSpriteInCycle.status == .MovingStarted {
                        stopSoon = true
                    }
                } else {
                    run = false
                }
            } while run
            showScore()
        }
            

            
//        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully
        flag: Bool) {
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!,
        error: NSError!) {
    }
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer!) {
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer!) {
    }


}

