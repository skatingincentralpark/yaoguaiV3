//
//  SimpleKeyInputV1.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 25/12/2024.
//

import SwiftUI

struct SimpleKeyInputV1<V>: View where V: AllowedNumeric {
	@Binding var value: V?
	var id: Int = UUID().hashValue
	let index: Int
	@FocusState.Binding var focusedField: Int?
	var focused: Bool { focusedField == index }
	
    var body: some View {
		UIKeyInputWrapped(value: $value, next: { print("NOT IMPLEMENTED") })
			.focused($focusedField, equals: index)
			.frame(width: 70, height: 30)
			.background(Color(red: 0, green: 0, blue: 0, opacity: 0.1))
			.clipShape(RoundedRectangle(cornerRadius: 6))
			.overlay {
				RoundedRectangle(cornerRadius: 6)
					.stroke(focused ? .green : .clear, lineWidth: 4.0)
			}
			.overlay(alignment: .trailing) {
				Text("\(index)")
					.padding(.horizontal, 5)
					.foregroundColor(.blue)
					.opacity(0.7)
			}
			.id("workoutKeyInput_\(index)")
    }
}

//#Preview {
//    SimpleKeyInputV1()
//}
