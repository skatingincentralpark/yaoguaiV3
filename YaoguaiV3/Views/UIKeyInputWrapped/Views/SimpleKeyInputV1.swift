//
//  SimpleKeyInputV1.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 25/12/2024.
//

import SwiftUI

struct SimpleKeyInputV1<V: AllowedNumeric, W: WorkoutCommon>: View {
	let workout: W
	@Binding var value: V?
	var id: Int = UUID().hashValue
	let index: Int
	@FocusState.Binding var focusedField: Int?
	var focused: Bool { focusedField == index }
	
    var body: some View {
		UIKeyInputWrapped(workout: workout, value: $value)
			.focused($focusedField, equals: index)
			.frame(width: 70, height: 30)
			.background(Color(red: 0, green: 0, blue: 0, opacity: 0.1))
			.clipShape(RoundedRectangle(cornerRadius: 6))
			.overlay(alignment: .trailing) {
				ZStack(alignment: .trailing) {
					Text("\(index)")
						.padding(.horizontal, 5)
						.foregroundColor(.blue)
						.opacity(0.7)
						.allowsHitTesting(false)
					
					RoundedRectangle(cornerRadius: 6)
						.stroke(focused ? .green : .clear, lineWidth: 4.0)
				}
			}
			.id("workoutKeyInput_\(index)")
    }
}

//#Preview {
//    SimpleKeyInputV1()
//}
