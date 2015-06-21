//
//  MyGameView.swift
//  JLinesV1
//
//  Created by Jozsef Romhanyi on 09.03.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit

class MyGameView: UIView {

    //var gameNumber: Int?
    var package: Package?
    var alertPresented = false
    //var volumeNr: Int?

    //var gameboard: Array2D<Point>?
    
    var gameboard: GameBoard?
    var notInMove = true

    var error: String?
    var startPointX: Int = -1
    var startPointY: Int = -1
    var aktColor: LineType = .Unknown
    var nextLevel: Bool?
    var alertNotReady: Bool?
    var rectSize: CGFloat?
    //var moveCount: Int = 0
    var parent: UIViewController    //var gameEnded: ()->()?
    var gameEnded: (Bool)->()
    var lastColor = LineType.Unknown
    
    var bgLayer = MyLayer()
    var lineLayers = [LineType:MyLayer]()
    var pointLayer: MyLayer?
    

    init(frame: CGRect, package: Package, parent: UIViewController, gameEnded: (Bool)->()) {
        self.parent = parent
        var device = UIDevice.currentDevice()					//Get the device object
        self.gameEnded = gameEnded
        var gameArray: Array2D<Point>
        var error: String
        var lines: [LineType:Line]
        //gameEnded = {return ()}
        var OK = true
        var numColors = 0
        //var maxGameNumber = package.getMaxNumber(volumeNr)
        if GV.gameNr <= GV.maxGameNr {
            (OK, numColors, gameArray, error, lines) = package.getGameNew(GV.volumeNr, numberIn: GV.gameNr)
            if OK {
                if GV.createNewGame {
                    self.gameboard = GameBoard()
                } else {
                    self.gameboard = GameBoard(gameArray: gameArray, lines: lines, numColors: numColors)
                }
            }
            
        } else {
            
            self.gameboard = GameBoard()
            //self.gameboard!.gameArray = gameboard
            //self.gameboard!.lines = lines
        }
        
        
        
        super.init(frame: frame)
        GV.notificationCenter.addObserver(self, selector: "handleMadeMove", name: GV.notificationMadeMove, object: nil)
        if GV.gameNr < GV.maxGameNr {
            //println("GV.volumeNr: \(GV.volumeNr), GV.gameNr: \(GV.gameNr)")
            var gameData = GV.gameData.volumes[GV.volumeNr].games[GV.gameNr]
            //GV.dataStore.createRecord(gameData)
            
            GV.gameRectSize = self.frame.width * GV.gameSizeMultiplier / CGFloat(GV.gameSize)
            
            bgLayer.frame = CGRect(origin: self.frame.origin, size: CGSizeMake(self.frame.width * GV.gameSizeMultiplier, self.frame.height * GV.gameSizeMultiplier))
            bgLayer.backgroundColor = GV.DarkForrestGreen.CGColor //GV.darkTurquoiseColor.CGColor
            bgLayer.color = .Unknown
            bgLayer.name = "background"
            
            self.layer.addSublayer(bgLayer)
            bgLayer.setNeedsDisplay()

            let linesCount = GV.lines.count
            for index in 0..<linesCount {
                let color = LineType(rawValue: (LineType.C1.rawValue + index))!
                makeNewLayer(color)
            }
            
            if GV.gameControll == .JoyStick {
                
            }
        }
        if GV.gameControll == .JoyStick || GV.gameControll == .Accelerometer {
            setRandomAktColor()
        }

    }
    
    func makeNewLayer(color: LineType) {
        lineLayers[color] = MyLayer()
        lineLayers[color]!.color = color
        
        lineLayers[color]!.frame = CGRect(origin: bgLayer.frame.origin, size: bgLayer.frame.size)
        lineLayers[color]!.name = "line"
        self.layer.addSublayer(lineLayers[color])
        GV.lines[color]!.lineEnded = false
        lineLayers[color]!.setNeedsDisplay()
    }
    
    func restart() {
        for index in 0..<GV.lines.count
        {
            let color = LineType(rawValue: (LineType.C1.rawValue + index))!
            let line = GV.lines[color]!
            while line.points.count > 0 {
                let x = line.lastPoint().column
                let y = line.lastPoint().row
                if line.lastPoint() != line.point1 && line.lastPoint() != line.point2 {
                    gameboard!.gameArray[x, y]!.color = .Unknown
                    //gameboard!.gameArray[x, y]!.originalPoint = false
                }
                gameboard!.gameArray[x, y]!.inLinePoint = false
                line.removeLastPoint()
            }
            line.point1!.inLinePoint = false
            line.point2!.inLinePoint = false
            lineLayers[color]!.removeFromSuperlayer()
            makeNewLayer(color)
            line.lineEnded = false
        }
        //GV.notificationCenter.addObserver(self, selector: "handleMadeMove", name: GV.notificationMadeMove, object: nil)
        GV.lineCount = 0
        GV.moveCount = 0
        if GV.gameControll == .JoyStick || GV.gameControll == .Accelerometer {
            setRandomAktColor()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func setRandomAktColor () {
        
        var colorTab: [LineType]
        colorTab = []
        for index in 0..<GV.lines.count
        {
            let color = LineType(rawValue: (LineType.C1.rawValue + index))!
            if !GV.lines[color]!.lineEnded {
                colorTab.append(color)
            }
        }
        if colorTab.count > 0 {
            var aktX = 0
            var aktY = 0
            let randomColor = colorTab[random(0, max: colorTab.count - 1)]
            if random(0, max: 1) == 0 {
                aktX = GV.lines[randomColor]!.point1!.column
                aktY = GV.lines[randomColor]!.point1!.row
            } else {
                aktX = GV.lines[randomColor]!.point2!.column
                aktY = GV.lines[randomColor]!.point2!.row
            }
            let aktCoordX = CGFloat(aktX) * CGFloat(GV.gameRectSize) + GV.gameRectSize / 2
            let aktCoordY = CGFloat(aktY) * CGFloat(GV.gameRectSize) + GV.gameRectSize / 2
            GV.aktColor = randomColor
            myTouchesBegan(CGPointMake(aktCoordX, aktCoordY))
        }
    }
        
    func random(min: Int, max: Int) -> Int {
        let randomInt = min + Int(arc4random_uniform(UInt32(max + 1 - min)))
        return randomInt
    }

    func handleMadeMove() {
        if notInMove {
            notInMove = false
            let point = CGPointMake(GV.touchPoint.x + GV.speed.width, GV.touchPoint.y + GV.speed.height)
            if myTouchesMoved(point) {
                checkIfGameEnded()
                if GV.lines[aktColor]!.lineEnded {
                    setRandomAktColor()
                }
            }
            notInMove = true
        }
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touchCount = touches.count
        let touch = touches.first as! UITouch
        myTouchesBegan(touch.locationInView(self))
    }
    
    func myTouchesBegan(point: CGPoint) {

        let (OK, x, y) = getXYPositionInGrid(point, inMoving: false)
        if (OK && (gameboard!.gameArray[x, y]!.originalPoint || gameboard!.gameArray[x, y]!.inLinePoint)) {
            startPointX = x
            startPointY = y
            aktColor = gameboard!.gameArray[x, y]!.color
            GV.aktColor = aktColor
            if aktColor != lastColor {
                GV.moveCount++
            }
            GV.lineCount = getEndedLinesCount()
            let lineString = GV.language.getText("lines")
            GV.lineCountLabel.text = "\(GV.lineCount) / \(GV.lines.count) \(lineString)"
            
            if pointLayer != nil {
               pointLayer!.removeFromSuperlayer()
            }
            pointLayer = MyLayer()
            pointLayer!.name = "point"
            pointLayer!.frame = CGRect(origin: self.frame.origin, size: self.frame.size)
        
            pointLayer!.color = aktColor
            self.layer.addSublayer(pointLayer)
            pointLayer!.setNeedsDisplay()
            
            
            gameboard!.gameArray[x, y]!.inLinePoint = true
            let point = gameboard!.gameArray[x, y]!
            let line = GV.lines[aktColor]!
            if line.points.count == 0  { // leer
                line.addPoint(point) // add actuelle Point
            } else {
                deleteEndLine(point, line: line, calledFrom: "touchesBegan")
                line.addPoint(point)
            }
            lineLayers[aktColor]!.setNeedsDisplay()
            if GV.gameControll == .JoyStick || GV.gameControll == .Accelerometer {
                GV.notificationCenter.postNotificationName(GV.notificationColorChanged, object: nil)
                GV.accelerometer.startAccelerometer()
            }
        }
        else {
            startPointX = -1
            startPointY = -1
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if GV.gameControll == .Finger {
            let touchCount = touches.count
            let touch = touches.first as! UITouch
            myTouchesMoved(touch.locationInView(self))
        }
    }


    func myTouchesMoved(point:CGPoint) -> Bool {
        let (OK, x, y) = getXYPositionInGrid(point, inMoving: true)
        if OK && startPointX != -1 && startPointY != -1 {
            
            pointLayer!.setNeedsDisplay()
            
            if x != startPointX || y != startPointY {
                let point: Point = gameboard!.gameArray[x, y]!
                if !((point.originalPoint && point.color != aktColor) || abs(x - startPointX) > 1 || abs(y - startPointY) > 1) {  // can be moved here
                    
                    if point.color != .Unknown && point.color != aktColor  {  // here another line
                        point.earlierColor = point.color
                        deleteEndLine(point,line: GV.lines[point.color]!, calledFrom: "touchesMoved1")  // delete endpart of line, inclusive point
                    }
                    
                    if x != startPointX && y != startPointY {
                        if !gameboard!.gameArray[x, startPointY]!.originalPoint {
                            moved(x, y: startPointY)  // when diagonal, then 2 steps: first left/rigth
                            moved(x, y:y)
                        }
                    } else {
                        moved(x, y: y)
                    }
                    lineLayers[aktColor]!.makeLineForLayer()
                    lineLayers[aktColor]!.setNeedsDisplay()
                    checkIfGameEnded()
                    startPointX = x
                    startPointY = y
                }
            }
            return true
        }
        return false
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if GV.gameControll == .Finger {
            let touchCount = touches.count
            let touch = touches.first as! UITouch
            let point = touch.locationInView(self)
            if pointLayer != nil {
                pointLayer!.removeFromSuperlayer()
            }
            pointLayer = nil
            let (OK, x, y) = getXYPositionInGrid(point, inMoving: true)
            if OK && startPointX != -1 && startPointY != -1 {
                GV.lineCount = getEndedLinesCount()
                
                
                //GV.dataStore.printRecords()
                checkIfGameEnded()
                if aktColor != lastColor {
                    lastColor = aktColor
                }

            }
        }
    }
    
    
    func getXYPositionInGrid(point:CGPoint, inMoving: Bool) -> (Bool, Int, Int) {
        let xPos = point.x - bounds.origin.x
        let yPos = point.y - bounds.origin.y
        let halfGameRectSize = CGFloat(GV.gameRectSize) / 2
        let checkCorrectur = GV.gameControll == .JoyStick || GV.gameControll == .Accelerometer ? CGFloat(GV.gameRectSize) / 2 : 0
        var myTouchPoint = point
        if xPos < checkCorrectur || xPos >= bounds.size.width - checkCorrectur || yPos < checkCorrectur || yPos >= bounds.size.height - checkCorrectur {
            return (false, 0, 0)
        }
        let x = Int(xPos / CGFloat(GV.gameRectSize))
        let y = Int(yPos / CGFloat(GV.gameRectSize))
        if x >= GV.gameSize || y >= GV.gameSize {
            return (false, 0, 0)
        }
        if GV.speed.width == 0 { // moving along Y
            myTouchPoint.x = CGFloat(x) * CGFloat(GV.gameRectSize) + halfGameRectSize
        }
        if GV.speed.height == 0 { // moving along X
            myTouchPoint.y = CGFloat(y) * CGFloat(GV.gameRectSize) + halfGameRectSize
        }
        let newPointColor = gameboard!.gameArray[x, y]!.color
        if inMoving && (newPointColor != self.aktColor && newPointColor != .Unknown)
        {
            //println("returned with oldColor: \(self.aktColor), newColor: \(newPointColor) with speed: \(GV.speed)")
           return (false, 0, 0)
        }
        if x < GV.gameSize && y < GV.gameSize {
            GV.touchPoint = myTouchPoint
            return (true, x, y)
        }
        return (false, 0, 0)
    }
    
    
    func deleteEndLine(aktPoint: Point, line: Line, calledFrom: String) {
        //println("deleteEndLine: caller: \(calledFrom), Color: \(aktPoint.color), lColor: \(line.color), aktColor: \(aktColor)")
        let point = (aktPoint.originalPoint && aktPoint != line.firstPoint()) ? line.firstPoint() : aktPoint
        let lastPoint = line.lastPoint()
        while line.points.count != 0 && line.lastPoint() != point {
            let tempX = line.lastPoint().column
            let tempY = line.lastPoint().row
            if !gameboard!.gameArray[tempX, tempY]!.originalPoint {gameboard!.gameArray[tempX, tempY]!.color = .Unknown}
            gameboard!.gameArray[tempX, tempY]!.inLinePoint = false
            line.lastPoint().layer.removeFromSuperlayer()
            line.lastPoint().layer = CALayer()
            line.lineEnded = false
            line.removeLastPoint()
        }
        //gameboard!.gameArray[line.lastPoint().column, line.lastPoint().row]?.inLinePoint = false
        //println("inLinePoint false at line.lastPoint().column: \(line.lastPoint().column), line.lastPoint().row]: \(line.lastPoint().row)")
        
        line.removeLastPoint()
    }
    
    func moved(x: Int, y:Int) {
        let point = gameboard!.gameArray[x, y]!
        //println("point.lineEnded:\(GV.lines[aktColor]!.lineEnded)")
        if GV.lines[aktColor]!.pointInLine(point) {
            deleteEndLine(point, line: GV.lines[aktColor]!, calledFrom: "moved")
            //println("deletePoint: x-\(x), y-\(y)")
        }
        if !GV.lines[aktColor]!.lineEnded {
            //println("addPoint: x-\(x), y-\(y)")
            gameboard!.gameArray[x, y]!.color = aktColor
            gameboard!.gameArray[x, y]!.inLinePoint = true
            GV.lines[aktColor]!.addPoint(gameboard!.gameArray[x, y]!)
        }
        lineLayers[aktColor]!.setNeedsDisplay()
    }
    
    func checkIfGameEnded () -> Bool {
        var completed = false
        if !alertPresented {
            completed = true
            var gameEndAlert:UIAlertController?
            var messageTxt = ""
            var titleText = ""
            var stopText = ""
            for (color, line) in GV.lines {
                if !line.lineEnded {return false}
            }
            alertPresented = true
            
            for column in 0..<GV.gameSize {
                for row in 0..<GV.gameSize {
                    if gameboard!.gameArray[column, row]!.color == .Unknown {
                        completed = false
                    }
                }
            }
            
            GV.timeAdder = 0
            nextLevel = false
            alertNotReady = true
            
            if completed {
                if GV.gameControll == .JoyStick || GV.gameControll == .Accelerometer {
                    GV.moveCount++
                }
                var gameData = GameData()
                gameData.gameName = GV.package!.getVolumeName(GV.volumeNr) as String
                gameData.gameNumber = GV.gameNr
                gameData.countLines = GV.lines.count
                gameData.countMoves = GV.moveCount
                gameData.countSeconds = GV.timeCount
                
                GV.dataStore.updateRecord(gameData)
                
                completed = true
                titleText = GV.language.getText("task completed")
                stopText = "stop"
                if GV.moveCount == GV.lines.count {
                    messageTxt = GV.language.getText("congratulations")
                }
                messageTxt += GV.language.getText("task solved",par:"\(GV.moveCount)", "\(GV.timeCount)")

            } else {
                titleText = GV.language.getText("task not completed")
                messageTxt = GV.language.getText("fill the board")
                var gameData = GameData()
                stopText = "continue"
                gameData.gameName = GV.package!.getVolumeName(GV.volumeNr) as String
                gameData.gameNumber = GV.gameNr
                GV.dataStore.updateRecord(gameData)
            }

            pointLayer!.removeFromSuperlayer()
            GV.notificationCenter.postNotificationName(GV.notificationColorChanged, object: nil) // Joystick / Accelerometer reset

            gameEndAlert = UIAlertController(title: titleText,
                message: messageTxt,
                preferredStyle: .Alert)
            
            let firstAction = UIAlertAction(title: GV.language.getText("next level"),
                style: UIAlertActionStyle.Default,
                handler: {(paramAction:UIAlertAction!) in
                    GV.notificationCenter.postNotificationName(GV.notificationColorChanged, object: nil)
                    GV.notificationCenter.removeObserver(self)
                    self.gameEnded(true)
                }
            )
            
            let secondAction = UIAlertAction(title: GV.language.getText(stopText),
                style: UIAlertActionStyle.Cancel,
                handler: {(paramAction:UIAlertAction!) in
                    self.alertPresented = false
                    //GV.notificationCenter.addObserver(self, selector: "handleJoystickMoved", name: GV.notificationJoystickMoved, object: nil)
                }
                

            )
            
            if GV.gameControll == GameControll.Accelerometer {
                GV.accelerometer.stopAccelerometer()
            }
            gameEndAlert!.addAction(firstAction)
            gameEndAlert!.addAction(secondAction)
            parent.presentViewController(gameEndAlert!,
                animated:true,
                completion: nil)
        }
        return completed
    }
    
    func getEndedLinesCount() -> Int{
        var count = 0
        for index in 0..<GV.lines.count {
            count += GV.lines[LineType(rawValue: (LineType.C1.rawValue + index))!]!.lineEnded ? 1 : 0

        }
       //println("aktColor: \(aktColor), count:\(count)")
        return count
    }

}
