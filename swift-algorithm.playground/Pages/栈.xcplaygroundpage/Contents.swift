//: [Previous](@previous)

import Foundation

public struct Stack<T>{
    fileprivate var array = [T]()
    
    public var isEmpty: Bool{
        return array.isEmpty
    }
    
    public var count: Int {
        return array.count
    }
    
//    所以在方法前边添加 mutating来修饰的话是为了能在该方法中修改 struct、enum的变量
    public mutating func push(_ element:T){
        array.append(element)
    }
    
    public mutating func pop() -> T?{
        return array.popLast()
    }
    
    
    public var top:T?{
        return array.last
    }
    public func peek() -> T?{
        return array.last
    }
}

var rwBookStack = Stack<String>()
rwBookStack.push("3D Games by Tutorials")
rwBookStack.push("two")
rwBookStack.push("three")
//rwBookStack.pop()
rwBookStack.peek()
//: [Next](@next)
