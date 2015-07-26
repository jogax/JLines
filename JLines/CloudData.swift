//
//  CloudData.swift
//  JLinesV2
//
//  Created by Jozsef Romhanyi on 20.04.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import CloudKit

class CloudData {
    var container: CKContainer
    var privatDB: CKDatabase
    var publicDB: CKDatabase
    var wait = true
    
    init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
        privatDB = container.privateCloudDatabase
    }
    
    func saveRecord(gameData: GameData) {
        deleteIfExists(gameData)
        let gameDataRecord = CKRecord(recordType: "GameStatus")
        gameDataRecord.setValue(gameData.gameName, forKey: "gameName")
        gameDataRecord.setValue(gameData.gameNumber, forKey: "gameNumber")
        gameDataRecord.setValue(gameData.countLines, forKey: "countLines")
        gameDataRecord.setValue(gameData.countMoves, forKey: "countMoves")
        gameDataRecord.setValue(gameData.countSeconds, forKey: "countSeconds")
        gameDataRecord.setValue(gameData.timeStemp, forKey: "timeStamp")
        privatDB.saveRecord(gameDataRecord, completionHandler: { returnRecord, error in
            if let err = error {
                //println("error: \(err)")
            }
        })
    }
    
    func deleteIfExists(gameData: GameData) {
        var wait = true
        let p1 = NSPredicate(format: "gameName = %@", gameData.gameName)
        let p2 = NSPredicate(format: "gameNumber = %ld", gameData.gameNumber)
        let predicate = NSCompoundPredicate.andPredicateWithSubpredicates([p1, p2])
        let query = CKQuery(recordType: "GameStatus", predicate: predicate)
        privatDB.performQuery(query, inZoneWithID: nil) {
            results, error in
            if error != nil {
                self.wait = false
            } else {
                //println("results:\(results.count)")
                self.wait = false
            }
        }
            
    }
    
    func fetchAllRecords() -> MyGames {
        var myGames = MyGames()
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "GameStatus", predicate: predicate)
        privatDB.performQuery(query, inZoneWithID: nil) {
            results, error in
            if error != nil {
               self.wait = false
            }
            else
            {
                for (ind, result) in enumerate(results!) {
                    let match = result as! CKRecord
                    var gameData = GameData()
                    gameData.gameName = match.valueForKey("gameName")! as! String
                    gameData.gameNumber = match.valueForKey("gameNumber")! as! NSInteger
                    gameData.countLines = match.valueForKey("countLines")! as! NSInteger
                    gameData.countMoves = match.valueForKey("countMoves")! as! NSInteger
                    gameData.countSeconds = match.valueForKey("countSeconds")! as! NSInteger
                    //gameData.timeStemp = match.valueForKey("timeStamp")! as! NSDate
                    let volume = GV.volumeNr
                    //println("volume:\(volume), number: \(gameData.gameNumber), countLines: \(gameData.countLines), countMoves: \(gameData.countMoves)")
                    myGames.volumes[volume].games[gameData.gameNumber - 1] = gameData
                }
                self.wait = false
            }
        }
        while wait
        {
            let a = 0
        }
        return myGames
    }

    func readLevelDataArray() -> [Level]{
        var levels = [Level]()
        let LevelRecord = CKRecord(recordType: "Levels")
        //let predicate = NSPredicate(value: true)
        let deviceType = GV.onIpad ? "IPAD" : "IPhone"
        //let sort = NSSortDescriptor(key: "F002_Level", ascending: false)
        
        let predicate = NSPredicate(format: "F001_DeviceType = %@", deviceType)
        let query = CKQuery(recordType: "Levels", predicate: predicate)
        //pquery.sortDescriptors = [sort]
        publicDB.performQuery(query, inZoneWithID: nil) {
            results, error in
            if error != nil {
                self.wait = false
            }
            else
            {
                for index in 0..<results.count {
                    var level = Level()
                    levels.append(level)
                }
                for (ind, result) in enumerate(results!) {
                    let match = result as! CKRecord
                    var level = Level()
                    let levelNr = match.valueForKey("F002_Level")! as! NSInteger
                    level.countContainers = match.valueForKey("F003_CountContainers")! as! NSInteger
                    level.countSpritesProContainer = match.valueForKey("F004_CountSpritesProContainer")! as! NSInteger
                    level.countColumns = match.valueForKey("F005_CountColumns")! as! NSInteger
                    level.countRows = match.valueForKey("F006_CountRows")! as! NSInteger
                    level.minProzent = match.valueForKey("F007_MinProzent")! as! NSInteger
                    level.maxProzent = match.valueForKey("F008_MaxProzent")! as! NSInteger
                    level.containerSize = match.valueForKey("F009_ContainerSize")! as! NSInteger
                    level.spriteSize = match.valueForKey("F010_SpriteSize")! as! NSInteger
                    levels[levelNr] = level
                }
                self.wait = false
            }
        }
        while wait
        {
            let a = 0
        }


        return levels
    }

}