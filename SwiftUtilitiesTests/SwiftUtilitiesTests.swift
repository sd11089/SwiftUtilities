//
//  SwiftUtilitiesTests.swift
//  SwiftUtilitiesTests
//
//  Created by Stephen Donnell on 7/15/15.
//  Copyright (c) 2015 Stephen Donnell. All rights reserved.
//

import UIKit
import XCTest
import SwiftUtilities

class SwiftUtilitiesTests: XCTestCase {
    
    private var mixedCollection:[[String:AnyObject]] = [
        ["name" : "Moe", "age" : 40, "started" : 1932],
        ["name" : "Larry", "age" : 50, "started" : 1930],
        ["name" : "Curly", "age" : 60, "started" : 1932]
    ]
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Collection Tests
    
    func testEachArray() {
        var count = 0
        
        $.each( [1, 2, 3] ) { (value, index, array) -> Void in
            count += 1
        }
        
        XCTAssert( count == 3, "each item iterated over in array" )
    }
    
    func testEachDictionary() {
        var count = 0
        
        $.each( [
            "one" : 1,
            "two" : 2,
            "three" : 3
            ] ) { (value, key, dictionary) -> Void in
                count += 1
        }
        
        XCTAssert( count == 3, "each item iterated over in dictionary" )
    }
    
    func testMap() {
        var result = $.map( [1, 2, 3]) { (value, index, array) -> Int in
            return value * 3
        }
        
        XCTAssert( result == [3, 6, 9], "each item in array multiplied by 3" )
    }
    
    func testReduce() {
        var result = $.reduce( [1, 2, 3], iteratee: { (memo, value, index, array) -> Int in
            return memo + value
            }, initial: 0)
        
        XCTAssert( result == 6, "each item in array summed" )
    }
    
    func testReduceRight() {
        var result = $.reduceRight([[0, 1], [2, 3], [4, 5]], iteratee: { (memo:[Int], value:[Int], index, array) -> [Int] in
            return memo + value
            }, initial: [Int]())
        
        XCTAssert( result == [4, 5, 2, 3, 0, 1], "each item iterated over in reverse, and concatenated to the original array")
    }
    
    func testFind() {
        var result = $.find( [1, 2, 3], predicate: { (value, index, array) -> Bool in
            return value % 2 == 0
        })
        
        XCTAssert( result == 2, "returned first odd value")
    }
    
    func testFilter() {
        var result = $.filter( [1, 2, 3, 4, 5, 6], predicate: { (value, index, array) -> Bool in
            return value % 2 == 0
        })
        
        XCTAssert( result == [2, 4, 6], "returned all odd values")
    }
    
    func testFindWhere() {
        var result = $.findWhere(mixedCollection, properties: [
            "age" : 50
            ])
        
        XCTAssert( ( result!["name"] as? String ) == "Larry", "returned Larry")
    }
    
    func testFilterWhere() {
        var results = $.filterWhere(mixedCollection, properties: [
            "started" : 1932
            ])
        
        XCTAssert( results.count == 2, "returned moe and curly" )
    }
    
    func testReject() {
        var odds = $.reject( [1, 2, 3, 4, 5, 6], predicate: { (value, index, array) -> Bool in
            return value % 2 == 0
        })
        
        XCTAssert( odds == [1, 3, 5], "returned odds only")
    }
    
    func testEvery() {
        var allEven = $.every([2, 4, 6], predicate: { (value, index, array) -> Bool in
            return value % 2 == 0
        })
        
        XCTAssert( allEven, "all values are even")
    }
    
    func testSome() {
        var someEven = $.some( [1, 2, 3], predicate: { (value, index, array) -> Bool in
            return value % 2 == 0
        })
        
        XCTAssert( someEven, "some values are even" )
    }
    
    func testContains() {
        var contains = $.contains( [1, 2, 3], value: 2)
        XCTAssert( contains, "array contains 2")
    }
    
    // TODO: Test Invoke
    
    func testPluck() {
        var plucked = $.pluck(mixedCollection, key: "name")
        if plucked is [String] {
            XCTAssert(plucked as! [String] == ["Moe", "Larry", "Curly"], "returned names from collection")
        }
    }
    
    func testMax() {
        var max = $.max([1, 2, 3, 4, 5, 6], comparator: { (valA, valB) -> Int in
            return valA > valB ? 1 : -1
        })
        
        XCTAssert(max == 6, "max value is 6")
    }
    
    func testMin() {
        var min = $.min([1, 2, 3, 4, 5, 6], comparator: { (valA, valB) -> Int in
            return valA > valB ? 1 : -1
        })
        
        XCTAssert(min == 1, "max value is 6")
    }
    
    func testSortBy() {
        var sorted = $.sortBy([1, 2, 3], comparator: { (valA, valB) -> Int in
            return valA > valB ? -1 : 1
        })
        
        XCTAssert(sorted == [3, 2, 1], "sorted descending")
    }
    
    func testGroupBy() {
        var grouped = $.groupBy(mixedCollection, iteratee: { (value, index, array) -> Int? in
            return value["started"] as? Int
        })
        
        XCTAssert(grouped[1932]?.count == 2, "two items exist with started = 1932")
    }
    
    func testIndexBy() {
        var indexed = $.indexBy(mixedCollection, iteratee: { (value, index, array) -> Int? in
            return value["age"] as? Int
        })
        
        XCTAssert(indexed[40]?["name"] as? String == "Moe", "Moe was indexed using age of 40")
    }
    
    func testCountBy() {
        var counted = $.countBy(mixedCollection, iteratee: { (value, index, array) -> Int? in
            return value["started"] as? Int
        })
        
        XCTAssert(counted[1932] == 2, "two records returned where started is equal to 1932")
    }
    
    func testSize() {
        XCTAssert($.size([1, 2, 3]) == 3, "size returns the length of an array")
    }
    
    func testPartition() {
        var partitioned = $.partition(mixedCollection, predicate: { (value, index, array) -> Bool in
            return value["started"] as? Int == 1932
        })
        
        XCTAssert(partitioned[0]?.count == 2, "two items in the collection match a started date of 1932")
    }
    
    
    // MARK: Array Tests
    
    func testFirst() {
        XCTAssert($.first([1, 2, 3], length: 2) == [1, 2], "returned first 2 elements of intArray")
    }
    
    func testInitial() {
        XCTAssert($.initial([1, 2, 3], length: 2) == [1], "only the first element was returned of intArray")
    }
    
    func testRest() {
        XCTAssert($.rest([1, 2, 3], index: 1) == [2, 3], "returned the last 2 elements of intArray")
    }
    
    func testCompact() {
        XCTAssert($.compact([0, 1, 2, 3]) == [1, 2, 3], "removed falsey values from array")
    }
    
    func testFlatten() {
        XCTAssert($.flatten([1, 2, [3, [4, 5]]]) == [1, 2, 3, 4, 5], "all arrays were flattened into a single dimension")
    }
    
    func testWithout() {
        XCTAssert($.without([1, 2, 3], exclude: 2, 3) == [1], "returned all elements in array except 2 and 3")
    }
    
    func testUnion() {
        XCTAssert($.union([1, 2, 3], [101, 2, 1, 10], [2, 1]) == [1, 2, 3, 101, 10], "pulled unique values out of the passed in arrays")
    }
    
    func testIntersection() {
        XCTAssert($.intersection([1, 2, 3], [101, 2, 1, 10], [2, 1]) ==  [1, 2], "intersection only included 1 and 2")
    }
    
    func testDifference() {
        XCTAssert($.difference([1, 2, 3, 4, 5], others: [5, 2, 10]) == [1, 3, 4], "items in array 1 that didn't exist in array 2 were 1, 3 and 4")
    }
    
    func testUniq() {
        XCTAssert($.uniq([1, 2, 1, 4, 1, 3]) == [1, 2, 4, 3], "only unique values returned, in order")
    }
    
    func testZip() {
        XCTAssert($.zip(["moe", "larry", "curly"], [30, 40, 50], [true, false, false]) == [["moe", 30, true], ["larry", 40, false], ["curly", 50, false]], "zipped up arrays")
    }
    
    func testUnzip() {
        XCTAssert($.unzip(["moe", 30, true], ["larry", 40, false], ["curly", 50, false]) == [["moe", "larry", "curly"], [30, 40, 50], [true, false, false]], "unzipped arrays" )
    }
    
    func testIndexOf() {
        XCTAssert($.indexOf([1, 2, 3], value: 2) == 1, "Index of 2 is 1")
    }
    
    func testLastIndexOf() {
        XCTAssert($.lastIndexOf([1, 2, 3, 1, 2, 3], value: 2) == 4, "Last index of 2 is 4")
    }
    
    func testSortedIndex() {
        XCTAssert($.sortedIndex([10, 20, 30, 40, 50], value: 35) == 3, "Sorted index, 35 would be at index 3")
    }
    
    func testFindIndex() {
        var index:Int? = $.findIndex( [1, 2, 3], predicate: { (value, index, array) -> Bool in
            return value % 2 == 0
        })
        
        XCTAssert(index == 1, "first passed predicate is when x == 2")
    }
    
    func testFindLastIndex() {
        var index:Int? = $.findLastIndex([1, 2, 3, 1, 2, 3], predicate: { (value, index, array) -> Bool in
            return value == 2
        })
        
        XCTAssert(index == 4, "last index of 2 is 4")
    }
    
    func testRange() {
        var range = $.range(0, stop: 3, step: 1)
        XCTAssert(range == [0, 1, 2, 3], "range from 0 to 3, incrementing by 1 returned")
    }
    
    
    // MARK: Object Tests
    
    func testKeys() {
        XCTAssert($.keys(["one": 1, "two" : 2, "three" : 3]).count == 3, "keys from dictionary returned")
    }
    
    func testValues() {
        XCTAssert($.values(["one": 1, "two" : 2, "three" : 3]).count == 3, "keys from dictionary returned")
    }
    
    func testMapObject() {
        var mappedObject = $.mapObject(["start": 5, "end": 12], iteratee: { (value, key, dictionary) -> Int? in
            return value + 5
        })
        
        XCTAssert(mappedObject["start"] == 10, "all values in object were incremented by 5")
        
    }
    
    func testPairs() {
        var pairs = $.pairs(["one": 1, "three" : 3])
        XCTAssert(pairs == [["one", 1], ["three", 3]], "returned pairs of key-values from dictionary")
    }
    
    func testInvert() {
        var inverted = $.invert(["Moe": "Moses", "Larry": "Louis"])
        XCTAssert(inverted["Moses"] == "Moe", "swapped all keys and values")
    }
    
    func testFindKey() {
        var key = $.findKey(["one": 1, "two" : 2, "three" : 3], predicate: { (value, key, dictionary) -> Bool in
            return value % 2 == 0
        })
        
        XCTAssert(key == "two", "returned the only key with an even value")
    }
    
    func testFilterKey() {
        var keys = $.filterKeys(["one": 1, "two" : 2, "three" : 3], predicate: { (value, key, dictionary) -> Bool in
            return value % 2 != 0
        })
        
        XCTAssert(keys == ["one", "three"], "returned 2 keys where their values were odd")
    }
    
    func testExtend() {
        var source = ["one": 1]
        var extendedObj = $.extend(source, sources: ["two" : 2], ["three" : 3])
        XCTAssert($.has(extendedObj, key: "three"), "extended object contains key 'three'")
    }
    
    func testPick() {
        var picked = $.pick(["one" : 1, "two": 2, "three" : 3], properties: "one", "two")
        XCTAssert($.has(picked, key: "one") && !$.has(picked, key: "three"), "picked dictionary has 'one', but not 'three'")
    }
    
    func testOmit() {
        var picked = $.omit(["one" : 1, "two": 2, "three" : 3], properties: "three")
        XCTAssert($.has(picked, key: "one") && !$.has(picked, key: "three"), "ommited dictionary has 'one', but not 'three'")
    }
    
    func testDefaults() {
        var source = ["one" : 1, "two": 2]
        var defaulted = $.defaults(source, defaults: ["two" : 12, "three" : 3])
        XCTAssert(defaulted["two"] == 2 && defaulted["three"] == 3, "defaults defaulted value for 3, and kept the value for 2")
    }
    
    func testHas() {
        XCTAssert($.has(["one" : 1, "two" : 2], key: "two"), "dictionary has key two")
    }
    
    func testProperty() {
        var fn = $.property("one") as ([String:Int] -> Int?)
        XCTAssert(fn(["one" : 1]) == 1, "returned the value for property 'one'")
    }
    
    func testPropertyOf() {
        var fn = $.propertyOf(["one" : 1])
        XCTAssert(fn("one") == 1, "returned the value for property 'one'")
    }
    
    func testMatcher() {
        var matcher = $.matcher( ["one", "two"] ) as ((Int, String, [String:Int]) -> Bool)
        XCTAssert( matcher(0, "", ["one" : 1, "two" : 2]) == true, "matcher returned function that could be used to determine if all properties exist")
    }
    
}
