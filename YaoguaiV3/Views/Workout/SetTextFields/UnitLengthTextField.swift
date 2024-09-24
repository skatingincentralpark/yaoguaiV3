//
//  UnitLengthTextField.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 22/9/2024.
//

import SwiftUI

struct UnitLengthTextField: View {
	@Binding var value: Measurement<UnitLength>?
	
	var body: some View {
		SimpleTextFieldV2(
			value: Binding(
				get: {
					doubleFromMeasurement(value)
				},
				set: { newValue in
					if let newValue {
						value = measurementFromDouble(newValue)
					}
				}
			),
			id: UUID().hashValue
		)
	}
	
	// Convert Measurement<UnitLength> to Double for TextField
	private func doubleFromMeasurement(_ measurement: Measurement<UnitLength>?) -> Double {
		// If the measurement is nil, return 0.0 as the default
		guard let measurement = measurement else {
			return 0.0
		}
		// Convert the measurement to kilograms and return the double value
		return measurement.converted(to: .meters).value
	}
	
	// Convert Double back to Measurement<UnitLength>
	private func measurementFromDouble(_ double: Double) -> Measurement<UnitLength>? {
		// Assuming the input is in kilograms, create and return a Measurement<UnitLength>
		return Measurement(value: double, unit: .meters)
	}
}
