//
//  TimestampedValue.swift
//  CFDictionary
//
//  Created by Amirreza Eghtedari on 10/3/1399 AP.
//

import Foundation

struct TimestampValue<Value> {
	
	let value: Value
	private(set) var timestamp: Date
	
	init(value: Value, timestamp: Date = Date()) {
		self.value = value
		self.timestamp = timestamp
	}
	
	mutating func refreshTimestamp(withTimestamp: Date = Date()) {
		timestamp = withTimestamp
	}
	
	func compareTimestamp(to value: Self) -> TimestampComparisonResult {
		
		let comparision = self.timestamp.compare(value.timestamp)
		
		switch comparision {
		case .orderedAscending:
			return .earlier
		
		case .orderedSame:
			return .same
			
		case .orderedDescending:
			return .later
		}
	}
}
