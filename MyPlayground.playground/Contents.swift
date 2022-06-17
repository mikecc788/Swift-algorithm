import UIKit

var greeting = "Hello, playground"

class Person{
    var name:String
    var age:Int
    init(name:String,age:Int) {
        self.name = name
        self.age = age
    }
}
extension Person:CustomStringConvertible{
    var description: String {
        get{
            return "\(name) age \(age)"
        }
    }
    
}

//let zhang = Person.init(name: "zhangn", age: 18)
//
//let str:String? = "abc"
//if str != nil{
//    let count = str!.count
////    print(count)
//}
//let count = str?.count
//
//let str1:String! = "abcd"
////print(str1.count)
//
//let str2:Optional<String> = "abc"
//if let actualStr = str2{
//    let count = actualStr.count
////    print(count)
//}

//var num1:UInt8 = 251
//var num2 = num1 &+ 20
//print(num2)


//let a : Int? = 10
//let b = 8
//print(a ?? b)

//let range = ...5
//print(range)

//var welcome = "hello.world"
//let range = welcome.index(welcome.endIndex, offsetBy: -6)..<welcome.endIndex
//welcome.removeSubrange(range)
//print(welcome)

//let five = Array.init(repeating: "a", count: 4)
//print(five)
//var numbers = [Int](3...7)
//for (num,index) in numbers.enumerated(){
//    print(num,index)
//}
//
//numbers.shuffle()
//print(numbers)

//struct Stack<T> {
//    private var elements = [T]()
//
//    var count:Int{
//        return elements.count
//    }
//
//    var isEmpty:Bool{
//        return elements.isEmpty
//    }
//
//    mutating func push(_ element:T){
//        elements.append(element)
//    }
//
//    mutating func pop() -> T?{
//        return elements.popLast()
//    }
//}
//
//var stack = Stack<Int>()
//
//stack.push(1)
//stack.push(6)
//stack.push(7)
//print(stack.count)
//print(stack.pop() ?? 0)
//print(stack.count)
//
//struct Queue<T>{
//    private var elements = [T]()
//
//    var count:Int{
//        return elements.count
//    }
//
//    var isEmpty:Bool{
//        return elements.isEmpty
//    }
//}
//
//var dict1 = Dictionary<String,Int>()
//print(type(of: dict1))

var xa = [1,2,3,4]
let squares = xa.map {
    
    $0 * $0
}

//print(squares)


let numbers = [1,2,5,4,3,6,8,7]
let sortNumbers = numbers.sorted(by: { (a,b)->Bool in
    return a < b
})

print("numbers -" + "\(sortNumbers)")

func SwapTwoValues <T>(value1: inout T, value2: inout T) {
        let p = value1
        value1 = value2
        value2 = p
}
var a1 = "hello"
var a2 = "world"

SwapTwoValues(value1: &a1, value2: &a2)
print(a1,a2)
