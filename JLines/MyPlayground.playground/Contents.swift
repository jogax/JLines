//: Playground - noun: a place where people can play

import UIKit

var str = "010255530"
var str1 = "200150030"
var any: AnyObject = str
var arr1 = [AnyObject]()
arr1.append(str)
arr1.append(str1)
var gesamt: NSString = String(arr1[0] as! NSString) + String(arr1[1] as! NSString)

var st1 = gesamt.substringWithRange(NSRange(location: 0, length: 9)) as NSString
var st2 = gesamt.substringWithRange(NSRange(location: 9, length: 9)) as NSString

var farbe1 = st2.substringWithRange(NSRange(location: 0, length: 3))

var farbe2 = st2.substringWithRange(NSRange(location: 3, length: 3))
var farbe3 = st2.substringWithRange(NSRange(location: 6, length: 3))