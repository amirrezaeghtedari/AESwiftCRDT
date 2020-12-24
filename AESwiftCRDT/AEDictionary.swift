//
//  CRDTDictionary.swift
//  CRDTDictionary
//
//  Created by Amirreza Eghtedari on 10/3/1399 AP.
//

import Foundation

public struct AEDictionary<Key, Value> where Key: Hashable {
	
	private var addDictioanary 		= Dictionary<Key, TimestampValue<Value>>()
	private var removeDictionary	= Dictionary<Key, TimestampValue<Value>>()
	
	public var bias: Bias
	
	public init(bias: Bias) {
		self.bias = bias
	}
	
	mutating func add(key: Key, value: Value, timestamp: Date = Date()) {
		addDictioanary[key] = TimestampValue(value: value, timestamp: timestamp)
	}
	
	mutating func remove(key: Key, timestamp: Date = Date()) {
		
		if var value = addDictioanary[key] {
			value.refreshTimestamp(withTimestamp: timestamp)
			removeDictionary[key] = value
		}
	}
	
	func value(key: Key) -> Value? {
		
		guard let availableTimestampValue = addDictioanary[key] else {
			///key is not available
			return nil
		}
		
		guard let deletedTimestampValue = removeDictionary[key] else {
			///key is availabel and has not removed
			return availableTimestampValue.value
		}
		
		let compareResult = availableTimestampValue.compareTimestamp(to: deletedTimestampValue)
		
		switch compareResult {
		
		case .earlier:
			///Key has removed later
			return nil
			
		case .same:
			///key has added and removed at the same time. The return value depends on the bias property
			if bias == .add {
				return availableTimestampValue.value
			} else {
				return nil
			}
		
		case .later:
			///key has added later
			return availableTimestampValue.value
		}
	}
	
	
	///If timestamp fo the same keys are the same, merge function picks the value of the soucre dictionary
	mutating func merge(dictionary: Self) {
		
		addDictioanary.merge(dictionary.addDictioanary) { (lhTimestampValue, rhTimestampValue) -> TimestampValue<Value> in
			let mergedTimestampValue = lhTimestampValue.timestamp >= rhTimestampValue.timestamp ? lhTimestampValue : rhTimestampValue
			return mergedTimestampValue
		}
		
		removeDictionary.merge(dictionary.removeDictionary) { (lhTimestampValue, rhTimestampValue) -> TimestampValue<Value> in
			let mergedTimestampValue = lhTimestampValue.timestamp >= rhTimestampValue.timestamp ? lhTimestampValue : rhTimestampValue
			return mergedTimestampValue
		}
	}
}


