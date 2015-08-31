//
//  Stack.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 27.08.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import Foundation

class Stack<T> {
    private var stack: Array<SavedSprite>
    
    init() {
        stack = Array<SavedSprite>()
    }
    
    func push (value: SavedSprite) {
        stack.append(value)
    }
    
    func pull () -> SavedSprite? {

        if stack.count > 0 {
            let value = stack.last
            stack.removeLast()
            return value!
        } else {
            return nil
        }
    }
}
