//
//  BarebonesUIKeyInput+AdjustLogic.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 30/12/2024.
//

import UIKit

extension BarebonesUIKeyInput {
	enum AdjustDirection {
		case increment
		case decrement
	}
	
	func adjustValue(_ direction: AdjustDirection) {
		// Determine the adjustment based on direction
		let adjustedCandidate: T?
		
		switch direction {
		case .increment:
			adjustedCandidate = currentValue?.incremented()
		case .decrement:
			adjustedCandidate = currentValue?.decremented()
		}
		
		guard let candidate = adjustedCandidate else { return }

		guard candidate <= candidate.MAX_VALUE else {
			self.internalString = candidate.MAX_VALUE.formattedString()
			self.currentValue = candidate.MAX_VALUE
			return
		}
		guard candidate >= candidate.MIN_VALUE else {
			self.internalString = candidate.MIN_VALUE.formattedString()
			self.currentValue = candidate.MIN_VALUE
			return
		}

		let stringCandidate = candidate.formattedString()
		
		guard candidate.validateStringDigitCount() else { return }
		
		self.internalString = stringCandidate
		self.currentValue = T(stringCandidate)
	}
}
