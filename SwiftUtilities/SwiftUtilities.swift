//
//  SwiftUtilities.swift
//  SwiftUtilities
//
//  Created by Stephen Donnell on 7/15/15.
//  Copyright (c) 2015 Stephen Donnell. All rights reserved.
//


import Foundation

// MARK: Aliases

public class $ {

    // MARK: Collections
    
    /**
    Iterates over an array of elements, yielding each in turn to the iteratee function.  Each iteratee function is called with 3 arguments: (value, index and array)
    */
    public class func each<T>(array:[T], iteratee:(value:T, index:Int, array:[T]) -> Void) {
        for var i = 0; i < array.count; i++ {
            iteratee(value: array[i], index: i, array: array)
        }
    }
    
    /**
    Iterates over an array of elements in reverse order, yielding each in turn to the iteratee function.  Each iteratee function is called with 3 arguments: (value, index and array)
    */
    public class func eachReverse<T>(array:[T], iteratee:(value:T, index:Int, array:[T]) -> Void) {
        for var i = array.count - 1; i >= 0; i-- {
            iteratee(value: array[i], index: i, array: array)
        }
    }
    
    /**
    Iterates over a dictionary of elements, yielding each in turn to the iteratee function.  Each iteratee function is called with 3 arguments: (value, key, dictionary)
    */
    public class func each<K,V>(dictionary:[K:V], iteratee:(value:V, key:K, dictionary:[K:V]) -> Void) {
        for (key, val) in dictionary {
            iteratee(value: val, key: key, dictionary: dictionary)
        }
    }
    
    /**
    Returns a new array that has been generated using the iteratee function.  The iteratee function is passed in each element in the array sequentially.
    */
    public class func map<T>(array:[T], iteratee:(value:T, index:Int, array:[T]) -> T) -> [T] {
        var rtn = [T]()
        
        $.each(array) { (value, index, array) -> Void in
            rtn.append(iteratee(value: value, index:index, array:array))
        }
        
        return rtn
    }
    
    /**
    Reduces an array down to a single value through the use of an iteratee
    */
    public class func reduce<T>(array:[T], iteratee:(memo:T, value:T, index:Int, array:[T]) -> T, initial:T) -> T {
        var rtn = initial
        
        $.each(array, iteratee: { (value, index, array) -> Void in
            rtn = iteratee(memo: rtn, value: value, index: index, array: array)
        })
        
        return rtn
    }
    
    /**
    Reduces an array down to a single value, starting iteration from the last value in the array
    */
    public class func reduceRight<T>(array:[T], iteratee:(memo:T, value:T, index:Int, array:[T]) -> T, initial:T) -> T  {
        var rtn = initial
        
        $.eachReverse(array, iteratee: { (value, index, array) -> Void in
            rtn = iteratee(memo: rtn, value: value, index: index, array: array)
        })
        
        return rtn
    }
    
    /**
    Looks through each value in the array, returning the first one that passes the predicate's test, or nil if no objects pass.
    */
    public class func find<T>(array:[T], predicate:(value:T, index:Int, array:[T]) -> Bool) -> T? {
        for var i = 0; i < array.count; i++ {
            if predicate(value: array[i], index: i, array: array) {
                return array[i]
            }
        }
        
        return nil
    }
    
    /**
    Looks through each value in the array, returning an array of all elements that matched the predicate's test.
    */
    public class func filter<T>(array:[T], predicate:(value:T, index:Int, array:[T]) -> Bool) -> [T] {
        var rtn = [T]()
        
        $.each(array, iteratee: { (value, index, array) -> Void in
            if predicate(value: value, index: index, array: array) {
                rtn.append(value)
            }
        })
        
        return rtn
    }
    
    /**
    Returns all objects in the passed in colleciton that match the properties provided
    */
    public class func filterWhere<K, V:AnyObject>(array:[[K:V]], properties:[K:V]) -> [[K:V]] {
        var keys = $.keys(properties)
        
        return $.filter(array, predicate: { (obj, index, array) -> Bool in
            return $.every(keys, predicate: { (key, idx, arr) -> Bool in
                return $.isEqual(properties[key], objB: obj[key])
            })
        })
    }
    
    /**
    Returns the first object or nil in the passed in colleciton that match the properties provided
    */
    public class func findWhere<K, V:AnyObject>(array:[[K:V]], properties:[K:V]) -> [K:V]? {
        var keys = $.keys(properties)
        
        return $.find(array, predicate: { (obj, index, array) -> Bool in
            return $.every(keys, predicate: { (key, idx, arr) -> Bool in
                return $.isEqual(properties[key], objB: obj[key])
            })
        })
    }
    
    /**
    Looks through each value in the array, returing an array of all elements that failed the predicates' test.
    */
    public class func reject<T>(array:[T], predicate:(value:T, index:Int, array:[T]) -> Bool) -> [T] {
        var rtn = [T]()
        
        $.each(array, iteratee: { (value, index, array) -> Void in
            if !predicate(value: value, index: index, array: array) {
                rtn.append(value)
            }
        })
        
        return rtn
    }
    
    /**
    Looks through each value in the array, and checks if it passes the predicate's test.  If all values passed, the function returns true, otherwise the function returns false.
    */
    public class func every<T>(array:[T], predicate:(value:T, index:Int, array:[T]) -> Bool) -> Bool {
        return $.filter(array, predicate: predicate).count == array.count
    }
    
    /**
    Returns true if atleast one element in the array passes the predicates test.
    */
    public class func some<T>(array:[T], predicate:(value:T, index:Int, array:[T]) -> Bool) -> Bool {
        return $.find(array, predicate: predicate) != nil
    }
    
    /**
    Returns true if the element passed in exists in the array
    */
    public class func contains<T:AnyObject>(array:[T], value:T) -> Bool {
        return $.indexOf(array, value: value) != nil
    }
    
    /**
    Manipulates the array's values directly.  Invokes the iteratee function on each array element.
    */
    public class func invoke<T>(inout array:[T], iteratee:(value:T, index:Int, array:[T]) -> T) -> [T] {
        $.each(array) { (value, index, arr) -> Void in
            array[index] = iteratee(value: value, index: index, array: arr)
        }
        
        return array
    }
    
    /**
    Extracts an array of property values for the passed in key from an array of dictionaries
    */
    public class func pluck<K, V>(objects:[[K:V]], key:K) -> [V] {
        var rtn = [V]()
        
        $.each( objects ) { (value, index, array) -> () in
            if let prop = $.property(key)(value) {
                rtn.append(prop)
            }
        }
        
        return rtn
    }
    
    /**
    Returns the maximum value in an array, based on the passed in comparator
    */
    public class func max<T>(array:[T], comparator:(valA:T, valB:T) -> Int) -> T {
        return $.last($.sortBy(array, comparator: comparator), length: 1)[0]
    }
    
    /**
    Returns the maximum value in an array, based on the passed in comparator, uses map to return an array of values specified using the iteratee.
    */
    public class func max<T>(array:[T], iteratee:(value:T, index:Int, array:[T]) -> T, comparator:(valA:T, valB:T) -> Int ) -> T {
        return $.max( $.map(array, iteratee: iteratee), comparator: comparator )
    }
    
    /**
    Returns the minimum value in an array, based on the passed in comparator
    */
    public class func min<T>(array:[T], comparator:(valA:T, valB:T) -> Int) -> T {
        return $.first($.sortBy(array, comparator: comparator), length: 1)[0]
    }
    
    /**
    Returns the minimum value in an array, based on the passed in comparator, uses map to return an array of values specified using the iteratee
    */
    public class func min<T>(array:[T], iteratee:(value:T, index:Int, array:[T]) -> T, comparator:(valA:T, valB:T) -> Int ) -> T {
        return $.min( $.map(array, iteratee: iteratee), comparator: comparator )
    }
    
    /**
    Returns a sorted version of the passed in array.  The comparator is called, and should return a value of less than 0, 0 or greater than 0 to indiciate sort order.  A value < 0 indicates A comes before B, a value of 0 means both elements are equal, and a value of > 0 indicates A comes after B.
    */
    public class func sortBy<T>(array:[T], comparator:(valA:T, valB:T) -> Int) -> [T] {
        var rtn = [T]()
        
        $.each( array ) { (value, index, array) -> () in
            if index == 0 {
                rtn.append(value)
            }
            else {
                var idx     = 0
                var order   = comparator(valA: value, valB: rtn[idx])
                while order > 0 && ++idx < rtn.count {
                    order = comparator(valA: value, valB: rtn[idx])
                }
                rtn.insert(value, atIndex: idx)
            }
        }
        
        return rtn
    }
    
    /**
    Groups elements in the passed in array based on the result of the iteratee function.
    */
    public class func groupBy<T, R:Hashable>(array:[T], iteratee:(value:T, index:Int, array:[T]) -> R?) -> [R:[T]] {
        var rtn = [R:[T]]()
        
        $.each( array ) { (value, index, array) -> () in
            if let groupId = iteratee(value: value, index: index, array: array) {
                if rtn[groupId] != nil {
                    rtn[groupId]!.append(value)
                }
                else {
                    rtn[groupId] = [value]
                }
            }
        }
        
        return rtn
    }
    
    /**
    similar to group by, but when you know the key values are unique.
    */
    public class func indexBy<T, R:Hashable>(array:[T], iteratee:(value:T, index:Int, array:[T]) -> R?) -> [R:T] {
        var rtn = [R:T]()
        
        $.each( array ) { (value, idx, array) in
            if let indexId = iteratee(value: value, index: idx, array: array) {
                rtn[indexId] = value
            }
        }
        
        return rtn
    }
    
    /**
    Groups elements in the passed in array based on the result of the iteratee function.
    */
    public class func countBy<T, R:Hashable>(array:[T], iteratee:(value:T, index:Int, array:[T]) -> R?) -> [R:Int] {
        var rtn = [R:Int]()
        
        $.each( array ) { (value, index, array) in
            if let groupId = iteratee(value: value, index: index, array: array) {
                if rtn[groupId] != nil {
                    rtn[groupId]! += 1
                }
                else {
                    rtn[groupId] = 1
                }
            }
        }
        
        return rtn
    }
    
    /**
    Shuffles the passed in array in a random order using the Fisher-Yates method.
    */
    public class func shuffle<T>(array:[T]) -> [T] {
        var rtn = array
        
        for var i = 0, rand:Int; i < array.count; i++ {
            rand = $.random(0, end: i)
            if rand != i {
                rtn[i] = rtn[rand]
            }
            rtn[rand] = array[i]
        }
        
        return rtn
    }
    
    /**
    Returns a random sample, up to the provided length ( or 1 if no length is provided )
    */
    public class func sample<T>(array:[T], length:Int = 1) -> [T] {
        var shuffled = $.shuffle( array )
        var rtn = [T]()
        
        for ( var i = 0; i < length && i < shuffled.count; i++ ) {
            rtn.append( shuffled[i] )
        }
        
        return rtn
    }
    
    /**
    Returns the number of items in an array
    */
    public class func size<T>(array:[T]) -> Int {
        return array.count
    }
    
    
    /**
    Partitions an array into pass/fail groups, where group 0 pased the predicate, and group 1 failed
    */
    public class func partition<T>(array:[T], predicate:(value:T, index:Int, array:[T]) -> Bool) -> [Int:[T]] {
        return $.groupBy(array) { (value, index, array) -> Int? in
            return predicate(value: value, index: index, array: array) ? 0 : 1
        }
    }
    
    
    // MARK: Array Functions
    
    /**
    Returns the first element(s) up to the length parameter in the given array.
    */
    public class func first<T>(array:[T], length:Int = 1) -> [T] {
        var rtn = [T]()
        
        for var i = 0; i < length && i < array.count; i++ {
            rtn.append(array[i])
        }
        
        return rtn
    }
    
    /**
    Returns everything but the last element in the array.  If a length property is populated, all but the last x elements are returned.
    */
    public class func initial<T>(array:[T], length:Int = 1) -> [T] {
        var rtn = [T]()
        
        for var i = 0; i < array.count - length; i++ {
            rtn.append(array[i])
        }
        
        return rtn
    }
    
    /**
    Returns the last element of the array, or last n elements if a length if specified
    */
    public class func last<T>(array:[T], length:Int = 1) -> [T] {
        var rtn = [T]()
        
        for var i = array.count - 1; i >= 0 && rtn.count < length; i-- {
            rtn.insert(array[i], atIndex: 0)
        }
        
        return rtn
    }
    
    /**
    Returns all elements from the specified index to the end of the array.
    */
    public class func rest<T>(array:[T], index:Int = 0) -> [T] {
        var rtn = [T]()
        
        for var i = index; i < array.count; i++ {
            rtn.append(array[i])
        }
        
        return rtn
    }
    
    /**
    Removes all falsey values from the array
    */
    public class func compact<T>(array:[T]) -> [T] {
        var rtn = [T]()
        
        $.each(array, iteratee: { (elem, index, array) -> Void in
            var isNull  = ( elem is NSNull )
            var isZero  = ( elem as? Int ) == 0
            var isEmptyString = ( elem as? String ) == ""
            
            if !isNull && !isZero && !isEmptyString {
                rtn.append( elem )
            }
        })
        
        return rtn
    }
    
    /**
    Recursivley flattens a nested array, down into a single 1 dimensional array.
    */
    public class func flatten<T>(array:[T]) -> [T] {
        var rtn = [T]()
        
        $.each( array ) { (elem, index, array) -> Void in
            if let elemAsArray = elem as? [T] {
                rtn.extend( $.flatten( elemAsArray ) )
            }
            else {
                rtn.append( elem )
            }
        }
        
        return rtn
    }
    
    /**
    Returns all elements from the first array that don't exist in the excluded values.
    */
    public class func without<T:AnyObject>(array:[T], exclude:T...) -> [T] {
        var rtn = [T]()
        
        $.each(array) { (value, index, array) -> () in
            if !$.contains(exclude, value: value) {
                rtn.append(value)
            }
        }
        
        return rtn
    }
    
    /**
    Returns an array of unique items between the list of passed in arrays
    */
    public class func union<T:AnyObject>(arrays:[T]...) -> [T] {
        var rtn = [T]()
        
        $.each( arrays ) { (array, index, arrays) -> Void in
            $.each( array ) { (value, index, array) -> Void in
                if !$.contains(rtn, value: value) {
                    rtn.append( value )
                }
            }
        }
        
        return rtn
    }
    
    /**
    Returns an array of all values that are present in each of the passed in arrays.
    */
    public class func intersection<T:AnyObject>(arrays:[T]...) -> [T] {
        var rtn = [T]()
        
        $.each( arrays ) { (array, index, arrays) -> Void in
            $.each( array ) { (value, index, array) -> Void in
                if !$.contains(rtn, value: value) {
                    if $.every(arrays, predicate: { (arr, index, arrays) -> Bool in
                        return $.contains(arr, value: value)
                    }) {
                        rtn.append( value )
                    }
                }
            }
        }
        
        return rtn
    }
    
    /**
    Returns an array of values that exist in the first array, but not any of the other arrays
    */
    public class func difference<T:AnyObject>(array:[T], others:[T]...) -> [T] {
        var rtn = [T]()
        
        $.each( array ) { (value, index, array) -> Void in
            if !$.contains(rtn, value: value) {
                if !$.some( others, predicate: { (innerArray, index, arrays) -> Bool in
                    if $.isEqual(innerArray, objB: array) {
                        return false
                    }
                    
                    return $.contains(innerArray, value: value)
                }) {
                    rtn.append( value )
                }
            }
        }
        
        return rtn
    }
    
    /**
    Produces a duplicate free version of array.
    */
    public class func uniq<T:AnyObject>(array:[T]) -> [T] {
        var rtn = [T]()
        
        $.each(array, iteratee: { (value, index, array) -> Void in
            if !$.contains(rtn, value: value) {
                rtn.append( value )
            }
        })
        
        return rtn
    }
    
    /**
    Merges together the values of each of the arrays with the values at the corresponding position. Useful when you have separate data sources that are coordinated through matching array indexes.
    */
    public class func zip<T>(arrays:[T]...) -> [[T]] {
        var rtn = [[T]]()
        
        $.each(arrays) { (value, index, array) -> Void in
            $.each(value) { (innerValue, innerIndex, innerArray) -> Void in
                if ( index == 0 ) {
                    rtn.append( [T]() )
                }
                
                rtn[innerIndex].append( innerValue )
            }
        }
        
        return rtn
    }
    
    /**
    The opposite of zip. Given a number of arrays, returns a series of new arrays, the first of which contains all of the first elements in the input arrays, the second of which contains all of the second elements, and so on.
    */
    public class func unzip<T>(arrays:[T]...) -> [[T]] {
        var rtn = [[T]]()
        
        $.each(arrays) { (value, index, array) -> Void in
            $.each(value) { (innerValue, innerIndex, innerArray) -> Void in
                if ( index == 0 ) {
                    rtn.append( [T]() )
                }
                
                rtn[innerIndex].append( innerValue )
            }
        }
        
        return rtn
    }
    
    /**
    Returns the index of the specified element in the array, or nil of not found.
    */
    public class func indexOf<T:AnyObject>(array:[T], value:T) -> Int? {
        for var i = 0; i < array.count; i++ {
            if $.isEqual(value, objB: array[i]) {
                return i
            }
        }
        
        return nil
    }
    
    /**
    Returns the last index of the specified element in the array, or nil if not found.
    */
    public class func lastIndexOf<T:AnyObject>(array:[T], value:T) -> Int? {
        for var i = array.count - 1; i >= 0; i-- {
            if $.isEqual(value, objB: array[i]) {
                return i
            }
        }
        
        return nil
    }
    
    
    /**
    Uses a binary search to determine the index at which the value should be inserted into the list in order to maintain the list's sorted order.
    */
    public class func sortedIndex<T:Comparable>(array:[T], value:T) -> Int? {
        var sorted = $.sortBy( array + [value] ) { (valA, valB) -> Int in
            return valA > valB ? 1 : -1
        }
        
        for var i = 0; i < sorted.count; i++ {
            if value == sorted[i] {
                return i
            }
        }
        
        return nil
    }
    
    //    public class func sortedIndex<K, V>(array:[[K:V]], iteratee:(value:[K:V], array:[[K:V]]) -> Int, value:[K:V]) -> Int? {
    //
    //        var mapped = $.map(<#array: [T]#>, iteratee: <#(value: T, index: Int, array: [T]) -> T##(value: T, index: Int, array: [T]) -> T#>)
    //        var sorted = $.sortBy( array ) { (objA, objB) -> Int in
    //            var valA = iteratee(value: objA, array: array)
    //            var valB = iteratee(value: objB, array: array)
    //            return valA > valB ? 1 : -1
    //        }
    //
    //        var val = iteratee(value: value, array: array)
    //        return $.indexOf(sorted, value: val)
    //    }
    
    /**
    Similar to indexOf, but uses a predicate test.
    */
    public class func findIndex<T>(array:[T], predicate:(value:T, index:Int, array:[T]) -> Bool) -> Int? {
        for var i = 0; i < array.count; i++ {
            if predicate(value: array[i], index: i, array: array) {
                return i
            }
        }
        
        return nil
    }
    
    /**
    Similar to lastIndexOf, but uses a predicate test.
    */
    public class func findLastIndex<T>(array:[T], predicate:(value:T, index:Int, array:[T]) -> Bool) -> Int? {
        for var i = array.count - 1; i >= 0; i-- {
            if predicate(value: array[i], index: i, array: array) {
                return i
            }
        }
        
        return nil
    }
    
    /**
    Returns an array containing a range of numbers, starting from start, to stop incremented by a step
    */
    public class func range(start:Int, stop:Int, step:Int) -> [Int] {
        var rtn = [Int]()
        
        for var i = start; i <= stop; i += step {
            rtn.append( i )
        }
        
        return rtn
    }
    
    /**
    Returns an array containing a range of numbers, starting from start, to stop incremented by a step
    */
    public class func range(start:Float, stop:Float, step:Float) -> [Float] {
        var rtn = [Float]()
        
        for var i = start; i <= stop; i += step {
            rtn.append( i )
        }
        
        return rtn
    }
    
    // MARK: Object Functions
    
    /**
    Returns an array of key's from a dictionary object.
    */
    public class func keys<K,V>(dictionary:[K:V]) -> [K] {
        var rtn = [K]()
        
        $.each( dictionary ) { (value, key, dictionary) in
            rtn.append(key)
        }
        
        return rtn
    }
    
    /**
    Returns an array of all values from a dictionary object
    */
    public class func values<K,V>(dictionary:[K:V]) -> [V] {
        var rtn = [V]()
        
        $.each(dictionary, iteratee: { (value, key, dictionary) in
            rtn.append( value )
        })
        
        return rtn
    }
    
    /**
    Returns a new hash that has been generated using the iteratee function against the passed in dictionary.  The iteratee function is passed in each element in the dictionary sequentially.
    */
    public class func mapObject<K, V>(dictionary:[K:V], iteratee:(value:V, key:K, dictionary:[K:V]) -> V?) -> [K:V] {
        var rtn = [K:V]()
        
        $.each( dictionary ) { (value, key, dictionary) in
            if let value = iteratee(value: value, key: key, dictionary: dictionary) {
                rtn[key] = value
            }
        }
        
        return rtn
    }
    
    /**
    Converts a dictionary into an array of key-value pairs
    */
    public class func pairs<T>(dictionary:[T:T]) -> [[T]] {
        var rtn = [[T]]()
        
        $.each(dictionary) { (value, key, dictionary) -> Void in
            rtn.append( [key, value] )
        }
        
        return rtn
    }
    
    /**
    Returns a copy of the object where the keys and values are swapped
    */
    public class func invert<K, V:Hashable>(dictionary:[K:V]) -> [V:K] {
        var rtn = [V:K]()
        
        $.each( dictionary ) { (value, key, dictionary) -> Void in
            rtn[value] = key
        }
        
        return rtn
    }
    
    /**
    Similar to find index, where the key that matches the predicate is returned
    */
    public class func findKey<K, V>(dictionary:[K:V], predicate:(value:V, key:K, dictionary:[K:V]) -> Bool) -> K? {
        for ( key, value ) in dictionary {
            if predicate(value: value, key: key, dictionary: dictionary) {
                return key
            }
        }
        
        return nil
    }
    
    /**
    Similar to filterIndex, where an array of all keys that match the predicate are returned
    */
    public class func filterKeys<K, V>(dictionary:[K:V], predicate:(value:V, key:K, dictionary:[K:V]) -> Bool) -> [K] {
        var rtn = [K]()
        
        for ( key, value ) in dictionary {
            if predicate(value: value, key: key, dictionary: dictionary) {
                rtn.append( key )
            }
        }
        
        return rtn
    }
    
    /*
    Adds all entries from the second object to the first object.  Similar to defaults,
    but it always overwrites with the second objects values.
    
    :param: destination Hash object to add entries to
    :param: source Hash object(s) containing entries to add to the destination object
    
    :returns: Hash destination + source
    */
    public class func extend<K, V>(destination:[K:V], sources:[K:V]...) -> [K:V] {
        var rtn = destination
        
        $.each( sources ) {(value, index, dictionary) in
            $.each( value ) {(value, key, dictionary )  in
                rtn[key] = value
            }
        }
        
        return rtn
    }
    
    /**
    Returns an object containing only the whitelisted keys.
    */
    public class func pick<K:AnyObject, V>(dictionary:[K:V], properties:K...) -> [K:V] {
        var rtn = [K:V]()
        
        $.each(dictionary, iteratee: { (value, key, dictionary)  in
            if $.contains(properties, value: key) {
                rtn[key] = value
            }
        })
        
        return rtn
    }
    
    /**
    Returns an object containing only the whitelisted keys, where the key passes a predicate
    */
    public class func pick<K, V>(dictionary:[K:V], predicate:(value:V, key:K, dictionary:[K:V]) -> Bool) -> [K:V] {
        var rtn = [K:V]()
        
        $.each(dictionary, iteratee: { (value, key, dictionary) in
            if predicate(value: value, key: key, dictionary: dictionary) {
                rtn[key] = value
            }
        })
        
        return rtn
    }
    
    /**
    Returns a copy of the object, filtered to omit the blacklisted keys.
    */
    public class func omit<K:AnyObject, V>(dictionary:[K:V], properties:K...) -> [K:V] {
        var rtn = [K:V]()
        
        $.each(dictionary, iteratee: { (value, key, dictionary) in
            if !$.contains(properties, value: key) {
                rtn[key] = value
            }
        })
        
        return rtn
    }
    
    /**
    Returns a copy of the object, filtered to omit the blacklisted keys (where predicate returns true)
    */
    public class func omit<K, V>(dictionary:[K:V], predicate:(value:V, key:K, dictionary:[K:V]) -> Bool) -> [K:V] {
        var rtn = [K:V]()
        
        $.each(dictionary, iteratee: { (value, key, dictionary) in
            if !predicate(value: value, key: key, dictionary: dictionary) {
                rtn[key] = value
            }
        })
        
        return rtn
    }
    
    /*
    Fills in undefined properties in the Hash
    
    :param: object Hash object to fill in with defaults
    :param: defaults Hash object(s) containing default values
    
    :returns: Hash object + defaults
    */
    public class func defaults<K, V>(destination:[K:V], defaults:[K:V]...) -> [K:V] {
        var rtn = destination
        
        $.each( defaults ) { (innerDefaults, value, dictionary) in
            $.each( innerDefaults ) {(value, key, dictionary) in
                if rtn[key] == nil {
                    rtn[key] = value
                }
            }
        }
        
        return rtn
    }
    
    /**
    Returns true if the dictionary contains the defined key
    */
    public class func has<K, V>(dictionary:[K:V], key:K) -> Bool {
        return dictionary[key] != nil
    }
    
    /**
    Returns a curried function that accepts an object and returns the value of the specified curried key.
    */
    public class func property<K, V>(key:K) -> ([K:V]) -> V? {
        return { (object:[K:V]) -> V? in
            return object[key]
        }
    }
    
    /**
    Inverse of property, takes a dictionary, and returns a function that accepts a key and returns the value of the key using the dictionary
    */
    public class func propertyOf<K, V>(dictionary:[K:V]) -> (K) -> V? {
        return { (key:K) -> V? in
            return dictionary[key]
        }
    }
    
    /**
    Returns a predicate function that will tell if you if the passed in object contains all of the attributes
    */
    public class func matcher<K, V>(attributes:[K]) -> ((V, K, [K:V]) -> Bool) {
        return { (value:V, key:K, dictionary:[K:V]) -> Bool in
            return $.every(attributes, predicate: { (value, index, array) -> Bool in
                return $.has(dictionary, key: value)
            })
        }
    }
    
    /**
    Checks to see if two AnyObjects are equal to each other.
    */
    public class func isEqual(objA:AnyObject?, objB:AnyObject?) -> Bool {
        // Attemp to convert objects to NSObjects
        if let nsObjA = objA as? NSObject {
            return nsObjA.isEqual(objB)
        }
        else if let nsObjB = objB as? NSObject {
            return nsObjB.isEqual(objA)
        }
        else {
            // Check if identical
            return $.isIdentical(objA, objB: objB)
        }
    }
    
    /**
    Checks if two AnyObject's are identical to each other.
    */
    public class func isIdentical(objA:AnyObject?, objB:AnyObject?) -> Bool {
        return objA === objB
    }
    
    /**
    Returns true if the array has no members
    */
    public class func isEmpty<T>(array:[T]) -> Bool {
        return array.count == 0
    }
    
    /**
    Returns true if the dictionary has no keys
    */
    public class func isEmpty<K, V>(dictionary:[K:V]) -> Bool {
        return $.isEmpty( $.keys( dictionary) )
    }
    
    /* TODO: Work on comparison
    Compares the first object against the second object and returns all properties from Hash 1
    that don't match the property value in Hash 2
    
    :param: source Hash to compare to comparison
    :param: comparison Hash to compare against
    
    :returns: Hash all differences in source relative to comparison
    */
    public class func difference<K, V:AnyObject>(source:[K:V], comparison:[K:V]) -> [K:V] {
        var rtn = [K:V]()
        
        $.each( source ) { (value, key, dictionary) in
            if !$.isEqual(comparison[key], objB: value) {
                rtn[key] = value
            }
        }
        
        return rtn
    }
    
    
    // MARK: Utility Functions
    
    /**
    Generates a random integer between the start and end value, inclusive.
    */
    public class func random(start:Int, end:Int) -> Int {
        return Int(arc4random_uniform(UInt32(end))) + start
    }
    
    /**
    Generates a unique ID
    */
    public class func uniqueId() -> String {
        return NSUUID().UUIDString
    }
    
    /**
    Returns the value of the key in the dictionary, or the optional default value provided
    */
    public class func result<K, V>(dictionary:[K:V], key:K, defaultValue:V? = nil) -> V? {
        return $.has(dictionary, key: key) ? dictionary[key] : defaultValue
    }
    
    /**
    Allows for executing multiple functions against a single object, where that object is returned at the end of each execution
    */
    public class func chain<T>(object:T, function:((object:T)->Any?)...) -> T {
        $.each( function ) { (fn, index, array) -> () in
            var obj = fn(object: object)
        }
        
        return object
    }
}
