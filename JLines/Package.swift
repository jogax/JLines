//
//  Package.swift
//  JLinesV1
//
//  Created by Jozsef Romhanyi on 11.02.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import UIKit



class Package {
    
    var moves: Int
    var time: Int
    var squereSize: Int
    var gameName: String
    var package: Dictionary<String, AnyObject>?
    var spiele: AnyObject?
    var aktSpiel: AnyObject?
    var packageVolumes: AnyObject?
    
    var volumeName: String?
    var json: JSON?
    
    
    
    
    let BrettSize = 12
    
    init(packageName: String) {
        
        moves = 0
        time = 0
        squereSize = 0
        gameName = ""
        



        let (package, data) = Dictionary<String, AnyObject>.loadJSONFromBundle(packageName)
        json = JSON(data: data!)
        
        if let packageName = json!["packageName"].string {
            //println("\(packageName)")
        }
        if json != nil {
            
            GV.maxVolumeNr = (json!["volumeCount"].int)!
            packageVolumes = package!["packageVolume"]
            
            
        }
    }
    
    
    func getVolumeName (volumeNumber: Int) -> NSString {
        let gameName = json!["packageVolume"][volumeNumber]["gameName"].string
        return gameName!
    }
    
    func getGameSize (volumeNr: Int) -> Int {
        let gameSize = json!["packageVolume"][volumeNr]["size"].int!
        return gameSize
    }
    
    func getMaxNumber(volumeNr: Int) -> Int {
        var number: Int = 1
        var testWert: Int?
        do {
            testWert = json!["packageVolume"][volumeNr]["games"][number++]["lineCount"].int
        } while testWert != nil
        return number - 1
    }
    
    func getLineCount(volumeNr: Int, numberIn: Int) -> Int {
        return json!["packageVolume"][volumeNr]["games"][numberIn]["lineCount"].int!
    }

    func getGameNew (volumeNr: Int, numberIn: Int) -> (Bool, Int, Array2D<Point>, String, [LineType:Line]) {
        var number = numberIn
        let squereSize = json!["packageVolume"][volumeNr]["size"].int!
        let colorCount = 3
        var spielArray =  Array2D<Point>(columns:squereSize, rows: squereSize)
        for column in 0..<squereSize {
            for row in 0..<squereSize {
                let point = Point(column: column, row: row, type: .Unknown, originalPoint: false, inLinePoint: false, delegate: checkDirections)
                spielArray[column, row] = point
            }
        }
        
        var error = ""
        
        //var lineArray = [Line](count: squereSize, repeatedValue: nil)
        var lines = [LineType:Line]()
        
        let testWert = json!["packageVolume"][volumeNr]["games"][number]["lineCount"].int
        if testWert == nil {return (false, 0, spielArray, error, lines)}
        let lineCount = testWert!
        for lineIndex in 0..<lineCount {
            let p1 = json!["packageVolume"][volumeNr]["games"][number]["lines"][lineIndex]["P1"].int
            let p2 = json!["packageVolume"][volumeNr]["games"][number]["lines"][lineIndex]["P2"].int
            let row1 = p1! / squereSize
            let column1 = p1! % squereSize
            let row2 = p2! / squereSize
            let column2 = p2! % squereSize
            
            spielArray[column1, row1]!.color = LineType(rawValue: lineIndex + 1)!
            spielArray[column2, row2]!.color = LineType(rawValue: lineIndex + 1)!
            spielArray[column1, row1]!.originalPoint = true
            spielArray[column2, row2]!.originalPoint = true
            
            let point1 = Point(column: column1, row: row1, type: LineType(rawValue: lineIndex + 1)!, originalPoint: true, inLinePoint: false, delegate: checkDirections)
            let point2 = Point(column: column2, row: row2, type: LineType(rawValue: lineIndex + 1)!, originalPoint: true, inLinePoint: false, delegate: checkDirections)

            let color = LineType(rawValue: lineIndex + 1)
            
            lines[color!] = Line(lineType: color!)
            lines[color!]!.point1 = point1
            lines[color!]!.point2 = point2
            lines[color!]!.cnt = 2
        }
        for index in 1...lines.count {
            let color = LineType(rawValue: index)!
            if lines[color]!.cnt > 2 {
                if error == "" {
                    error = "The color \(color) \(lines[color]!.cnt) times!"
                } else {
                    error = error + ", \(color) \(lines[color]!.cnt) times!"
                }
            }
        }
        //println("spielArray: \(spielArray)")
        //println("lines: \(lines)")
        return (true, lineCount, spielArray, error, lines)
    }
    func checkDirections (Int, Int) {
        
    }
    
}


