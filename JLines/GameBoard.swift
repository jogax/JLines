//
//  GameBoard.swift
//  JLinesV1
//
//  Created by Jozsef Romhanyi on 12.03.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import Foundation

struct LowValues: Hashable {
    var tuple: (x:Int, y:Int)
    var hashValue: Int {
        return tuple.x * 100 + tuple.y
    }
}
func ==(lhs: LowValues, rhs: LowValues) -> Bool {
    return lhs.tuple.x == rhs.tuple.x && lhs.tuple.y == rhs.tuple.y
}

struct Member: Hashable {
    var x: Int
    var y: Int
    var checked: Bool
    var endPoint: Bool
    var hashValue: Int {
        return x * 100 + y
    }
}

func ==(lhs: Member, rhs: Member) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}



class GameBoard {
    struct Area {
        var points:Array<Member>
        var hasEndPoints: Bool
        var countEndPoints: Int
        var countNotCheckedMembers: Int
        
        init () {
            points = Array<Member>()
            countNotCheckedMembers = 0
            hasEndPoints = false
            countEndPoints = 0
        }
    }

    
    var gameArray: Array2D<Point>
    //var directions: Array2D<Directions>
    var tempGameArray: Array2D<Point>?
    //var tempDirections: Array2D<Directions>?
    var lowCountDirections = Array<(x:Int, y:Int)>()
    //var lowValuesIndex: Int = 0
    var numEmptyPoints: Int
    //var lines: [LineType:Line]
    var numColors: Int = 0
    var countMoves: Int = 0
    var areas = [Int:Area]()
    var areaNr = 0
    let minLength = 4
    var debugging = GV.debugging
    
    
    init (gameArray: Array2D<Point>, lines: [LineType:Line],  numColors: Int) {
        
        self.numColors = numColors
        self.gameArray = gameArray
        GV.lines = lines
        self.numEmptyPoints = GV.gameSize * GV.gameSize
        
    }
    
    init () {
        let minMaxColorCount = [ // Key: gameSize, worth: min & max count of colors
            5:(4, 5),
            6:(4, 6),
            7:(5, 8),
            8:(6, 9),
            9:(6, 10)
        ]
        var (minColorCount, maxColorCount) = minMaxColorCount[GV.gameSize]!
        self.gameArray =  Array2D<Point>(columns:GV.gameSize, rows: GV.gameSize)
        //self.directions = Array2D<Directions>(columns:GV.gameSize, rows: GV.gameSize)
        self.numEmptyPoints = GV.gameSize * GV.gameSize
        
        GV.lines = [LineType:Line]()
        printFunction("GameBoard.init()")
        numColors = random(minColorCount, max: maxColorCount, comment: "wähle Anzahl colors")
        let startTime = NSDate()
        (gameArray, GV.lines) = generateGameArrayExtended()
        removeLinesFromGameboard()
        printGeneratedLine()
        let currentTime = NSDate()
        let elapsedTime = currentTime.timeIntervalSinceDate(startTime) * 1000 / 1000
        //println("Time für Generierung von Gameboard:\(elapsedTime) sec")

    }

    
    func generateGameArray() -> (Array2D<Point>, [LineType:Line]) {
        printFunction("generateGameArray()")

        //let countColors = LineType.LastColor.rawValue - 1
        tempGameArray = Array2D<Point>(columns: GV.gameSize, rows: GV.gameSize)
        //tempDirections = Array2D<Directions>(columns: GV.gameSize, rows: GV.gameSize)
      
        for column in 0..<GV.gameSize {  // empty Array generieren
            for row in 0..<GV.gameSize {
                tempGameArray![column, row] = Point(column: column, row: row, type: LineType.Unknown, originalPoint: false, inLinePoint: false, delegate: checkDirections)
            }
        }
        //lowCountDirections = [Int:Array<(x:Int, y:Int)>]()
        checkDirections()
        //analyzeGameboard()

        var lines = [LineType:Line]()
        var x1 = 0
        var y1 = 0
        var x2 = 0
        var y2 = 0
        var line: Line
        
        //var repeat = false
        
        var deleted = false
        var ind = 0
        var toContinue = false
        //for ind in 0..<self.numColors {
        //for ind in 0..<2 
        do {
            let color = LineType(rawValue: (LineType.C1.rawValue + ind))!
            let startTime = NSDate()
            
            
            (x1, y1) = getRandomPoint()
            
            do {
                tempGameArray![x1, y1]!.color = color
                tempGameArray![x1, y1]!.originalPoint = true
                tempGameArray![x1, y1]!.inLinePoint = true
                lines[color] = generateLineFromPoint(x1, y: y1, color: color)
                deleted = deleteLineIfRequired(color)
            } while deleted
        
            let currentTime = NSDate()
            let elapsedTime = currentTime.timeIntervalSinceDate(startTime) * 1000 / 1000
            //println("laufTime:\(elapsedTime) sec für \(color)")
            ind++
            toContinue = (ind < self.numColors && self.numEmptyPoints != 0) || self.numEmptyPoints != 0
        } while toContinue

        
        GV.gameNr++
        return (tempGameArray!, lines)
        
    }

    func removeLinesFromGameboard() {
        for index in 0..<GV.lines.count
        {
            let color = LineType(rawValue: (LineType.C1.rawValue + index))!
            let line = GV.lines[color]!
            while line.points.count > 0 {
                let x = line.lastPoint().column
                let y = line.lastPoint().row
                if line.lastPoint() != line.point1 && line.lastPoint() != line.point2
                {
                    tempGameArray![x, y]!.color = .Unknown
                    tempGameArray![x, y]!.originalPoint = false
                }
                tempGameArray![x, y]!.inLinePoint = false
                line.removeLastPoint()
            }
            line.point1!.inLinePoint = false
            line.point2!.inLinePoint = false
        }
    }
    
    func printGeneratedLine() {
        if GV.printGeneratedLine {
            print ("{\"lineCount\": \(GV.lines.count), \"lines\":[")
            for index in 0..<GV.lines.count
            {
                let color = LineType(rawValue: (LineType.C1.rawValue + index))!
                let line = GV.lines[color]!
                let pos1 = line.point1!.row * GV.gameSize + line.point1!.column
                let pos2 = line.point2!.row * GV.gameSize + line.point2!.column
                if index > 0 {
                    print(",")
                }
                print("{\"P1\":\(pos1),\"P2\":\(pos2)}")
            }
            print("]},")
            println()
        }
    }
    
    func random(min: Int, max: Int, comment: String) -> Int {
        let randomInt = min + Int(arc4random_uniform(UInt32(max + 1 - min)))
        printFunction("random(min: \(min), max: \(max)) -> \(randomInt), comment: \(comment)")
        return randomInt
    }
    
    func getRandomPoint () -> (Int, Int) {
        var randomSet: [(x:Int, y:Int)]
        randomSet = []
        

        var area = areas[self.areaNr]!
        for (index, member) in enumerate(area.points) {
            if !area.hasEndPoints || area.points[index].endPoint {
                let x = area.points[index].x
                let y = area.points[index].y
                randomSet.append(x: x, y: y)
            }

        }
        let randomWert = randomSet[random(0, max: randomSet.count - 1, comment: "generiere Point")]
        printFunction("getRandomPoint () -> \(randomWert)")

        return randomWert
    }
    
    func generateLineFromPoint(x: Int, y: Int, color:LineType) -> Line {
        printFunction("generateLineFromPoint(x: \(x), y: \(y), color:\(color))")
        /*
        println("arrays:\(areas.count)")
        for ind in 0..<areas.count {
            println("areas[ind].count:\(areas[ind]!.points.count)")
        }
        */
        let line = Line(lineType: color)
        let left =  0
        let up =    1
        let right = 2
        let down =  3
        
        var leftUpRightDown = random(Int(left), max: Int(down), comment: "wähle Direction")
        var blockedX = GV.gameSize
        var blockedY = GV.gameSize
        
        while line.length < 3 {
            //let point = Point(column: x, row: y, type: color, originalPoint: true, inLinePoint: true, size:GV.gameSize, delegate: checkDirections)
            //line.point1 = point
            //line.point2 = point
            line.point1 = tempGameArray![x, y]!
            line.point2 = line.point1
            line.addPoint(line.point1!)
            //println("color: \(color), line.count: \(line.length), aktX: \(x), aktY:\(y)")

            let emptyPointsCount = areas[areaNr]!.points.count  // nehme die 1st area
            
            var otherEmptyPointsCount = 0
            otherEmptyPointsCount = numEmptyPoints - emptyPointsCount
            
            var lineLength = 0
            var restLinesCount = numColors - GV.lines.count
            var areasCount = areas.count
            var averageLength = 0
            if restLinesCount > 0 {
                averageLength = emptyPointsCount / restLinesCount
            } else {
                averageLength = 3
            }
            var possibleLengths = [Int]()
            for i in 0..<6 {
                if averageLength - 3 + i > 2 {
                    possibleLengths.append(averageLength - 3 + i)
                    if i == 3 {
                        possibleLengths.append(averageLength - 3 + i)
                    }
                }
            }
            
            if emptyPointsCount < 6 || restLinesCount == 1 || areasCount == restLinesCount {
                lineLength = emptyPointsCount + 1
            } else {
                if emptyPointsCount >  9 {
                    //lineLength = random(3, max: emptyPointsCount - (restLinesCount - areasCount) * 3, comment: "wähle Linelenght")
                    lineLength = possibleLengths[random(0, max: possibleLengths.count - 1, comment: "wähle Linelenght")]
                } else {
                    lineLength = 3
                }
            }
            var aktX: Int = x
            var aktY: Int = y
            
            while line.length < lineLength {
                var randomSet: [(x:Int, y:Int)]
                randomSet = []
                var cnt = 0
                while randomSet.count == 0 && cnt <= 3 {
                    switch leftUpRightDown {
                    case left:
                        if aktX > 0 && tempGameArray![aktX - 1, aktY]!.color == .Unknown && tempGameArray![aktX - 1, aktY]!.areaNumber == areaNr && (aktX - 1 != blockedX || aktY != blockedY) {
                                let setX = aktX - 1
                                let setY = aktY
                                randomSet.append(x: setX, y: setY)
                        }
                    case right:
                        if aktX < GV.gameSize - 1 && tempGameArray![aktX + 1, aktY]!.color == .Unknown && tempGameArray![aktX + 1, aktY]!.areaNumber == areaNr  && (aktX + 1 != blockedX || aktY != blockedY) {
                            let setX = aktX + 1
                            let setY = aktY
                            randomSet.append(x: setX, y: setY)
                        }
                    case up:
                        if aktY > 0 && tempGameArray![aktX, aktY - 1]!.color == .Unknown && tempGameArray![aktX, aktY - 1]!.areaNumber == areaNr && (aktX != blockedX || aktY - 1 != blockedY) {
                            let setX = aktX
                            let setY = aktY - 1
                            randomSet.append(x: setX, y: setY)
                        }
                    default: //down
                        if aktY < GV.gameSize - 1 && tempGameArray![aktX, aktY + 1]!.color == .Unknown && tempGameArray![aktX, aktY + 1]!.areaNumber == areaNr && (aktX != blockedX || aktY + 1 != blockedY) {
                            let setX = aktX
                            let setY = aktY + 1
                            randomSet.append(x: setX, y: setY)}
                    }
                    if randomSet.count == 0 {
                        if ++leftUpRightDown > down {leftUpRightDown = 0}
                        cnt++
                    }
                }
                
                blockedX = GV.gameSize  //entBlocking
                blockedY = GV.gameSize
                if randomSet.count == 0 {
                    lineLength = line.length
                } else {
                    (aktX, aktY) = randomSet[random(0, max: randomSet.count - 1, comment: "wähle next Point in Line aus Randomset")]
                    let oldAreasCount = areas.count
                    var tooShortCount = 0
                    tempGameArray![aktX, aktY]!.color = color
                    if areas.count != oldAreasCount {
                        for ind in 0..<areas.count {
                            if areas[ind]!.points.count < 3 || areas[ind]!.countEndPoints == 3  {
                                tooShortCount++
                            }
                        }
                    }
                    if tooShortCount == 1 {
                        lineLength = line.length + areas[areaNr]!.points.count + 1
                    }
                    if tooShortCount > 1 {
                        tempGameArray![aktX, aktY]!.color = .Unknown
                        if tempGameArray![aktX, aktY]!.directions.countDirections > 1 {
                            blockedX = aktX // wenn mehrere Richtungen, dann wähle andere Richtung
                            blockedY = aktY
                            aktX = line.lastPoint().column
                            aktY = line.lastPoint().row
                        } else {
                            tempGameArray![aktX, aktY]!.color = color // Problem anders lösen
                        }
                    }
                    if blockedX == GV.gameSize {
                        tempGameArray![aktX, aktY]!.inLinePoint = true
                        line.point2 = Point(column: aktX, row: aktY, type: color, originalPoint: false, inLinePoint: true, delegate: checkDirections )
                        //println("color: \(color), line.count: \(line.length), aktX: \(aktX), aktY:\(aktY)")
                        line.addPoint(tempGameArray![aktX, aktY]!)
                        //printGameboard()
                        self.numEmptyPoints = countEmptyPoints()
                    }
                }
            }
            /*
            for ind in 1..<line.length{
                line.points[ind].originalPoint = false
                let x = line.points[ind].column
                let y = line.points[ind].row
                
                tempGameArray![x, y]!.originalPoint = false
            }
            */
            line.point2!.originalPoint = true
            let x2 = line.point2!.column
            let y2 = line.point2!.row
            line.firstPoint().originalPoint = true
            line.lastPoint().originalPoint = true
            tempGameArray![x2, x2]!.originalPoint = true
            //println("point1: \(line.point1), point2: \(line.point2), countEmptyPoints: \(self.countEmptyPoints)")
            printGameboard()
/*
            for ind in 0..<areas.count {
                if areas[ind]!.points.count < 3 || areas[ind]!.countEndPoints == 3  {//> 2 && areas[ind]!.points.count < 6) { //zu kurze Area or zu viele EndPoints --> line weglöschen!
                    while line.points.count > 2 {
                        let x = line.lastPoint().column
                        let y = line.lastPoint().row
                        tempGameArray![x, y]!.clearPoint()
                        line.removeLastPoint()
                        //printGameboard()
                    }
                }
            }
*/
        }
        
        GV.lines[color] = line
        return GV.lines[color]!
    }
    
    func deleteLineIfRequired(color: LineType) -> Bool {
        printFunction("deleteLineIfRequired(color: \(color))")
        let line = GV.lines[color]!
        var toDelete = false
        for ind in 0..<areas.count {
            if areas[ind]!.points.count < 3 || areas[ind]!.countEndPoints == 3  {//> 2 && areas[ind]!.points.count < 6) { //zu kurze Area or zu viele EndPoints --> line weglöschen!
                toDelete = true
            }
        }
        if toDelete {
            while line.points.count > 0 {
                let x = line.lastPoint().column
                let y = line.lastPoint().row
                tempGameArray![x, y]!.clearPoint()
                line.removeLastPoint()
                analyzeGameboard()
                printGameboard()
            }
            GV.lines.removeValueForKey(color)
        }
        numEmptyPoints = countEmptyPoints()
        return toDelete

    }
    func printGameboard() {
        if debugging {
            printFunction("printGameboard()")
            var lineString = "+"
            for i in 0..<GV.gameSize {lineString += "---+"}
            println (lineString)
            for y in 0..<GV.gameSize {
                var printString = "| "
                for x in 0..<GV.gameSize {
                    var p: String
                    p = tempGameArray![x, y]!.color.colorAbbr.lowercaseString
                    if tempGameArray![x, y]!.originalPoint {
                        p = p.uppercaseString
                    }
                    printString += p + " | "
                }
                println("\(printString)")
                println("\(lineString)")
            }
        }
    }
    
    func analyzeGameboard() {
        let startTime = NSDate()
        printFunction("analyzeGameboard()")
        self.areas = [Int:Area]()
        var area = Area()
        for x in 0..<GV.gameSize {
            for y in 0..<GV.gameSize {
                tempGameArray![x, y]!.areaNumber = -1
            }
        }
        var areaNumber = 0
        var minAreaLength = 1000
        for x in 0..<GV.gameSize {
            for y in 0..<GV.gameSize {
                if tempGameArray![x, y]!.color == .Unknown &&
                tempGameArray![x, y]!.areaNumber == -1 {
                    area.points.append(Member(x: x, y: y, checked: false, endPoint: false))
                    tempGameArray![x, y]!.areaNumber = areaNumber
                    area.countNotCheckedMembers++
                    while area.countNotCheckedMembers > 0 {
                        for (index, member) in enumerate(area.points) {
                            if !member.checked {
                                let x = member.x
                                let y = member.y
                                if tempGameArray![x, y]!.directions.left > 0 &&
                                    tempGameArray![x - 1, y]!.color == .Unknown &&
                                    tempGameArray![x - 1, y]!.areaNumber == -1 {
                                    
                                    tempGameArray![x - 1, y]!.areaNumber = areaNumber
                                    area.points.append(Member(x: x - 1, y: y, checked: false, endPoint: false))
                                    area.countNotCheckedMembers++
                                }
                                if tempGameArray![x, y]!.directions.right > 0 &&
                                    tempGameArray![x + 1, y]!.color == .Unknown &&
                                    tempGameArray![x + 1, y]!.areaNumber == -1 {
                                        
                                    tempGameArray![x + 1, y]!.areaNumber = areaNumber
                                    area.points.append(Member(x: x + 1, y: y, checked: false, endPoint: false))
                                    area.countNotCheckedMembers++
                                }
                                if tempGameArray![x, y]!.directions.up > 0 &&
                                    tempGameArray![x, y - 1]!.color == .Unknown &&
                                    tempGameArray![x, y - 1]!.areaNumber == -1 {

                                    tempGameArray![x, y - 1]!.areaNumber = areaNumber
                                    area.points.append(Member(x: x, y: y - 1, checked: false, endPoint: false))
                                    area.countNotCheckedMembers++
                                }
                                if tempGameArray![x, y]!.directions.down > 0 &&
                                    tempGameArray![x, y + 1]!.color == .Unknown &&
                                    tempGameArray![x, y + 1]!.areaNumber == -1 {
                                    
                                    tempGameArray![x, y + 1]!.areaNumber = areaNumber
                                    area.points.append(Member(x: x, y: y + 1, checked: false, endPoint: false))
                                    area.countNotCheckedMembers++
                                }
                                if tempGameArray![x, y]!.directions.countDirections == 1 {
                                    area.hasEndPoints = true
                                    area.countEndPoints++
                                    area.points[index].endPoint = true
                                }
                                area.points[index].checked = true
                                area.countNotCheckedMembers--
                                //println("index: \(index), x: \(x), y:\(y), notChecked: \(area.countNotCheckedMembers), areaNumber: \(areaNumber)")
                            }
                        }
                    }
                    self.areas[areaNumber] = area
                    if minAreaLength > area.points.count {
                        minAreaLength = area.points.count
                        self.areaNr = areaNumber
                    }
                    //printGameboard()
                    area = Area()
                    areaNumber++
                }
                
            }
        }
        let currentTime = NSDate()
        let elapsedTime = currentTime.timeIntervalSinceDate(startTime) * 1000
        if GV.debuggingTime {println("analyzeGameboard elapsedTime:\(elapsedTime) ms")}
    }

    func checkDirections(x: Int, y: Int) {
        printFunction("checkDirections(x: \(x), y: \(y))")
        checkDirections()

        var startTime = NSDate()
        var pointer = lowCountDirections.count
        if let point = tempGameArray![x, y] {
            if point.color == .Unknown {
                checkDirections()
            } else {
                var columnLeft: Int = x - 1
                tempGameArray![x, y]!.clearDirections()
                while columnLeft >= 0 && tempGameArray![columnLeft, y]!.color == .Unknown {
                    tempGameArray![columnLeft, y]!.directions.right = x - columnLeft - 1
                    tempGameArray![columnLeft, y]!.countDirections()
                    columnLeft--
                }
                var columnRight = x + 1
                tempGameArray![x, y]!.directions.right = 0
                while columnRight < GV.gameSize && tempGameArray![columnRight, y]!.color == .Unknown {
                    tempGameArray![columnRight, y]!.directions.left = columnRight - x - 1
                    tempGameArray![columnRight, y]!.countDirections()
                    columnRight++
                }
                var rowUp = y - 1
                tempGameArray![x, y]!.directions.up = 0
                while rowUp >= 0 && tempGameArray![x, rowUp]!.color == .Unknown {
                    tempGameArray![x, rowUp]!.directions.down = y - rowUp - 1
                    tempGameArray![x, rowUp]!.countDirections()
                    rowUp--
                }
                var rowDown = y + 1
                tempGameArray![x, y]!.directions.down = 0
                while rowDown < GV.gameSize && tempGameArray![x, rowDown]!.color == .Unknown {
                    tempGameArray![x, rowDown]!.directions.up = rowDown - y - 1
                    tempGameArray![rowDown, y]!.countDirections()
                    rowDown++
                }
                analyzeGameboard()
                printGameboard()
            }
        }
        let currentTime = NSDate()
        let elapsedTime = currentTime.timeIntervalSinceDate(startTime) * 1000
        if GV.debuggingTime {println("checkDirections elapsedTime:\(elapsedTime) ms")}

    }
    
    func checkDirections() {
        printFunction("checkDirections()")
        var startTime = NSDate()
        if let point = tempGameArray![0, 0] {
            var lowCountDir = Array<(x:Int, y:Int)>()
            for x in 0..<GV.gameSize {
                for y in 0..<GV.gameSize {
                    var dir = Directions()
                    if tempGameArray![x, y]!.color != .Unknown {
                        tempGameArray![x, y]!.directions = dir
                    } else {
                        if x > 0 {
                            var col = x - 1
                            while col >= 0 && tempGameArray![col, y]!.color == .Unknown {
                                col--
                                dir.left++
                            }
                        }
                        
                        if x < GV.gameSize - 1 {
                            var col = x + 1
                            while col <= GV.gameSize - 1 && tempGameArray![col, y]!.color == .Unknown {
                                col++
                                dir.right++
                            }
                        }
                        
                        if y > 0 {
                            var row = y - 1
                            while row >= 0 && tempGameArray![x, row]!.color == .Unknown {
                                row--
                                dir.up++
                            }
                        }

                        if y < GV.gameSize - 1 {
                            var row = y + 1
                            while row <= GV.gameSize - 1 && tempGameArray![x, row]!.color == .Unknown {
                                row++
                                dir.down++
                            }
                        }
                        dir.count = dir.left + dir.right + dir.up + dir.down
                        dir.countDirections = dir.left > 0 ? 1 : 0
                        dir.countDirections += dir.right > 0 ? 1 : 0
                        dir.countDirections += dir.up > 0 ? 1 : 0
                        dir.countDirections += dir.down > 0 ? 1 : 0
                        if dir.countDirections < 2 {
                            lowCountDir.append(x: x, y: y)
                        }
                        tempGameArray![x, y]!.directions = dir
                    }
                }
            }
            self.lowCountDirections = lowCountDir
            analyzeGameboard()
        }
        let currentTime = NSDate()
        let elapsedTime = currentTime.timeIntervalSinceDate(startTime)
        //println("elapsedTime:\(elapsedTime)")


    }

    func countEmptyPoints() -> Int {
        printFunction("countEmptyPoints()")
        var count = 0
        for x in 0..<GV.gameSize {
            for y in 0..<GV.gameSize {
                if tempGameArray![x, y]!.color == .Unknown {
                    count++
                }
            }
        }
        return count
    }
    func printFunction(funcName:String) {
        if GV.debuggingFunctions {
            println("Function: \(funcName)")
        }
    }
}


func ==(lhs: (x: Int, y: Int), rhs: (x:Int, y:Int)) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

