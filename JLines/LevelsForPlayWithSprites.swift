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
        1: "a,3,10,4,4,25,80,60,25,1.0,4",
        2: "r,0,10,0,0,0,0,0,0,0.0,0",
        3: "r,0,10,0,0,0,0,0,0,0.0,0",
        4: "r,0,10,0,0,10,0,0,0,0.5,-1",
        5: "r,0,10,1,1,0,0,0,0,0.0,0",
        6: "r,0,10,0,0,0,0,0,0,0.0,0",
        7: "r,0,10,0,0,0,0,0,0,0.5,-1",
        8: "r,0,10,0,0,0,0,0,0,0.0,0",
        9: "r,0,10,0,0,0,0,0,0,0.0,0",
        10: "a,4,20,4,4,20,50,60,25,1.0,2",
        11: "r,0,10,0,0,0,10,0,0,0,0",
        12: "r,0,10,0,0,0,0,0,0,0.5,0",
        13: "r,0,10,1,1,0,10,0,0,0,0",
        14: "r,0,10,0,0,0,0,0,0,1.0,0",
        15: "r,0,10,0,0,0,10,0,0,0,-1",
        16: "r,0,0,1,1,0,0,0,0,1.0,0",
        17: "r,0,0,0,0,0,0,0,0,0.5,-1",
        18: "r,0,10,0,0,0,0,0,0,0,0",
        19: "r,0,20,0,0,0,0,0,0,0,0",
        20: "a,5,20,5,5,10,30,50,25,2.0,4",
        21: "r,0,20,0,0,0,10,0,0,0,0",
        22: "r,0,20,0,0,0,10,0,0,0,0",
        23: "r,0,20,0,0,0,10,0,0,0.5,0",
        24: "r,0,20,0,0,0,10,0,0,0,-1",
        25: "r,0,0,1,1,0,10,0,0,0,0",
        26: "r,0,0,0,0,0,10,0,0,0.5,0",
        27: "r,0,0,0,0,0,10,0,0,0,-1",
        28: "r,0,0,0,0,0,10,0,0,0,0",
        29: "r,0,0,0,0,0,10,0,0,0.5,0",
        30: "a,6,30,6,6,10,30,50,30,3.0,4",
        31: "r,0,10,0,0,0,10,0,0,0,0",
        32: "r,0,10,0,0,0,10,0,0,0,0",
        33: "r,0,10,0,0,0,10,0,0,0.5,0",
        34: "r,0,10,0,0,0,10,0,0,0,-1",
        35: "r,0,20,0,0,0,10,0,0,0,0",
        36: "r,0,20,0,0,0,10,0,0,0.5,0",
        37: "r,0,20,0,0,0,10,0,0,0,-1",
        38: "r,0,20,0,0,0,10,0,0,0,0",
        39: "r,0,20,0,0,0,10,0,0,0.5,0",
    ]
    var levelParam = [LevelParam]()
    
    init () {
       level = 0
        for index in 1..<levelContent.count {
            let paramString = levelContent[index]
            let paramArr = paramString!.componentsSeparatedByString(",")
            var aktLevelParam: LevelParam = LevelParam()
            let absVal = paramArr[0] == "a" ? true : false
            aktLevelParam.countContainers = absVal ? paramArr[1].toInt()! : levelParam[index - 2].countContainers + paramArr[1].toInt()!
            aktLevelParam.countSpritesProContainer = absVal ? paramArr[2].toInt()! : levelParam[index - 2].countSpritesProContainer + paramArr[2].toInt()!
            aktLevelParam.countColumns = absVal ? paramArr[3].toInt()! : levelParam[index - 2].countColumns + paramArr[3].toInt()!
            aktLevelParam.countRows = absVal ? paramArr[4].toInt()! : levelParam[index - 2].countRows + paramArr[4].toInt()!
            aktLevelParam.minProzent = absVal ? paramArr[5].toInt()! : levelParam[index - 2].minProzent + paramArr[5].toInt()!
            aktLevelParam.maxProzent = absVal ? paramArr[6].toInt()! : levelParam[index - 2].maxProzent + paramArr[6].toInt()!
            aktLevelParam.containerSize = absVal ? paramArr[7].toInt()! : levelParam[index - 2].containerSize + paramArr[7].toInt()!
            aktLevelParam.spriteSize = absVal ? paramArr[8].toInt()! : levelParam[index - 2].spriteSize + paramArr[8].toInt()!
            aktLevelParam.targetScoreKorr = absVal ? CGFloat((paramArr[9] as NSString).floatValue) : levelParam[index - 2].targetScoreKorr + CGFloat((paramArr[9] as NSString).floatValue)
            aktLevelParam.timeLimitKorr = absVal ? paramArr[10].toInt()! : levelParam[index - 2].timeLimitKorr + paramArr[10].toInt()!
            levelParam.append(aktLevelParam)
        }
        aktLevel = levelParam[0]
    }

    func setAktLevel(level: Int) {
        self.level = level
        aktLevel = levelParam[level]
    }
    
    func getNextLevel() -> Int {
        level++
        aktLevel = levelParam[level]
        return level
    }
    
}