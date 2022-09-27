//: [Previous](@previous)

//你有一个整数数组a。 编写一个算法，在数组中找到第k大的元素
//O(nlogn)  因为它首先对数组进行排序，因此也使用额外的 O(n) 空间
import Foundation

var a1 = [-1,3,10,6,9,4,39,24,17]

func kthLargest(_ a: [Int], _ k: Int) -> Int? {
    let length = a.count
    if k > 0 && k <= length{
        let bbbbb = a.sorted()
        return bbbbb[length - k]
        
    }
       
    else{
        return nil
    }
        
}

print(kthLargest(a1,4)!)

//有一种聪明的算法结合了二分搜索和快速排序的思想来达到O(n)解决方案
//<T:Comparable>
func randomizedSelect<T>(_ a:inout [T], _ low:Int,_ high:Int,_ k:Int)->T{
    if(low < high){
        return a[low]
    }else{
        return a[high]
    }
}

print(randomizedSelect(&a1, 0, a1.count-1,4))

//: [Next](@next)
