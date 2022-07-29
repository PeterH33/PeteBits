//
//  File.swift
//  
//
//  Created by Peter Hartnett on 7/22/22.
//

import Foundation


///Wrapper for NSCountedSet to provide type safety
struct PBCountedSet<T: Any> {
    let internalSet = NSCountedSet()
    
    mutating func add(_ obj: T) {
        internalSet.add(obj)
    }
    
    mutating func remove(_ obj: T) {
        internalSet.remove(obj)
    }
    
    func count(for obj: T) -> Int {
        return internalSet.count(for: obj)
    }
}

public extension Array where Element : Hashable{
    ///Returns filtered array removing all duplicates
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        return filter { addedDict.updateValue(true, forKey: $0) == nil}
    }
    ///Removes all duplicates from an array in place.
    mutating func removeDuplicates(){
        self = self.removingDuplicates()
    }
}
