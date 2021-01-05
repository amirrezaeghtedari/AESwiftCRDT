//
//  TimestampTests.swift
//  AESwiftCRDTTests
//
//  Created by Amirreza Eghtedari on 10/16/1399 AP.
//

import XCTest
@testable import AESwiftCRDT

class TimestampValueTests: XCTestCase {
	
    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_compare_success() throws {
		
		let timestamp = Date()
        let sut1 = TimestampValue<Int>(value: 1, timestamp: timestamp)
		let sut2 = TimestampValue<Int>(value: 2, timestamp: timestamp)
		
		let result = sut1.compareTimestamp(to: sut2)
		XCTAssert(result == .same)
		
		let sut3 = sut1
		XCTAssert(sut1.compareTimestamp(to: sut3) == .same)
    }


}
