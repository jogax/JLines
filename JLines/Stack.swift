//
//  Stack.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 27.08.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import Foundation

class Stack<T> {
    private var stack: Array<T?>
    
    init() {
        stack = Array<T?>()
    }
    
    func push (value: T?) {
        stack.append(value)
    }
    
    func pull () -> T? {

        if stack.count > 0 {
            let value = stack.last
            stack.removeLast()
            return value!
        } else {
            return nil
        }
    }
}
