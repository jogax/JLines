//
//  GameStatus.swift
//  
//
//  Created by Jozsef Romhanyi on 22.04.15.
//
//

import Foundation
import CoreData

class GameStatus: NSManagedObject {

    @NSManaged var countLines: NSNumber
    @NSManaged var countMoves: NSNumber
    @NSManaged var countSeconds: NSNumber
    @NSManaged var gameName: String
    @NSManaged var gameNumber: NSNumber
    @NSManaged var timeStamp: NSDate

}
