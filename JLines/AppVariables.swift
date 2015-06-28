//
//  AppVariables.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 28.06.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import CoreData

class AppVariables: NSManagedObject {

    @NSManaged var farbSchemaIndex: NSNumber
    @NSManaged var gameControll: NSNumber
    @NSManaged var farbSchemas: String

}
