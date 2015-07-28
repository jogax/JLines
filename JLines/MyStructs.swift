//
//  MyStructs.swift
//  JLinesV2
//
//  Created by Jozsef Romhanyi on 18.04.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import UIKit

enum Choosed: Int{
    case Unknown = 0, Right, Left, Settings, Restart
}
enum GameControll: Int {
    case Finger = 0, JoyStick, Accelerometer, PipeLine
}

struct GV {
    static var vBounds = CGRect(x: 0, y: 0, width: 0, height: 0)
    //static var horNormWert: CGFloat = 0 // Geräteabhängige Constante
    //static var vertNormWert: CGFloat = 0 // Geräteabhängige Constante
    static var notificationCenter = NSNotificationCenter.defaultCenter()
    static let notificationGameControllChanged = "gameModusChanged"
    static let notificationMadeMove = "MadeMove"
    static let notificationJoystickMoved = "joystickMoved"
    static let notificationColorChanged = "colorChanged"
    static var dX: CGFloat = 0
    //static var dY: CGFloat = 0
    static let accelerometer   = Accelerometer()
    static var aktColor: LineType = .Unknown
    static var speed: CGSize = CGSizeZero
    static var touchPoint = CGPointZero
    static var gameSize = 5
    static var gameNr = 0
    static var gameSizeMultiplier: CGFloat = 1.0
    static let onIpad = UIDevice.currentDevice().model.substring(0, length: 4) == "iPad"
    static var ipadKorrektur: CGFloat = 0
    static var maxGameNr = 0
    static var volumeNr = 0 {
        didSet {
            if oldValue != volumeNr {
                gameSize = package!.getGameSize(volumeNr)
                maxGameNr = package!.getMaxNumber(volumeNr)
            }
        }
    }
    static var maxVolumeNr = 0
    static var lineCount: Int = 0 {
        didSet {
            let lineString = GV.language.getText("lines")
            GV.lineCountLabel.text = "\(GV.lineCount) / \(GV.lines.count) \(lineString)"
        }
    }
    
    static var moveCount: Int = 0 {
        didSet {
            let step = GV.language.getText("steps")
            GV.moveCountLabel.text = "\(GV.moveCount) / \(GV.lines.count) \(step)"
        }
    }
    static var gameControll = GameControll.Finger
    static var joyStickRadius: CGFloat = 0.0
    static var rectSize: CGFloat = 0 // rectSize in Choose Table
    static var gameRectSize: CGFloat = 0 // rectSize in gameboard
    static var lines = [LineType:Line]()
    static let multiplicator:CGFloat = 0.90
    static var timeAdder = 1
    static let language = Language()
    static var timeCount: Int = 0
    static let TableNumColumns = 5
    static let TableNumRows = 6
    static var aktPage = 0
    static var startTime = NSDate()
    static var currentTime = NSDate()
    static var elapsedTime: Double = 0

    
    static let scrollViewName = "ScrollView"
    static let dataStore = DataStore()
    static let cloudData = CloudData()
    static var package: Package?
    static let volumeName: [Int:String] = [0:"5 x 5", 1:"6 x 6", 2:"7 x 7", 3:"8 x 8", 4:"9 x 9"]
    static let volumeNumber: [String:Int] = ["5 x 5":0, "6 x 6":1, "7 x 7":2, "8 x 8":3, "9 x 9":4]
    static var gameData = MyGames()
    static var appData = AppData()
    static var spriteGameData = SpriteGameData()
    static var sublayer = CALayer()
    static let images = DrawImages()
    
    // Colors
    static let lightSalmonColor     = UIColor(red: 255/255, green: 160/255, blue: 122/255, alpha: 1)
    static let darkTurquoiseColor   = UIColor(red: 0/255,   green: 206/255, blue: 209/255, alpha: 1)
    static let turquoiseColor       = UIColor(red: 64/255,  green: 224/255, blue: 208/255, alpha: 1)
    static let darkBlueColor        = UIColor(red: 0/255,   green: 0/255,   blue: 139/255, alpha: 1)
    static let springGreenColor     = UIColor(red: 0/255,   green: 255/255, blue: 127/255, alpha: 1)
    static let khakiColor           = UIColor(red: 240/255, green: 230/255, blue: 140/255, alpha: 1)
    static let PaleGoldenrodColor   = UIColor(red: 238/255, green: 232/255, blue: 170/255, alpha: 1)
    static let PeachPuffColor       = UIColor(red: 255/255, green: 218/255, blue: 185/255, alpha: 1)
    static let SilverColor          = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1)
    static let BlackColor           = UIColor(red: 0/255,   green: 0/255,   blue: 0/255,    alpha: 1)
    static let DarkForrestGreen     = UIColor(red: 0x25/0xff, green: 0x41/0xff, blue: 0x17/0xff, alpha: 1)
    static let backgroundColor      = UIColor(red: 0xff/0xff, green: 0xff/0xff, blue: 0xff/0xff, alpha: 1)
    static let lightBackgroundColor = UIColor(red: 0xc3/0xff, green: 0xfd/0xff, blue: 0xb8/0xff, alpha: 1)
    static let clearWhiteColor      = UIColor(red: 0xff/0xff, green: 0xff/0xff, blue: 0xff/0xff, alpha: 0.7)


    // generierung new game
    static let createNewGame = false
    static let debugging = false
    static let debuggingFunctions = false
    static let debuggingTime = false
    static let printGeneratedLine = true

    
    // globale Labels
    
    static let moveCountLabel = UILabel()
    static let lineCountLabel = UILabel()
    
    // ColorSets
    static var colorSetIndex = 0
    static var colorSets = [
        // standerad Colors
        [
            UIColor.clearColor(),
            UIColor(red: 0xff/0xff, green: 0x00/0xff, blue: 0x00/0xff, alpha: 1), // Red
            UIColor(red: 0xff/0xff, green: 0xD7/0xff, blue: 0x00/0xff, alpha: 1), // Gold
            UIColor(red: 0x00/0xff, green: 0xff/0xff, blue: 0x7f/0xff, alpha: 1), // Springgreen
            UIColor(red: 0xff/0xff, green: 0x69/0xff, blue: 0xb4/0xff, alpha: 1), // HotPink
            UIColor(red: 0x00/0xff, green: 0x80/0xff, blue: 0x00/0xff, alpha: 1), // green
            UIColor(red: 0x00/0xff, green: 0x80/0xff, blue: 0xff/0xff, alpha: 1), // blue
            UIColor(red: 0xff/0xff, green: 0x00/0xff, blue: 0xff/0xff, alpha: 1), // magenta
            UIColor(red: 0xff/0xff, green: 0xda/0xff, blue: 0x9b/0xff, alpha: 1), // PeachPuff
            UIColor(red: 0x80/0xff, green: 0x00/0xff, blue: 0x80/0xff, alpha: 1), // purpleColor
            UIColor(red: 0xff/0xff, green: 0xa5/0xff, blue: 0x00/0xff, alpha: 1), // orangeColor
            UIColor(red: 0x00/0xff, green: 0xff/0xff, blue: 0xff/0xff, alpha: 1), // cyanColor
            UIColor(red: 0xa5/0xff, green: 0x2a/0xff, blue: 0x2a/0xff, alpha: 1), // brownColor
            UIColor(red: 0x80/0xff, green: 0x80/0xff, blue: 0x80/0xff, alpha: 1), // darkGrayColor
            UIColor(red: 0xc0/0xff, green: 0xc0/0xff, blue: 0xc0/0xff, alpha: 1), // silver
            UIColor(red: 0xc6/0xff, green: 0xbe/0xff, blue: 0x17/0xff, alpha: 1), // caramel
            UIColor(red: 0x7F/0xff, green: 0x46/0xff, blue: 0x2C/0xff, alpha: 1), // sepia
            UIColor.blackColor()
        ],
        
        // light colors
        [
            UIColor.clearColor(),
            UIColor(red: 0xff/0xff, green: 0x00/0xff, blue: 0x00/0xff, alpha: 1), // Red
            UIColor(red: 0x00/0xff, green: 0xff/0xff, blue: 0x00/0xff, alpha: 1), // Green
            UIColor(red: 0x00/0xff, green: 0x00/0xff, blue: 0xff/0xff, alpha: 1), // Blue
            UIColor(red: 0xff/0xff, green: 0xff/0xff, blue: 0x00/0xff, alpha: 1), // Yellow
            UIColor(red: 0x00/0xff, green: 0xff/0xff, blue: 0xff/0xff, alpha: 1), // Cyan
            UIColor(red: 0xff/0xff, green: 0x00/0xff, blue: 0xff/0xff, alpha: 1), // Magenta
            UIColor(red: 0x80/0xff, green: 0x00/0xff, blue: 0x80/0xff, alpha: 1), // Purple
            UIColor(red: 0x80/0xff, green: 0x00/0xff, blue: 0x00/0xff, alpha: 1), // Maroon
            UIColor(red: 0x80/0xff, green: 0x80/0xff, blue: 0x00/0xff, alpha: 1), // Olive
            UIColor(red: 0x00/0xff, green: 0x80/0xff, blue: 0x00/0xff, alpha: 1), // DarkGreen
            UIColor(red: 0xff/0xff, green: 0xa5/0xff, blue: 0x00/0xff, alpha: 1), // Orange
            UIColor(red: 0x00/0xff, green: 0xa0/0xff, blue: 0x00/0xff, alpha: 1), // DarkBlue
            UIColor(red: 0xa5/0xff, green: 0x2a/0xff, blue: 0x2a/0xff, alpha: 1), // Brown
            UIColor(red: 0x00/0xff, green: 0x20/0xff, blue: 0xc2/0xff, alpha: 1), // Cobalt Blue
            UIColor(red: 0x57/0xff, green: 0xfe/0xff, blue: 0xef/0xff, alpha: 1), // Blue Cyrcon
            UIColor(red: 0x6c/0xff, green: 0xc4/0xff, blue: 0x17/0xff, alpha: 1), // Alien Green
            UIColor.blackColor()
        ],
        [
            UIColor.clearColor(),
            UIColor(red: 0x7f/0xff, green: 0x7f/0xff, blue: 0x7f/0xff, alpha: 1), //
            UIColor(red: 0x7f/0xff, green: 0x7f/0xff, blue: 0x7f/0xff, alpha: 1), //
            UIColor(red: 0x7f/0xff, green: 0x7f/0xff, blue: 0x7f/0xff, alpha: 1), //
            UIColor(red: 0x7f/0xff, green: 0x7f/0xff, blue: 0x7f/0xff, alpha: 1), //
            UIColor(red: 0x7f/0xff, green: 0x7f/0xff, blue: 0x7f/0xff, alpha: 1), //
            UIColor(red: 0x7f/0xff, green: 0x7f/0xff, blue: 0x7f/0xff, alpha: 1), //
            UIColor(red: 0x7f/0xff, green: 0x7f/0xff, blue: 0x7f/0xff, alpha: 1), //
            UIColor(red: 0x7f/0xff, green: 0x7f/0xff, blue: 0x7f/0xff, alpha: 1), //
            UIColor(red: 0x7f/0xff, green: 0x7f/0xff, blue: 0x7f/0xff, alpha: 1), //
            UIColor(red: 0x7f/0xff, green: 0x7f/0xff, blue: 0x7f/0xff, alpha: 1), //
            UIColor(red: 0x7f/0xff, green: 0x7f/0xff, blue: 0x7f/0xff, alpha: 1), //
            UIColor(red: 0x7f/0xff, green: 0x7f/0xff, blue: 0x7f/0xff, alpha: 1), //
            UIColor(red: 0x7f/0xff, green: 0x7f/0xff, blue: 0x7f/0xff, alpha: 1), //
            UIColor(red: 0x7f/0xff, green: 0x7f/0xff, blue: 0x7f/0xff, alpha: 1), //
            UIColor(red: 0x7f/0xff, green: 0x7f/0xff, blue: 0x7f/0xff, alpha: 1), //
            UIColor(red: 0x7f/0xff, green: 0x7f/0xff, blue: 0x7f/0xff, alpha: 1), //
            UIColor.blackColor()
        ],
        
        
    ]
    // Constraints
    // static let myDevice = MyDevice()
    
    static func random(min: Int, max: Int) -> Int {
        let randomInt = min + Int(arc4random_uniform(UInt32(max + 1 - min)))
        return randomInt
    }

    static     func drawCircle(size: CGSize, imageColor: CGColor) -> UIImage {
        let opaque = false
        let scale: CGFloat = 1
        let size = size
        let endAngle = CGFloat(2*M_PI)
        
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextBeginPath(ctx)
        
        CGContextSetLineWidth(ctx, 1.0)
        let rect = CGRectMake(0, 0, size.width, size.height);
        let center = CGPoint(x: 0 + size.width / 2, y: 0 + size.height / 2)
        let r0 = size.width / 2.1
        
        CGContextSetFillColorWithColor(ctx, imageColor)
        
        CGContextAddArc(ctx, center.x, center.y, r0, 0, endAngle, 1)
        
        CGContextDrawPath(ctx, kCGPathFill);
        CGContextFillPath(ctx)
        
        //CGContextFillRect(ctx, rect);
        //CGContextSetFillColorWithColor(ctx, imageColor)
        
        CGContextStrokePath(ctx)
        
        
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image
    }

    static func drawButton(size: CGSize, imageColor: CGColor) -> UIImage {
        let opaque = false
        let scale: CGFloat = 1
        let oneGrad = CGFloat(M_PI / 180)
        let size = CGSizeMake(size.width * 0.95, size.height * 0.95)
        let startAngle = CGFloat(0 * oneGrad)
        let endAngle = CGFloat(180 * oneGrad)
        
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextBeginPath(ctx)
        
        CGContextSetLineWidth(ctx, 1.0)
        let center1 = CGPoint(x: 0 + size.height / 4,              y:  size.height / 4)
        let center2 = CGPoint(x: size.width - size.height / 4, y: size.height / 4)
        let center3 = CGPoint(x: size.width - size.height / 4,  y: size.height - size.height / 4)
        let center4 = CGPoint(x: size.height / 4,           y: size.height - size.height / 4)
        
        let p1 = CGPoint(x: 0 ,                             y: 0 + size.height / 4)
        let p2 = CGPoint(x: 0 + size.height / 4,            y: 0.5)
        let p3 = CGPoint(x: size.width - size.height / 4,   y: 0.5)
        let p4 = CGPoint(x: size.width,                     y: 0 + size.height / 4)
        let p5 = CGPoint(x: size.width,                     y: size.height - size.height / 4)
        let p6 = CGPoint(x: size.width - size.height / 4,   y: 0 + size.height)
        let p7 = CGPoint(x: 0  + size.height / 4,           y: 0 + size.height)
        let p8 = CGPoint(x: 0,                              y: size.height - size.height / 4)
        
        
        let r = size.height / 4
        
        CGContextSetFillColorWithColor(ctx, imageColor)
        
        CGContextAddArc(ctx, center1.x, center1.y, r, 270 * oneGrad, 180 * oneGrad, 1)
        CGContextStrokePath(ctx)
        
        CGContextMoveToPoint(ctx, p2.x, p2.y)
        CGContextAddLineToPoint(ctx, p3.x, p3.y)
        CGContextStrokePath(ctx)
        
        CGContextAddArc(ctx, center2.x, center2.y, r, 360 * oneGrad, 270 * oneGrad, 1)
        CGContextStrokePath(ctx)
        
        CGContextMoveToPoint(ctx, p4.x, p4.y)
        CGContextAddLineToPoint(ctx, p5.x, p5.y)
        CGContextStrokePath(ctx)
        
        CGContextAddArc(ctx, center3.x, center3.y, r, 90 * oneGrad, 0 * oneGrad, 1)
        CGContextStrokePath(ctx)
        
        CGContextMoveToPoint(ctx, p6.x, p6.y)
        CGContextAddLineToPoint(ctx, p7.x, p7.y)
        CGContextStrokePath(ctx)
        
        CGContextAddArc(ctx, center4.x, center4.y, r, 180 * oneGrad, 90 * oneGrad, 1)
        CGContextStrokePath(ctx)
        
        CGContextMoveToPoint(ctx, p8.x, p8.y)
        CGContextAddLineToPoint(ctx, p1.x, p1.y)
        CGContextStrokePath(ctx)
        
        CGContextDrawPath(ctx, kCGPathFill);
        CGContextFillPath(ctx)
        
        //CGContextFillRect(ctx, rect);
        //CGContextSetFillColorWithColor(ctx, imageColor)
        
        CGContextStrokePath(ctx)
        
        
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image
    }

    
}

struct GameData {
    var gameName: String
    var gameNumber: Int
    var countLines: Int
    var countMoves: Int {
        didSet {
            var color: CGColor
            if countMoves > 0 {
                switch countMoves {
                    case countLines:    color = UIColor(red: 0/255, green: 255/255, blue: 0/255, alpha: 0.2).CGColor
                    case countLines + 1 ... countLines + 10:
                                        color = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.2).CGColor
                    default:            color = UIColor.clearColor().CGColor
                }
                layer.backgroundColor = color
                layer.setNeedsDisplay()
            }
        }
    }

    
    var countSeconds: Int
    var timeStemp: NSDate
    var layer: CALayer
    
    init() {
        gameName = ""
        gameNumber = 0
        countLines = 0
        countMoves = 0
        countSeconds = 0
        timeStemp = NSDate()
        layer = CALayer()
    }
    init(name: String, number: Int) {
        gameName = name
        gameNumber = number
        countLines = 0
        countMoves = 0
        countSeconds = 0
        timeStemp = NSDate()
        layer = CALayer()
    }
}
struct VolumeData {
    var volume: String
    var games = [GameData]()
    
    init(volumeIndex: Int) {
        volume = GV.package!.getVolumeName(volumeIndex) as String
        for ind in 0..<GV.TableNumRows * GV.TableNumColumns {
            games.append(GameData(name: volume, number: ind))
        }
        
    }

}


struct MyGames {
    var volumes = [VolumeData]()
    
    init() {
        for volumeIndex in 0..<GV.maxVolumeNr {
            volumes.append(VolumeData(volumeIndex: volumeIndex))
        }
    }
}

struct AppData {
    var gameControll: Int64
    var farbSchemaIndex: Int64
    var farbSchemas: String

    init() {
        gameControll = Int64(GameControll.Finger.rawValue)
        farbSchemaIndex = Int64(GV.colorSetIndex)
        farbSchemas = ""
    }
    
}

struct SpriteGameData {
    var spriteLevelIndex: Int64
    var spriteGameScore: Int64
    
    init() {
        spriteLevelIndex = 0
        spriteGameScore = 0
    }
    
}

struct Level {
    var countContainers: Int
    var countSpritesProContainer: Int
    var targetScoreKorr: Double
    var countColumns: Int
    var countRows: Int
    var minProzent: Int
    var maxProzent: Int
    var containerSize: Int
    var spriteSize: Int
    
    init() {
        countContainers = 0
        countSpritesProContainer = 0
        targetScoreKorr = 0
        countColumns = 0
        countRows = 0
        minProzent = 0
        maxProzent = 0
        containerSize = 0
        spriteSize = 0
    }
}


