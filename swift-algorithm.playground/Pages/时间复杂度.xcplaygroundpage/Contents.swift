//: [Previous](@previous)

import Foundation

var array = [1,2,4,6,8,9]

//O(1)复杂性的最常见示例是访问数组索引。
let value = array[5]
print(value)
//另外一个O(1)的例子是栈的推进和弹出。

var greeting = "Hello, playground"

//O(log n)
var j = 1
while j < n {
  // do constant time stuff
  j *= 2
}


//O(n)
for i in stride(from: 0, to: 10, by: 1){
    print(array[i])
}

//O(n log n)
for i in stride(from: 0, to: n, by: 1) {
var j = 1
  while j < n {
    j *= 2
    // do constant time stuff
  }
}

//O(n^2)
for i  in stride(from: 0, to: n, by: 1) {
  for j in stride(from: 1, to: n, by: 1) {
    // do constant time stuff
  }
}

//O(n!)
func nFactFunc(n: Int) {
  for i in stride(from: 0, to: n, by: 1) {
    nFactFunc(n: n - 1)
  }
}
