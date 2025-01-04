//
//  UnitMassTextField.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 22/9/2024.
//

import SwiftUI

struct UnitMassTextField<W: WorkoutCommon>: View {
	let workout: W
	@Binding var value: Measurement<UnitMass>?
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
	
	// Convert Measurement<UnitMass> to Double for TextField
	private func doubleFromMeasurement(_ measurement: Measurement<UnitMass>?) -> Double? {
		guard let measurement = measurement else {
			return nil
		}
		// Convert the measurement to kilograms and return the double value
		return measurement.converted(to: .kilograms).value
	}
	
	// Convert Double back to Measurement<UnitMass>
	private func measurementFromDouble(_ double: Double?) -> Measurement<UnitMass>? {
		guard let double else {
			return nil
		}
		// Assuming the input is in kilograms, create and return a Measurement<UnitMass>
		return Measurement(value: double, unit: .kilograms)
	}
}

//struct UnitMassTextFieldPreview: View {
//	let m = Measurement<UnitMass>(value: 20.0, unit: .kilograms)
//	@FocusState var focusedField: Int?
//	
//	var body: some View {
//		UnitMassTextField(value: .constant(m), index: 0, focusedField: $focusedField)
//	}
//}
//
//#Preview(traits: .sizeThatFitsLayout) {
//	UnitMassTextFieldPreview()
//}
