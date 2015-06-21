//
//  GameBoard.swift
//  JLinesV1
//
//  Created by Jozsef Romhanyi on 12.03.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import Foundation

extension GameBoard {
    
    func generateGameArrayExtended() -> (Array2D<Point>, [LineType:Line]) {
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
            
            
            do {
                (x1, y1) = getRandomPoint()
            
                tempGameArray![x1, y1]!.color = color
                tempGameArray![x1, y1]!.originalPoint = true
                tempGameArray![x1, y1]!.inLinePoint = true
                lines[color] = generateLineFromPointExtended(x1, y: y1, color: color)
                deleted = deleteLineIfRequiredExtended(color)
            } while deleted
            
            let currentTime = NSDate()
            let elapsedTime = currentTime.timeIntervalSinceDate(startTime) * 1000 / 1000
            //println("laufTime:\(elapsedTime) sec für \(color)")
            ind++
            toContinue = (ind < self.numColors && self.numEmptyPoints != 0) || self.numEmptyPoints != 0
        } while toContinue
/*
        print ("{\"lineCount\": \(lines.count), \"lines\":[")
        for index in 0..<lines.count
        {
            let color = LineType(rawValue: (LineType.C1.rawValue + index))!
            let line = lines[color]!
            while line.points.count > 0 {
                let x = line.lastPoint().column
                let y = line.lastPoint().row
                if line.lastPoint() != line.point1 && line.lastPoint() != line.point2 {
                    tempGameArray![x, y]!.color = .Unknown
                    tempGameArray![x, y]!.originalPoint = false
                }
                tempGameArray![x, y]!.inLinePoint = false
                line.removeLastPoint()
            }
            line.point1!.inLinePoint = false
            line.point2!.inLinePoint = false
            //   {"lineCount":5, "lines":[{"P1":23, "P2":03},{"P1":24, "P2":04},{"P1":12, "P2":22},{"P1":10, "P2":02},{"P1":7, "P2":15}
            let pos1 = line.point1!.row * GV.gameSize + line.point1!.column
            let pos2 = line.point2!.row * GV.gameSize + line.point2!.column
            if index > 0 {print(",")}
            print("{\"P1\":\(pos1),\"P2\":\(pos2)}")
            
        }
        print("]},")
        //println()
        //GV.gameNr++
*/
        return (tempGameArray!, lines)
        
    }
    
    func generateLineFromPointExtended(x: Int, y: Int, color:LineType) -> Line {
        printFunction("generateLineFromPoint(x: \(x), y: \(y), color:\(color))")
        /*
        //println("arrays:\(areas.count)")
        for ind in 0..<areas.count {
        //println("areas[ind].count:\(areas[ind]!.points.count)")
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
        
        while line.length < minLength {
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
                averageLength = emptyPointsCount
            }
            var possibleLengths = [Int]()
            for i in 0..<6 {
                if averageLength - minLength + i > 3 {
                    possibleLengths.append(averageLength - minLength + i)
                    if i == minLength {
                        possibleLengths.append(averageLength - minLength + i)
                    }
                }
            }
            
            if emptyPointsCount < 8 || restLinesCount == 1 || areasCount == restLinesCount {
                lineLength = emptyPointsCount + 1
            } else {
                if emptyPointsCount >  9 {
                    //lineLength = random(3, max: emptyPointsCount - (restLinesCount - areasCount) * 3, comment: "wähle Linelenght")
                    lineLength = possibleLengths[random(0, max: possibleLengths.count - 1, comment: "wähle Linelenght")]
                } else {
                    lineLength = minLength
                }
            }
            var aktX: Int = x
            var aktY: Int = y
            
            while line.length < lineLength {
                var randomSet: [(x:Int, y:Int)]
                randomSet = []
                var cnt = 0
                while randomSet.count == 0 && cnt <= minLength {
//                    switch leftUpRightDown {
//                    case left:
                        if aktX > 0 && tempGameArray![aktX - 1, aktY]!.color == .Unknown && tempGameArray![aktX - 1, aktY]!.areaNumber == areaNr && (aktX - 1 != blockedX || aktY != blockedY) {
                            let setX = aktX - 1
                            let setY = aktY
                            randomSet.append(x: setX, y: setY)
                        }
//                    case right:
                        if aktX < GV.gameSize - 1 && tempGameArray![aktX + 1, aktY]!.color == .Unknown && tempGameArray![aktX + 1, aktY]!.areaNumber == areaNr  && (aktX + 1 != blockedX || aktY != blockedY) {
                            let setX = aktX + 1
                            let setY = aktY
                            randomSet.append(x: setX, y: setY)
                        }
//                    case up:
                        if aktY > 0 && tempGameArray![aktX, aktY - 1]!.color == .Unknown && tempGameArray![aktX, aktY - 1]!.areaNumber == areaNr && (aktX != blockedX || aktY - 1 != blockedY) {
                            let setX = aktX
                            let setY = aktY - 1
                            randomSet.append(x: setX, y: setY)
                        }
//                    default: //down
                        if aktY < GV.gameSize - 1 && tempGameArray![aktX, aktY + 1]!.color == .Unknown && tempGameArray![aktX, aktY + 1]!.areaNumber == areaNr && (aktX != blockedX || aktY + 1 != blockedY) {
                            let setX = aktX
                            let setY = aktY + 1
                            randomSet.append(x: setX, y: setY)}
//                    }
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
    
    func deleteLineIfRequiredExtended(color: LineType) -> Bool {
        printFunction("deleteLineIfRequired(color: \(color))")
        let line = GV.lines[color]!
        var toDelete = false
        for ind in 0..<areas.count {
            if areas[ind]!.points.count <= minLength || areas[ind]!.countEndPoints == 3 {//> 2 && areas[ind]!.points.count < 6) { //zu kurze Area or zu viele EndPoints --> line weglöschen!
                toDelete = true
            }
        }
        
        if line.point1 == line.point2 {
            toDelete = true
        }
        if line.length < 6 && (line.point1!.column == line.point2!.column || line.point1?.row == line.point2?.row) && GV.lines.count < numColors {
            toDelete = true
        }
        /*
        if line.point1!.column == line.point2!.column || line.point1!.row == line.point2!.row {
            let countLines = GV.lines.count
            let checkLineHor = line.point1!.row == line.point2!.row
            let minColumn = min(line.point1!.column, line.point2!.column)
            let maxColumn = max(line.point1!.column, line.point2!.column)
            let minRow = min(line.point1!.row, line.point2!.row)
            let maxRow = max(line.point1!.row, line.point2!.row)
            var checkOK:Bool = false
            var index = 0
            while index < GV.lines.count && !checkOK {
                let otherColor = LineType(rawValue: (index + 1))!
                let otherMinColumn = min(GV.lines[otherColor]!.point1!.column, GV.lines[otherColor]!.point2!.column)
                let othermaxColumn = max(GV.lines[otherColor]!.point1!.column, GV.lines[otherColor]!.point2!.column)
                let otherMinRow = min(GV.lines[otherColor]!.point1!.row, GV.lines[otherColor]!.point2!.row)
                let othermaxRow = max(GV.lines[otherColor]!.point1!.row, GV.lines[otherColor]!.point2!.row)
                
                if otherColor != color {
                    if checkLineHor && otherMinRow <= minRow && othermaxRow >= maxRow && otherMinColumn >= minColumn && othermaxColumn <= maxColumn {
                        checkOK = true
                    }
                    if !checkLineHor && otherMinColumn <= minColumn && othermaxColumn >= maxColumn && otherMinRow >= minRow && othermaxRow <= maxRow {
                        checkOK = true
                    }
                }
                index++
            }
            if !checkOK {
                toDelete = true
            }
        }
*/
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
}




