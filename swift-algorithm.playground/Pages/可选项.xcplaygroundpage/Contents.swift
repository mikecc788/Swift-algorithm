//: [Previous](@previous)

import Foundation

var greeting:String? = "Hello, playground"

greeting = nil

var age:Int?

var arr = [1,5,10,20]

func get(_ index:Int)->Int?{
    if(index < 0 || index > 3) {return nil}
    return arr[index]
}

print(get(2)!)

var array = [1,5,10,20]
array[1]

guard let username = "bbbb" else{
    print("aaaa")
    return
}
print(username)

