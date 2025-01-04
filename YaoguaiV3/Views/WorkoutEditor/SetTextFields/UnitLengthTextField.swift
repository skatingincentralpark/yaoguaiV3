//
//  UnitLengthTextField.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 22/9/2024.
//

import SwiftUI

struct UnitLengthTextField<W: WorkoutCommon>: View {
	let workout: W
	@Binding var value: Measurement<UnitLength>?
	let index: Int
	@FocusState.Binding var focusedField: Int?
	
	var body: some View {
		SimpleKeyInputV1(
			workout: workout,
			value: Binding(
				get: {
					doubleFromMeasurement(value)
				},
				set: { newValue in
					value = measurementFromDouble(newValue)
				}
			),
			id: UUID().hashValue,
			index: index,
			focusedField: $focusedField
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
