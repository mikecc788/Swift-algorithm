//: [Previous](@previous)

import Foundation

var greeting = "Hello, playground"

//: [Next](@next)
/**
 /*
  多行注释
  */
 */

//: # 111

/*:
    
 */

//元祖 类似结构体
let tuple = (2,3,5,7)
print(tuple.0);

let name = [1,2,3,4]
for i in 0..<3{
    print(name[i])
}

print("222","333",separator: "\n")

enum Score{
    case points(Int)
    case grader(Character)
}

var score = Score.points(5)
score = .grader("A")
switch score {
    case let .points(i):
        print(i,"point")
    case let .grader(i):
        print(i,"grader")
}

var age = 10


MemoryLayout<Int>.size
MemoryLayout<Int>.stride
MemoryLayout.size(ofValue: age)

enum Password {
    case number(Int,Int,Int,Int)
    case other
    case final
    case score(Int)
    case number1(Int,Int,Int,Int,Int)
}

enum Season:Int{
    case spring = 1,summer,autumn,winter
}
var s = Season.spring
var s1 = Season.summer
MemoryLayout<Season>.stride
MemoryLayout<Season>.size
MemoryLayout<Season>.alignment

var pwd = Password.number(5, 6, 4, 9)
pwd = .other
pwd = .final
pwd = Password.score(10)
MemoryLayout.size(ofValue: pwd)
MemoryLayout<Password>.stride
MemoryLayout<Password>.alignment

var a1:String = "aaa"

MemoryLayout.size(ofValue: a1)
/**
 lr = 0x0000000100003f80  arm64`main + 44 at main.m:16:9
 sp = 0x000000016fdff270
 pc = 0x0000000100003f38  arm64`test
 
 0x100003f80 <+44>: ldr    x0, [sp]
 
 05 00 00 00 00 00 00 00
 06 00 00 00 00 00 00 00
 04 00 00 00 00 00 00 00
 09 00 00 00 00 00 00 00
 00 00 00 00 00 00 00 00
 
 02 00 00 00 00 00 00 00
 03 00 00 00 00 00 00 00
 00 00 00 00 00 00 00 00
 00 00 00 00 00 00 00 00
 01 00 00 00 00 00 00 00
 0x100004c30 <+48>:  mov    w8, #0xa
 0x100004c34 <+52>:  mov    x0, x8
 0x100004c38 <+56>:  mov    w8, #0x14
 0x100004c3c <+60>:  mov    x1, x8
 0x100004c44 <+68>:  ldr    x20, [sp, #0x8]
 0x100004c48 <+72>:  adrp   x8, 12
 0x100004c4c <+76>:  str    x8, [sp, #0x20]
 0x100004c50 <+80>:  adrp   x9, 12
 0x100004c58 <+88>:  str    x9, [sp, #0x10]
 0x100004c5c <+92>:  str    x0, [x8, #0x5b8]
 0x100004c60 <+96>:  mov    w8, #0xb
 0x100004c64 <+100>: mov    x0, x8
 0x100004c68 <+104>: mov    w8, #0x16
 0x100004c6c <+108>: mov    x1, x8
 
 0x1000013bc <+44>:  mov    w8, #0xa
 0x1000013c0 <+48>:  mov    x0, x8
 0x1000013c4 <+52>:  mov    w8, #0x14
 0x1000013c8 <+56>:  mov    x1, x8
 
 0x1000013d0 <+64>:  mov    x8, x1
 0x1000013d4 <+68>:  ldr    x1, [sp, #0x18]
 0x1000013d8 <+72>:  stur   x0, [x29, #-0x10]
 0x1000013dc <+76>:  stur   x8, [x29, #-0x8]
 0x1000013e0 <+80>:  stur   x0, [x29, #-0x20]
 0x1000013e4 <+84>:  stur   x8, [x29, #-0x18]
 0x1000013e8 <+88>:  mov    w8, #0xb
 0x1000013ec <+92>:  stur   x8, [x29, #-0x20]
 0x1000013f0 <+96>:  mov    w8, #0x16
 0x1000013f4 <+100>: stur   x8, [x29, #-0x18]
->  0x1000013f8 <+104>: mov    w8, #0x1
 
 
 
 */


