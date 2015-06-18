//
//  Point.swift
//  JogaxLinesV1
//
//  Created by Jozsef Romhanyi on 07.02.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import UIKit


struct Directions {
    var left: Int
    var right: Int
    var up: Int
    var down: Int
    var count: Int
    var countDirections: Int
    
    init() {
        left = 0
        right = 0
        up = 0
        down = 0
        count = 0
        countDirections = 0
    }
    
}

class Point: Printable, Hashable {
    
    var column: Int
    var row: Int
    var checkDirections: (x:Int, y:Int)->()
    var color: LineType {
        didSet {
            if color != oldValue {
                checkDirections(x: column, y: row)
            }
        }
    }
    var originalPoint: Bool
    
    var inLinePoint: Bool {
        didSet {
            if !inLinePoint {
                layer.removeFromSuperlayer()
                layer = CALayer()
            }
        }
    }
    var earlierColor: LineType
    var areaNumber: Int
    var layer = CALayer()
    var directions: Directions
    
    init(column: Int, row: Int, type: LineType, originalPoint: Bool, inLinePoint: Bool, delegate: (Int, Int)->()) {
        self.column = column
        self.row = row
        self.color = type
        self.originalPoint = originalPoint
        self.inLinePoint = inLinePoint
        self.earlierColor = LineType.Unknown
        self.checkDirections = delegate
        self.areaNumber = -1
        self.directions = Directions()
    }
    
    func clearDirections () {
        directions.left = 0
        directions.right = 0
        directions.up = 0
        directions.down = 0
        directions.count = 0
        directions.countDirections = 0
    }
    
    func countDirections(){
        directions.count = directions.left + directions.right + directions.up + directions.down
        directions.countDirections = directions.left > 0 ? 1 : 0
        directions.countDirections += directions.right > 0 ? 1 : 0
        directions.countDirections += directions.up > 0 ? 1 : 0
        directions.countDirections += directions.down > 0 ? 1 : 0
    }
    
    func clearPoint () {
        color = .Unknown
        originalPoint = false
        inLinePoint = false
        earlierColor = .Unknown
        areaNumber = 0
    }
    
    var description: String {
        return String("\n column: \(column), row: \(row), type: \(color), originalPoint: \(originalPoint), inLinePoint: \(inLinePoint)")
    }
    
    var hashValue: Int {
        return (column + 1) * (row + 1)
    }
}

func ==(lhs: Point, rhs: Point) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color == rhs.color
}

