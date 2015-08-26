//
//  LevelsForPlayWithSprites.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 19.08.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit

enum LevelParamsType: Int {
    case LevelCount = 0,
    CountContainers = 1,
    CountSpritesProContainer = 2,
    CountColumns = 3,
    CountRows = 4,
    MinProzent = 5,
    MaxProzent = 6,
    ContainerSize = 7,
    SpriteSize = 8,
    TargetScoreKorr = 9,
    TimeLimitKorr = 10
}


class LevelsForPlayWithSprites {
    
    var level: Int
    var aktLevel: LevelParam
    let levelChanges = [
        "5,0,10,0,0,0,0,0,0,0,0",    // 5 times CountSpritesProContainer += 10
        "5,0,0,0,0,5,0,0,0,0,0",     // 2 times MinProzent += 5
        "5,0,0,0,0,0,5,0,5,0,0",     // 2 times MinProzent -= 3, MaxProzent += 5
        "2,0,10,0,0,0,0,0,5,0,0",    // 2 times CountSpritesProContainer += 10, SpriteSize += 5
        "2,0,0,0,0,0,0,0,0,1,0",     // 2 times TargetScoreCorr += 1
        "1,0,0,0,0,0,0,0,0,0,-1",    // 2 times TimeLimitKorr -= 1
        "1,0,0,1,1,0,0,0,0,1,-1",     // 1 time CountColumns += 1, CountRows += 1, TargetScoreCorr += 1
        "5,0,10,0,0,0,0,0,0,0,0"     // 5 times CountSpritesProContainer += 10
    ]
    private var levelContent = [
        1: "-1,3,10,4,4,25,70,60,30,1,4", // first param (levelCount) say, how many levels to make for this Line, if -1, than all levels according levelchanges
        2: "-1,4,20,5,5,20,70,60,30,2,3",
        3: "-1,5,20,5,5,20,70,50,30,3,3",
        4: "-1,6,20,5,5,20,70,50,30,2,3",
        5: "-1,7,20,5,5,20,70,40,25,2,3",
        6: "-1,8,20,5,5,20,70,40,25,2,3"
    ]
    var levelParam = [LevelParam]()
    
    init () {
       level = 0
        
        for index in 1..<levelContent.count + 1 {
            let paramString = levelContent[index]
            let paramArr = paramString!.componentsSeparatedByString(",")
            var aktLevelParam: LevelParam = LevelParam()
            var levelCount = paramArr[0].toInt() >= 0 ? paramArr[0].toInt() : 1000
            aktLevelParam.countContainers = paramArr[1].toInt()!
            aktLevelParam.countSpritesProContainer = paramArr[2].toInt()!
            aktLevelParam.countColumns = paramArr[3].toInt()!
            aktLevelParam.countRows = paramArr[4].toInt()!
            aktLevelParam.minProzent = paramArr[5].toInt()!
            aktLevelParam.maxProzent = paramArr[6].toInt()!
            aktLevelParam.containerSize = paramArr[7].toInt()!
            aktLevelParam.spriteSize = paramArr[8].toInt()!
            aktLevelParam.targetScoreKorr = paramArr[9].toInt()!
            aktLevelParam.timeLimitKorr = paramArr[10].toInt()!
            levelParam.append(aktLevelParam)
            
            var aktIndex = levelParam.count - 1
            for levelChangeIndex in 0..<levelChanges.count {
                let levelChangeArr = levelChanges[levelChangeIndex].componentsSeparatedByString(",")
                let loopValue = levelChangeArr[LevelParamsType.LevelCount.rawValue].toInt()
                for ind in 0..<loopValue! {
                    aktLevelParam.countContainers = levelParam.last!.countContainers + levelChangeArr[LevelParamsType.CountContainers.rawValue].toInt()!
                    aktLevelParam.countSpritesProContainer = levelParam.last!.countSpritesProContainer + levelChangeArr[LevelParamsType.CountSpritesProContainer.rawValue].toInt()!
                    aktLevelParam.countColumns = levelParam.last!.countColumns + levelChangeArr[LevelParamsType.CountColumns.rawValue].toInt()!
                    aktLevelParam.countRows = levelParam.last!.countRows + levelChangeArr[LevelParamsType.CountRows.rawValue].toInt()!
                    aktLevelParam.minProzent = levelParam.last!.minProzent + levelChangeArr[LevelParamsType.MinProzent.rawValue].toInt()!
                    aktLevelParam.maxProzent = levelParam.last!.maxProzent + levelChangeArr[LevelParamsType.MaxProzent.rawValue].toInt()!
                    aktLevelParam.containerSize = levelParam.last!.containerSize + levelChangeArr[LevelParamsType.ContainerSize.rawValue].toInt()!
                    aktLevelParam.spriteSize = levelParam.last!.spriteSize + levelChangeArr[LevelParamsType.SpriteSize.rawValue].toInt()!
                    aktLevelParam.targetScoreKorr = levelParam.last!.targetScoreKorr + levelChangeArr[LevelParamsType.TargetScoreKorr.rawValue].toInt()!
                    aktLevelParam.timeLimitKorr = levelParam.last!.timeLimitKorr + levelChangeArr[LevelParamsType.TimeLimitKorr.rawValue].toInt()!
                    levelParam.append(aktLevelParam)
                    if levelParam.count - aktIndex > levelCount! {
                        break
                    }
                }
                if levelParam.count - aktIndex > levelCount! {
                    break
                }
            }
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