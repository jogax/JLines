//
//  Package.swift
//  JLinesV1
//
//  Created by Jozsef Romhanyi on 11.02.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import UIKit



class Language {
    
    var callBacks: [()->()] = []
    var package: Dictionary<String, AnyObject>?
    var json: JSON?
    var packageName: AnyObject
    
    init() {
        packageName = NSLocale.preferredLanguages()[0]

        let (package, data) = Dictionary<String, AnyObject>.loadJSONFromBundle(packageName as! NSString as String)
        json = JSON(data: data!)
        
        
    }
    
    func setLanguage(language: String) {
        self.packageName = json![language].string!
        let (package, data) = Dictionary<String, AnyObject>.loadJSONFromBundle(packageName as! NSString as String)
        json = JSON(data: data!)

        for index in 0..<callBacks.count {
            callBacks[index]()
        }
    }
    
    func getText (origText: String, par:String...) -> String {
        if var text = json![origText].string {
            var index = 0
            for parameter in par {
                if let pos = text.rangeOfString("%\(++index)!") {
                    text.replaceRange(pos, with: parameter)
                }
            }
            return text
        } else
        {
            return getText("not found")
        }
    }
    
    func getLanguageCount() -> Int {
        var index = 0
        while json!["languages"][index]["EN"] != nil {
            index++
        }
        return index
    }
    
    func getLanguages() -> [String] {
        var index = 0
        var languages: [String] = []
        while json!["languages"][index] != nil {
            languages.append(json!["languages"][index++].string!)
        }
        return languages
    }
    
    func callBackWhenNewLanguage(updateLanguage: ()->()) {
        callBacks.append(updateLanguage)
        for index in 0..<callBacks.count {
            callBacks[index]()
        }

    }

    func getAktLanguageIndex() -> Int {
       return json!["languageIndex"].string!.toInt()!
    }
    
}


