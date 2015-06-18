//
//  Line.swift
//  PointCrunch
//
//  Created by Jozsef Romhanyi on 26.01.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import UIKit

enum LineType: Int, Printable {
    case Unknown = 0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15, C16, LastColor

    var colorName: String {
        let colorNames = [
            "none",
            "C1",
            "C2",
            "C3",
            "C4",
            "C5",
            "C6",
            "C7",
            "C8",
            "C9",
            "C10",
            "C11",
            "C12",
            "C13",
            "C14",
            "C15",
            "C16",
            "LastColor"
        ]
        
        return colorNames[rawValue]
    }
        
    var colorAbbr: String {
        let colorAbbrs = [
            " ",
            "A",
            "B",
            "C",
            "D",
            "E",
            "F",
            "G",
            "H",
            "I",
            "J",
            "K",
            "L",
            "M",
            "N",
            "O",
            "P",
            " "
        ]
        
        return colorAbbrs[rawValue]
    }

    var uiColor: UIColor {
        var uiColorTypes:[UIColor] = GV.colorSets[GV.colorSetIndex]

        /*
        var uiColorTypes = [
            UIColor.clearColor(),
            UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1), // Red
            UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1), // Gold
            UIColor(red: 0/255, green: 255/255, blue: 127/255, alpha: 1), // Springgreen
            UIColor(red: 255/255, green: 105/255, blue: 180/255, alpha: 1), // HotPink
            UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1), // green
            UIColor.blueColor(),
            UIColor.magentaColor(),
            UIColor(red: 255/255, green: 218/255, blue: 155/255, alpha: 1), // PeachPuff
            UIColor.purpleColor(),
            UIColor.orangeColor(),
            UIColor.cyanColor(),
            UIColor.brownColor(),
            UIColor.lightGrayColor(),
            UIColor.darkGrayColor(),
            UIColor(red:255/255, green: 228/255, blue: 225/255, alpha:1),
            UIColor(red: 165/255, green: 42/255, blue: 42/255, alpha:1),
            UIColor.blackColor()
        ]
        */
        return uiColorTypes[rawValue]
    }

    var description: String {
        return colorName
    }
}

func ==(lhs: LineType, rhs: LineType) -> Bool {
    return lhs.colorName == rhs.colorName
}

class Line: Hashable, Printable {
    var cnt: Int
    var point1: Point?
    var point2: Point?
    var points = [Point]()
    var color: LineType
    var lineEnded: Bool
    
    init(lineType: LineType) {
        self.color = lineType
        self.lineEnded = false
        cnt = 1
    }
    
    func addPoint(point: Point) {
        points.append(point)
        lineEnded = pointInLine(point1!) && pointInLine(point2!)
        cnt = points.count
    }
    
    func firstPoint() -> Point {
        return points[0]
    }
    
    func pointInLine(point: Point) -> Bool {
        for pnt in self.points {
            if pnt == point {
                return true
            }
        }
        return false
    }
    func lastPoint() -> Point {
        return points[points.count - 1]
    }

    
    func removeLastPoint() {
        lastPoint().inLinePoint = false
        points.removeAtIndex(points.count - 1)
        cnt = points.count
    }
    
    var length: Int {
        return points.count
    }
    
    var description: String {
        return "cnt: \(cnt), \npoint1: \(point1), \npoint2: \(point2), type: \(color) \n points: \(points)"
    }
    
    var hashValue: Int {
        return reduce(points, 0) { $0.hashValue ^ $1.hashValue }
    }
    
}

func ==(lhs: Line, rhs: Line) -> Bool {
    return lhs.points == rhs.points
}
