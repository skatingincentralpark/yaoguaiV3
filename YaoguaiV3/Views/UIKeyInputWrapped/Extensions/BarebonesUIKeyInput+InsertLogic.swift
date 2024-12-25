//
//  BarebonesUIKeyInput+InsertLogic.swift
//  LearningPlaygroundV1
//
//  Created by Charles Zhao on 24/12/2024.
//

import UIKit

extension BarebonesUIKeyInput {
	
	// MARK: - Insert Logic
	
	internal func replaceAllText(with text: String) {
		isAllSelected = false
		label.backgroundColor = .clear
		
		// Validate the entire new text
		internalString = ""
		currentValue = nil
		
		switch T.numericMode {
		case .double:
			for char in text {
				insertForDouble(String(char))
			}
		case .int:
			for char in text {
				insertForInt(String(char))
			}
		}
	}
	
	internal func insertForDouble(_ c: String) {
		// 1. Check constraints before actually inserting.
		// Constraint a) Only 1 decimal point
		// Constraint b) Max digits before decimal = 4
		// Constraint c) Max digits after decimal = 3
		// Constraint d) Value cannot exceed 9999.999
		
		let candidate = internalString + c
		
		guard FormatterUtilities.isValidDoubleInput(candidate) else { return }
		guard FormatterUtilities.validateDigitCountBeforeAndAfterDecimal(in: candidate) else { return }
		
		guard let parsed = Double(candidate) else { return }
		
		if parsed > MAX_VALUE_DOUBLE {
			internalString = "\(MAX_VALUE_DOUBLE)"
			currentValue = T(internalString)
			return
		}
		
		// If all checks pass, update
		internalString = candidate
		
		if let newValue = T(candidate) {
			currentValue = newValue
		} else {
			// Handle unexpected parsing failures
			assertionFailure("Failed to parse \(candidate) as \(T.self)")
			currentValue = nil
			internalString = ""
		}
	}
	
	internal func insertForInt(_ c: String) {
		// 1. Check constraints before actually inserting.
		// Constraint a) Max 4 digits
		// Constraint b) value cannot exceed 9999
		
		let candidate = internalString + c
		
		guard FormatterUtilities.isValidIntInput(candidate) else { return }
		guard FormatterUtilities.validateTotalLength(in: candidate) else { return }
		
		guard let parsed = Int(candidate) else { return }
		
		if parsed > MAX_VALUE_INT {
			internalString = "\(MAX_VALUE_INT)"
			currentValue = T(internalString)
			return
		}
		
		// If valid
		internalString = candidate
		if let newValue = T(candidate) {
			currentValue = newValue
		} else {
			// Optionally handle unexpected parsing failures
			assertionFailure("Failed to parse \(candidate) as \(T.self)")
			currentValue = nil
			internalString = ""
		}
	}
}

