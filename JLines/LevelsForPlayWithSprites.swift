//
//  LevelsForPlayWithSprites.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 19.08.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit

    
class LevelsForPlayWithSprites {
    var level: Int
    var aktLevel: LevelParam
    private var levelContent = [
        1: "3,10,4,4,20,50,50,20,1.0,4",
        2: "3,20,4,4,20,60,50,20,1.5,4",
        3: "3,30,4,4,20,70,50,20,1.6,4",
        4: "3,40,4,4,20,80,50,25,1.7,4",
        5: "3,50,4,4,20,90,50,25,1.8,4",
        6: "4,20,5,5,20,20,50,25,1.0,2",
        7: "4,25,5,5,20,30,50,25,1.5,4",
        8: "4,30,5,5,20,30,50,25,1.6,4",
        9: "4,40,5,5,20,40,50,25,1.7,4",
        10: "4,50,6,6,20,40,50,25,1.8,3",
        11: "4,60,6,6,20,50,50,25,1.9,3",
        12: "4,70,6,6,10,50,50,25,2.0,3",
        13: "4,80,6,6,10,20,50,25,2.1,3",
        14: "5,10,4,4,10,20,40,20,1,4",
        15: "5,10,4,4,10,20,40,20,1,4",
        16: "5,10,4,4,10,20,40,20,1,4",
        17: "5,10,4,4,10,20,40,20,1,4",
        18: "5,10,4,4,10,20,40,20,1,4",
        19: "5,10,4,4,10,20,40,20,1,4",
        20: "5,10,4,4,10,20,40,20,1,4",
        21: "5,10,4,4,10,20,40,20,1,4",
        22: "5,10,4,4,10,20,40,20,1,4",
        23: "5,10,4,4,10,20,40,20,1,4",
        24: "5,10,4,4,10,20,40,20,1,4",
        25: "5,10,4,4,10,20,40,20,1,4",
        26: "5,10,4,4,10,20,40,20,1,4",
        27: "6,10,4,4,10,20,40,20,1,4",
        28: "6,10,4,4,10,20,40,20,1,4",
        29: "6,10,4,4,10,20,40,20,1,4",
        30: "6,10,4,4,10,20,40,20,1,4"
    ]
    var levelParam = [LevelParam]()
    
    init () {
       level = 0
        for index in 1..<levelContent.count {
            let paramString = levelContent[index]
            let paramArr = paramString!.componentsSeparatedByString(",")
            var aktLevelParam: LevelParam = LevelParam()
            aktLevelParam.countContainers = paramArr[0].toInt()!
            aktLevelParam.countSpritesProContainer = paramArr[1].toInt()!
            aktLevelParam.countColumns = paramArr[2].toInt()!
            aktLevelParam.countRows = paramArr[3].toInt()!
            aktLevelParam.minProzent = paramArr[4].toInt()!
            aktLevelParam.maxProzent = paramArr[5].toInt()!
            aktLevelParam.containerSize = paramArr[6].toInt()!
            aktLevelParam.spriteSize = paramArr[7].toInt()!
            aktLevelParam.targetScoreKorr = CGFloat((paramArr[8] as NSString).floatValue)
            aktLevelParam.timeLimitKorr = paramArr[9].toInt()!
            levelParam.append(aktLevelParam)
        }
        aktLevel = levelParam[0]
    }
    
    func getNextLevel() -> Int {
        level++
        aktLevel = levelParam[level]
        return level
    }
    
}