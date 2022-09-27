//: [Previous](@previous)

import Foundation

// 有一种更聪明的方法来计算GCD：欧几里德的算法
//gcd(a, b) = gcd(b, a % b) 其中a％b是a除以b的余数
//使用递归
func gcd(_ a:Int,_ b:Int)->Int{
    let r = a % b
    if r != 0{
        return gcd(b, r)
    }else{
        return b
    }
}

gcd(52, 39)
gcd(51357, 3819)
gcd(841, 299)
//: [Next](@next)

//下面是欧几里德算法略微不同的一种实现。 与第一个版本不同，它不使用递归，而只使用基本的while循环。

//函数顶部的 max() 和 min() 确保我们总是用较大的数字除以较小的数字
func gcd1(_ m:Int,_ n :Int)->Int{
    var a = 0
    var b = max(m, n)
    var c = min(m, n)
    while c != 0 {
        a = b
        b = c
        c = a % b
    }
    
    return b
}

gcd1(52, 39)

