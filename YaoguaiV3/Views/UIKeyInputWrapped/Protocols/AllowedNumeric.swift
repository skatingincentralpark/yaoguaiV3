//
//  AllowedNumeric.swift
//  LearningPlaygroundV1
//
//  Created by Charles Zhao on 24/12/2024.
//

import Foundation

enum NumericMode {
	case int
	case double
}

protocol AllowedNumeric: Numeric, Comparable {
	static var numericMode: NumericMode { get }
	var MAX_VALUE: Self { get }
	var MIN_VALUE: Self { get }
	
	init?(_ description: String)
	
	func formattedString() -> String
	func incremented() -> Self
	func decremented() -> Self
	func zero() -> Self
	func validateStringDigitCount() -> Bool
}

extension Int: AllowedNumeric {
	static var numericMode: NumericMode { .int }
	var MAX_VALUE: Self { 9999 }
	var MIN_VALUE: Self { 0 }
	
	func formattedString() -> String {
		FormatterUtilities.formatInt(self)
	}
	
	func incremented() -> Int {
		self + 1
	}
	
	func decremented() -> Int {
		self - 1
	}
	
	func zero() -> Int {
		0
	}
	
	func validateStringDigitCount() -> Bool {
		FormatterUtilities.validateTotalLength(in: self.formattedString())
	}
}

extension Double: AllowedNumeric {
	static var numericMode: NumericMode { .double }
	var MAX_VALUE: Self { 9999.999 }
	var MIN_VALUE: Self { 0.0 }
	
	func formattedString() -> String {
		FormatterUtilities.formatDouble(self)
	}
	
	func incremented() -> Double {
		self + 1.0
	}
	
	func decremented() -> Double {
		self - 1.0
	}
	
	func zero() -> Double {
		0.0
	}
	
	func validateStringDigitCount() -> Bool {
		FormatterUtilities.validateDigitCountBeforeAndAfterDecimal(in: self.formattedString())
	}
}
