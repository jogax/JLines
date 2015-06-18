//
//  DataStore.swift
//  JLinesV2
//
//  Created by Jozsef Romhanyi on 15.04.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit





class DataStore {
    
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    //let request = NSFetchRequest()
    var error: NSError?
    var gameEntity: GameStatus?
    var appVariablesEntity: AppVariables?
    var appVariables: AppVariables?
    var exists: Bool = true
    var gameStatusDescription:NSEntityDescription?
    var appVariablesDescription:NSEntityDescription?
    
    init() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        gameStatusDescription = NSEntityDescription.entityForName("GameStatus", inManagedObjectContext:managedObjectContext!)
        appVariablesDescription = NSEntityDescription.entityForName("AppVariables", inManagedObjectContext:managedObjectContext!)
 
    }
    
    func createRecord(gameData: GameData) {
        if exists(gameData) {
            deleteRecords(gameData)
        }
        //println("\(gameData)")
        gameEntity = GameStatus(entity:gameStatusDescription!, insertIntoManagedObjectContext: managedObjectContext)
        updateRecord(gameData)
    }
    
    func updateRecord(gameData:GameData) {
        if exists(gameData) {
            deleteRecords(gameData)
        }
        //GV.cloudData.saveRecord(gameData)
        gameEntity = GameStatus(entity:gameStatusDescription!, insertIntoManagedObjectContext: managedObjectContext)
        let volume = GV.volumeNr
        GV.gameData.volumes[volume].games[gameData.gameNumber] = gameData
        gameEntity!.countLines = gameData.countLines
        gameEntity!.gameName = gameData.gameName
        gameEntity!.gameNumber = gameData.gameNumber
        gameEntity!.countMoves = gameData.countMoves
        gameEntity!.countSeconds = gameData.countSeconds
        managedObjectContext?.save(&error)
        if let err = error {
            let errorMessage = GV.language.getText("errorBySaveData",par:String(_cocoaString: err))
            //println("\(errorMessage)")
        }
    }
   
    func exists(gameData:GameData)->Bool {
        let request = NSFetchRequest()
        request.entity = gameStatusDescription
 
        let p1 = NSPredicate(format: "gameName = %@", gameData.gameName)
        let p2 = NSPredicate(format: "gameNumber = %ld", gameData.gameNumber)
        request.predicate = NSCompoundPredicate.andPredicateWithSubpredicates([p1, p2])
        var results = managedObjectContext?.executeFetchRequest(request, error: &error)
        if error != nil {
            //println("err: \(error)")
        }
        if let match = results?.first as? NSManagedObject {
            return true
        } else {
            return false
        }
    }
    
    
    func getCountRecords() -> Int {
        let request = NSFetchRequest()
        
        request.entity = gameStatusDescription
        
        var results = managedObjectContext!.executeFetchRequest(request, error: &error)
        return results!.count
    }

    func deleteAllRecords() {
        let request = NSFetchRequest()
        
        request.entity = gameStatusDescription
        
        var results = managedObjectContext!.executeFetchRequest(request, error: &error)
        //println("countResults: \(results!.count)")
        for (ind,result) in enumerate(results!) {
            managedObjectContext!.deleteObject(result as! NSManagedObject)
        }
        results = managedObjectContext!.executeFetchRequest(request, error: &error)
        //println("countResults: \(results!.count)")
    }
    
    

    func deleteRecords(gameData:GameData) {
        printRecords()
        //println("--------------------------------")
        let request = NSFetchRequest()
        request.entity = gameStatusDescription
        let p1 = NSPredicate(format: "gameName = %@", gameData.gameName)
        let p2 = NSPredicate(format: "gameNumber = %ld", gameData.gameNumber)
        request.predicate = NSCompoundPredicate.andPredicateWithSubpredicates([p1, p2])
        var results = managedObjectContext?.executeFetchRequest(request, error: &error)
        
        for (ind,result) in enumerate(results!) {
            managedObjectContext!.deleteObject(result as! NSManagedObject)
        }
        printRecords()
    }


    func getDataArray() -> MyGames {
        let request = NSFetchRequest()
        request.entity = gameStatusDescription
        //var cloudArray = GV.cloudData.fetchAllRecords()
        var results = managedObjectContext?.executeFetchRequest(request, error: &error)
        //println("countResults: \(results!.count)")
        //var dataArray = cloudArray
    
        
        var dataArray = MyGames()
        
        for (ind, result) in enumerate(results!) {
            let match = result as! NSManagedObject
            var gameData = GameData()
            gameData.gameName = match.valueForKey("gameName")! as! String
            gameData.gameNumber = match.valueForKey("gameNumber")! as! NSInteger
            gameData.countLines = match.valueForKey("countLines")! as! NSInteger
            gameData.countMoves = match.valueForKey("countMoves")! as! NSInteger
            gameData.countSeconds = match.valueForKey("countSeconds")! as! NSInteger
            //gameData.timeStemp = match.valueForKey("timeStamp")! as! NSDate
            let volume = GV.volumeNumber[gameData.gameName]
            //println("volume:\(volume), number: \(gameData.gameNumber), countLines: \(gameData.countLines), countMoves: \(gameData.countMoves)")
            dataArray.volumes[volume!].games[gameData.gameNumber] = gameData
        }

        return dataArray
    }
    
    func getNumberRecords () -> Int {
        let request = NSFetchRequest()
        request.entity = gameStatusDescription
        var results = managedObjectContext?.executeFetchRequest(request, error: &error)
        return results!.count
    }
    
    func createAppVariablesRecord(appData: AppData) {
        deleteGlobalVariablesRecords()
        //GV.cloudData.saveRecord(gameData)
        appVariablesEntity = AppVariables(entity:appVariablesDescription!, insertIntoManagedObjectContext: managedObjectContext)
        appVariablesEntity!.gameControll = NSNumber(longLong: appData.gameControll)
        managedObjectContext?.save(&error)
        if let err = error {
            let errorMessage = GV.language.getText("errorBySaveData",par:String(_cocoaString: err))
            //println("\(errorMessage)")
        }
    }
    
    func getAppVariablesData()->AppData {
        var appData = AppData()
        
        let request = NSFetchRequest()
        
        request.entity = self.appVariablesDescription
        
        var results = managedObjectContext!.executeFetchRequest(request, error: &error)
        if let match = results!.first as? NSManagedObject {

            appData.gameControll = Int64(match.valueForKey("gameControll") as! NSInteger)
        } else {
            appData.gameControll = Int64(GameControll.Finger.rawValue)
        }
        return appData
    }
    
    func deleteGlobalVariablesRecords() {
        let request = NSFetchRequest()
        
        request.entity = appVariablesDescription
        
        var results = managedObjectContext!.executeFetchRequest(request, error: &error)
        for (ind,result) in enumerate(results!) {
            managedObjectContext!.deleteObject(result as! NSManagedObject)
        }
        results = managedObjectContext!.executeFetchRequest(request, error: &error)
    }
    
    func printRecords() {
        let request = NSFetchRequest()
        request.entity = gameStatusDescription
        var results = managedObjectContext?.executeFetchRequest(request, error: &error)
        for (ind, result) in enumerate(results!) {
            let match = result as! NSManagedObject

            let gameName = match.valueForKey("gameName")! as! String
            let gameNumber = match.valueForKey("gameNumber")! as! NSInteger
            let countLines = match.valueForKey("countLines")! as! NSInteger
            let countMoves = match.valueForKey("countMoves")! as! NSInteger
            let countSeconds = match.valueForKey("countSeconds")! as! NSInteger
            
            //println("name: \(gameName), number: \(gameNumber), lines: \(countLines), moves:\(countMoves), seconds:\(countSeconds)")

        }
        
    }
    
}