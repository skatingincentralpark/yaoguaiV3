//
//  TimeIntervalPicker.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 22/9/2024.
//

import SwiftUI

struct TimeIntervalPicker: View {
	@Binding var timeInterval: TimeInterval?
	let index: Int
	@FocusState.Binding var focusedField: Int?

    var body: some View {
		SimpleTextFieldV2(
			value: Binding(
				get: {
					doubleFromTimeInterval(timeInterval)
				},
				set: { newValue in
					if let newValue {
						timeInterval = timeIntervalFromDouble(newValue)
					}
				}
			),
			id: UUID().hashValue,
			index: index,
			focusedField: $focusedField
		)
    }
	
	// Convert TimeInterval to Double for TextField
	private func doubleFromTimeInterval(_ timeInterval: TimeInterval?) -> Double {
		guard let timeInterval = timeInterval else {
			return 0.0
		}
		return timeInterval
	}
	
	// Convert Double back to TimeInterval
	private func timeIntervalFromDouble(_ double: Double) -> TimeInterval? {
		return double
	}
}
