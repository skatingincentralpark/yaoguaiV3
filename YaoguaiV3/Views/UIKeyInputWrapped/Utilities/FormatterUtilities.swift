//
//  FormatterUtilities.swift
//  LearningPlaygroundV1
//
//  Created by Charles Zhao on 24/12/2024.
//

import Foundation

struct FormatterUtilities {}

// MARK: - String Conversion Helpers
extension FormatterUtilities {
	static func formatDouble(_ value: Double) -> String {
		let epsilon = 1e-10
		if abs(value - Double(Int(value))) < epsilon {
			return String(Int(value))
		} else {
			return String(value)
		}
	}
	
	static func formatInt(_ value: Int) -> String {
		return "\(value)"
	}
}

// MARK: - Validation Helpers
extension FormatterUtilities {
	static private let ALLOWED_DIGITS_BEFORE_DECIMAL = 4
	static private let ALLOWED_DIGITS_AFTER_DECIMAL = 3
	
	/// Validates if a string contains only numeric characters.
	static func isValidIntInput(_ string: String) -> Bool {
		return string.allSatisfy(\.isNumber)
	}
	
	/// Validates if a string contains only numeric characters and a single period or less.
	static func isValidDoubleInput(_ string: String) -> Bool {
		// Allow digits and at most one decimal point
		let allowedCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "."))
		let characterSet = CharacterSet(charactersIn: string)
		
		// Check if all characters are allowed
		guard allowedCharacters.isSuperset(of: characterSet) else {
			return false
		}
		
		// Ensure there's at most one decimal point
		let decimalPointCount = string.filter { $0 == "." }.count
		return decimalPointCount <= 1
	}
	
	/// Validates digit counts before and after the decimal.
	static func validateDigitCountBeforeAndAfterDecimal(
		maxLengthBefore: Int = ALLOWED_DIGITS_BEFORE_DECIMAL,
		maxLengthAfter: Int = ALLOWED_DIGITS_AFTER_DECIMAL,
		in string: String
	) -> Bool {
		let parts = string.split(separator: ".", omittingEmptySubsequences: false)
		let before = parts.first ?? ""
		if before.count > maxLengthBefore {
			return false
		}
		
		if parts.count == 2 {
			let after = parts.last ?? ""
			if after.count > maxLengthAfter {
				return false
			}
		}
		
		return true
	}
	
	/// Checks for valid leading zeros in Int inputs.
	/// - Returns: `true` if valid, `false` otherwise.
	static func validateLeadingZeroForInt(_ string: String) -> Bool {
		// Allow "0" only if it's the sole character
		if string == "0" {
			return true
		}
		
		// Reject if string starts with '0' and has more characters
		if string.hasPrefix("0") {
			return false
		}
		
		return true
	}
	
	/// Checks for valid leading zeros in Double inputs.
	/// - Returns: `true` if valid, `false` otherwise.
	static func validateLeadingZeroForDouble(_ string: String) -> Bool {
		if string.hasPrefix("0") {
			if string.count == 1 {
				return true // "0" is valid
			}
			let secondChar = string[string.index(after: string.startIndex)]
			// Allow only if the second character is a decimal point
			return secondChar == "."
		}
		return true
	}
	
	/// Validates that the total length of the string does not exceed the specified maximum.
	static func validateTotalLength(
		maxLength: Int = ALLOWED_DIGITS_BEFORE_DECIMAL,
		in string: String
	) -> Bool {
		return string.count <= maxLength
	}
}
