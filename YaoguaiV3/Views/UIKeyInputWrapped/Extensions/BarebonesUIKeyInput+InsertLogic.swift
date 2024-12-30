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
		
		for char in text {
			insert(String(char))
		}
	}
	
	internal func insert(_ c: String) {
		let candidate = internalString + c
		
		switch T.numericMode {
		case .double:
			guard FormatterUtilities.isValidDoubleInput(candidate) else { return }
			guard FormatterUtilities.validateDigitCountBeforeAndAfterDecimal(in: candidate) else { return }
			guard FormatterUtilities.validateLeadingZeroForDouble(candidate) else {
				self.internalString = c
				self.currentValue = T(c)
				return
			}
			
		case .int:
			guard FormatterUtilities.isValidIntInput(candidate) else { return }
			guard FormatterUtilities.validateTotalLength(in: candidate) else { return }
			guard FormatterUtilities.validateLeadingZeroForInt(candidate) else {
				self.internalString = c
				self.currentValue = T(c)
				return
			}
		}
		
		guard let parsed = T(candidate) else { return }
		
		if parsed > parsed.MAX_VALUE {
			internalString = "\(parsed.MAX_VALUE)"
			currentValue = parsed.MAX_VALUE
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
}
