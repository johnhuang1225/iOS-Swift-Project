//: Playground - noun: a place where people can play

import UIKit

var url = NSURL(string: "http://opendata.epa.gov.tw/ws/Data/AQX/?format=json")
var data = NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingUncached, error: nil)
var json = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSArray

for result in json {
    var site: AnyObject? = result.objectForKey("SiteName")
    var status: AnyObject? = result.objectForKey("Status")
    println("\(site):\(status)")
}




struct Point {
    var x:Double
    var y:Double
}

struct Size {
    var length:Double = 0.0 {
        willSet{
            println("長度變更前:\(length)")
        }
        didSet{
            println("長度變更後:\(length)")
        }
    }
}

class Square {
    var originPoint:Point
    var size:Size
    var center:Point {
        get{
            let centerX = originPoint.x + size.length / 2
            let centerY = originPoint.y + size.length / 2
            return Point(x: centerX, y: centerY)
        }
    }
    
    init(originPoint:Point, size:Size) {
        self.originPoint = originPoint
        self.size = size
    }
    
    class func lines() -> Int {
        return 4
    }
}

var square = Square(originPoint: Point(x: 2, y: 3), size: Size(length: 10))
square.center

var s = Size(length: 10)
s.length = 12


Square.lines()



let chinese = [
    0:"零",
    1:"一",
    2:"二",
    3:"三",
    4:"四",
    5:"五",
    6:"六",
    7:"七",
    8:"八",
    9:"九"
]

let number = [20,1225,126,123]

number.map{
    (var num) -> String in
    var resultStr = ""
    while num > 0 {
        resultStr = chinese[num % 10]! + resultStr
        num = num / 10
    }
    return resultStr
}


var testNum:Int = 1225
var result = ""
while testNum > 0 {
    result = chinese[testNum % 10]! + result
    testNum = testNum / 10
}
result


//let swiftDict:Dictionary<String,String> = ["1":"john","2":"jessica"]
let nsDictionary = NSDictionary(objects: ["john","jessica"], forKeys: ["1","2"])
let swiftDict = nsDictionary as Dictionary
for (key,value) in swiftDict {
    println("\(key):\(value)")
}

nsDictionary.allValues


// =======
struct Human{
    var name:String?
    var age:String?
    var weight:String?
}

let keyString: NSString = "name age weight"
var keys: NSArray = keyString.componentsSeparatedByString(" ")

let valueString: NSString = "john 40 65"
var values: NSArray = valueString.componentsSeparatedByString(" ")



// ======= Generic

func myFilter<T>(source: [T], predicate: (T)->Bool) -> [T] {
    var result = [T]()
    for item in source {
        if predicate(item) {
            result.append(item)
        }
    }
    return result
}

func distinct<T:Equatable>(source: [T]) -> [T] {
    var result = [T]()
    for item in source {
        if !contains(result, item) {
            result.append(item)
        }
    }
    return result
}


typealias Entry = (Character,[String])

func buildIndex(words: [String]) -> [Entry] {
    var result = [Entry]()
    
    var letters = [Character]()
    for word in words {
        let char = Character( word.substringToIndex(advance(word.startIndex, 1)).uppercaseString )
        if !contains(letters, char) {
            letters.append(char)
        }
    }
    
    println("letters:\(letters)")
    
    
    for letter in letters {
        var wordsForLetters = [String]()
        for word in words {
            if letter == Character( word.substringToIndex(advance(word.startIndex, 1)).uppercaseString ) {
                wordsForLetters.append(word)
            }
        }
        result.append( (letter,wordsForLetters) )
        
    }
    return result
}

let words = ["Cat", "Chicken", "fish", "Dog",
    "Mouse", "Guinea Pig", "monkey"]

println(buildIndex(words))

















