//
//  UnitLengthTextField.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 22/9/2024.
//

import SwiftUI

struct UnitLengthTextField: View {
	@Binding var value: Measurement<UnitLength>?
	let index: Int
	
	var body: some View {
		SimpleTextFieldV2(
			value: Binding(
				get: {
					doubleFromMeasurement(value)
				},
				set: { newValue in
					value = measurementFromDouble(newValue)
				}
			),
			id: UUID().hashValue,
			index: index
		)
	}
	
	// Convert Measurement<UnitLength> to Double for TextField
	private func doubleFromMeasurement(_ measurement: Measurement<UnitLength>?) -> Double? {
		guard let measurement = measurement else {
			return nil
		}
		// Convert the measurement to kilograms and return the double value
		return measurement.converted(to: .meters).value
	}
	
	// Convert Double back to Measurement<UnitLength>
	private func measurementFromDouble(_ double: Double?) -> Measurement<UnitLength>? {
		guard let double else {
			return nil
		}
		// Assuming the input is in kilograms, create and return a Measurement<UnitLength>
		return Measurement(value: double, unit: .meters)
	}
}
