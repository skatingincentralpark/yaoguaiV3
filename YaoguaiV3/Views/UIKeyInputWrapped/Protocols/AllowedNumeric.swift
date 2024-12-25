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

protocol AllowedNumeric: Numeric {
	static var numericMode: NumericMode { get }
	
	init?(_ description: String)
	
	func formattedString() -> String
}

extension Int: AllowedNumeric {
	static var numericMode: NumericMode { .int }
	
	func formattedString() -> String {
		FormatterUtilities.formatInt(self)
	}
}

extension Double: AllowedNumeric {
	static var numericMode: NumericMode { .double }
	
	func formattedString() -> String {
		FormatterUtilities.formatDouble(self)
	}
}
