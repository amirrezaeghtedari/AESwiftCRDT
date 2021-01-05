//
//  CRDTDictionaryTests.swift
//  CRDTDictionaryTests
//
//  Created by Amirreza Eghtedari on 10/3/1399 AP.
//

import XCTest
@testable import AESwiftCRDT

class AEDictionaryTests: XCTestCase {

	//sut: System Under Test
	
	//test simple add and remove without time racing with success result
    func test_addAndRemove_success() throws {
        
		var sut = AEDictionary<Int, String>(bias: .add)
		
		XCTAssertNil(sut.value(key: 999))
		
		//test add
		sut.add(key: 1, value: "Amir")
		sut.add(key: 2, value: "Baran")
		XCTAssert(sut.value(key: 1) == "Amir")
		XCTAssert(sut.value(key: 2) == "Baran")
		
		//test update
		sut.add(key: 1, value: "Max")
		XCTAssert(sut.value(key: 1) == "Max")
		
		//test remove
		sut.remove(key: 1)
		XCTAssertNil(sut.value(key: 1))
		XCTAssert(sut.value(key: 2) == "Baran")
		
		//test update
		sut.add(key: 1, value: "Jack")
		XCTAssert(sut.value(key: 1) == "Jack")
		
		//test add again
		sut.add(key: 1, value: "Amir")
		XCTAssert(sut.value(key: 1) == "Amir")
		XCTAssert(sut.value(key: 2) == "Baran")
    }
	
	func test_synchronousOperationWithAddBias_success() {
		
		var sut = AEDictionary<Int, String>(bias: .add)
		
		let timestamp = Date()
		sut.add(key: 1, value: "Amir", timestamp: timestamp)
		sut.remove(key: 1, timestamp: timestamp)
		
		XCTAssert(sut.value(key: 1) == "Amir")
	}
	
	func test_synchronousOperationWithRemoveBias_success() {
		
		var sut = AEDictionary<Int, String>(bias: .remove)
		
		let timestamp = Date()
		sut.add(key: 1, value: "Amir", timestamp: timestamp)
		sut.remove(key: 1, timestamp: timestamp)
		
		XCTAssertNil(sut.value(key: 1))
	}
	
	//test basic merge operations
	func test_basicMerge_success() {
		
		var sut1 = AEDictionary<Int, String>(bias: .add)
		var sut2 = AEDictionary<Int, String>(bias: .add)
		
		sut1.add(key: 100, value: "BMW")
		sut1.add(key: 101, value: "Mercedes")
		sut1.add(key: 102, value: "Audi")
		
		//Test add operation
		sut2.add(key: 100, value: "Toyota")
		sut2.add(key: 202, value: "Mazda")
		sut2.add(key: 102, value: "Honda")
		
		sut1.merge(dictionary: sut2)
		
		XCTAssert(sut1.value(key: 100) == "Toyota")
		XCTAssert(sut1.value(key: 101) == "Mercedes")
		XCTAssert(sut1.value(key: 102) == "Honda")
		XCTAssert(sut1.value(key: 202) == "Mazda")
		
		//Test remove operation
		sut2.remove(key: 100)
		sut2.remove(key: 202)
		sut2.remove(key: 102)
		
		sut1.merge(dictionary: sut2)
		
		XCTAssertNil(sut1.value(key: 100))
		XCTAssert(sut1.value(key: 101) == "Mercedes")
		XCTAssertNil(sut1.value(key: 102))
		XCTAssertNil(sut1.value(key: 202))
	}

	//test merge is commutative
	func test_commutativeMerge_success() {
		
		var sut1 = AEDictionary<Int, String>(bias: .add)
		var sut2 = AEDictionary<Int, String>(bias: .add)
		
		sut1.add(key: 100, value: "BMW")
		sut1.add(key: 101, value: "Mercedes")
		sut1.add(key: 102, value: "Audi")
		
		sut2.add(key: 100, value: "Toyota")
		sut2.add(key: 202, value: "Mazda")
		sut2.add(key: 102, value: "Honda")
		
		sut1.merge(dictionary: sut2)
		
		XCTAssert(sut1.value(key: 100) == "Toyota")
		XCTAssert(sut1.value(key: 101) == "Mercedes")
		XCTAssert(sut1.value(key: 102) == "Honda")
		XCTAssert(sut1.value(key: 202) == "Mazda")
		
		sut2.merge(dictionary: sut1)
		
		XCTAssert(sut2.value(key: 100) == "Toyota")
		XCTAssert(sut2.value(key: 101) == "Mercedes")
		XCTAssert(sut2.value(key: 102) == "Honda")
		XCTAssert(sut2.value(key: 202) == "Mazda")
	}
	
	// test merge is associative
	func test_associativeMerge_success() {
		
		var sut1 = AEDictionary<Int, String>(bias: .add)
		var sut2 = AEDictionary<Int, String>(bias: .add)
		var sut3 = AEDictionary<Int, String>(bias: .add)
		
		sut1.add(key: 100, value: "BMW")
		sut1.add(key: 101, value: "Mercedes")
		sut1.add(key: 102, value: "Audi")
		
		sut2.add(key: 100, value: "Toyota")
		sut2.add(key: 202, value: "Mazda")
		sut2.add(key: 203, value: "Honda")
		
		sut3.add(key: 300, value: "Mazerati")
		sut3.add(key: 101, value: "Lamborghini")
		sut3.add(key: 202, value: "Alfa Romeo")
		
		//sut1 merge ( sut2 merge sut3)
		sut2.merge(dictionary: sut3)
		sut1.merge(dictionary: sut2)
		
		XCTAssert(sut1.value(key: 100) == "Toyota")
		XCTAssert(sut1.value(key: 101) == "Lamborghini")
		XCTAssert(sut1.value(key: 102) == "Audi")
		XCTAssert(sut1.value(key: 202) == "Alfa Romeo")
		XCTAssert(sut1.value(key: 203) == "Honda")
		XCTAssert(sut1.value(key: 300) == "Mazerati")
		
		//(sut1 merge sut2) merge sut3
		sut1.merge(dictionary: sut2)
		sut1.merge(dictionary: sut3)
		
		XCTAssert(sut1.value(key: 100) == "Toyota")
		XCTAssert(sut1.value(key: 101) == "Lamborghini")
		XCTAssert(sut1.value(key: 102) == "Audi")
		XCTAssert(sut1.value(key: 202) == "Alfa Romeo")
		XCTAssert(sut1.value(key: 203) == "Honda")
		XCTAssert(sut1.value(key: 300) == "Mazerati")
	}
	
	//test merge is idempotent
	func test_idempotentMerge_success() {
		
		var sut1 = AEDictionary<Int, String>(bias: .add)
		var sut2 = AEDictionary<Int, String>(bias: .add)
		
		sut1.add(key: 100, value: "BMW")
		sut1.add(key: 101, value: "Mercedes")
		sut1.add(key: 102, value: "Audi")
		
		sut2.add(key: 100, value: "Toyota")
		sut2.add(key: 202, value: "Mazda")
		sut2.add(key: 102, value: "Honda")
		
		sut1.merge(dictionary: sut2)
		
		XCTAssert(sut1.value(key: 100) == "Toyota")
		XCTAssert(sut1.value(key: 101) == "Mercedes")
		XCTAssert(sut1.value(key: 102) == "Honda")
		XCTAssert(sut1.value(key: 202) == "Mazda")
		
		sut1.merge(dictionary: sut2)
		
		XCTAssert(sut1.value(key: 100) == "Toyota")
		XCTAssert(sut1.value(key: 101) == "Mercedes")
		XCTAssert(sut1.value(key: 102) == "Honda")
		XCTAssert(sut1.value(key: 202) == "Mazda")
		
		sut1.merge(dictionary: sut2)
		
		XCTAssert(sut1.value(key: 100) == "Toyota")
		XCTAssert(sut1.value(key: 101) == "Mercedes")
		XCTAssert(sut1.value(key: 102) == "Honda")
		XCTAssert(sut1.value(key: 202) == "Mazda")
	}

}
