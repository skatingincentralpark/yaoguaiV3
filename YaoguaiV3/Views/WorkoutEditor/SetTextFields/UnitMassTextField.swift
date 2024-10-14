//
//  UnitMassTextField.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 22/9/2024.
//

import SwiftUI

struct UnitMassTextField: View {
	@Binding var value: Measurement<UnitMass>?
	
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
			id: UUID().hashValue
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

#Preview(traits: .sizeThatFitsLayout) {
	let m = Measurement<UnitMass>(value: 20.0, unit: .kilograms)
	UnitMassTextField(value: .constant(m))
}
