//
//  SetEditor.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 21/8/2024.
//

import SwiftUI

struct SetEditor<T: SetCommon>: View {
	@Binding var set: T
	let exercise: Exercise?
	let index: Int
	var previousSet: SetRecord?
	
	var delete: (T) -> Void
	
	init(
		set: Binding<T>,
		exercise: Exercise?,
		index: Int,
		delete: @escaping (T) -> Void
	) {
		self._set = set
		self.exercise = exercise
		self.index = index
		self.delete = delete
		self.previousSet = exercise?.latestRecord?.sets[safe: index]
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			Button(action: {
				if let previousSet {
					set.reps = previousSet.reps
					set.value = previousSet.value
					set.rpe = previousSet.rpe
				}
			}, label: {
				if let previousSet {
					Text("\(previousSet.valueString) kg x \(previousSet.repsString)")
						.fixedSize()
				} else {
					Text("No Previous Set ")
						.fixedSize()
				}
			})
			
			VStack(alignment: .leading, spacing: 5) {
				Group {
					switch set.category {
					case .weightAndReps:
						HStack {
							UnitMassTextField(value: $set.value)
							Text("\(set.valueString) \(set.value?.unit.symbol ?? "")")
						}
						HStack {
							SimpleTextFieldV2(value: $set.reps)
							Text("\(set.repsString) reps")
						}
						HStack {
							SimpleTextFieldV2(value: $set.rpe)
							Text("\(set.rpeString) rpe")
						}
					case .distanceAndWeight:
						HStack {
							UnitLengthTextField(value: $set.distance)
							Text(set.distanceString)
						}
						HStack {
							UnitMassTextField(value: $set.value)
							Text("\(set.valueString) \(set.value?.unit.symbol ?? "")")
						}
					case .duration:
						HStack {
							TimeIntervalPicker(timeInterval: $set.duration)
							Text(set.durationString)
						}
					case .durationAndWeight:
						HStack {
							TimeIntervalPicker(timeInterval: $set.duration)
							Text(set.durationString)
						}
						HStack {
							UnitMassTextField(value: $set.value)
							Text("\(set.valueString) \(set.value?.unit.symbol ?? "")")
						}
					case .reps:
						HStack {
							SimpleTextFieldV2(value: $set.reps)
							Text("\(set.repsString) reps")
						}
					}
				}
			}
			
			HStack {
				Button(role: .destructive) {
					delete(set)
				} label: {
					Image(systemName: "xmark")
				}
				.buttonStyle(.bordered)
				.tint(.red)
				
				// If it's a record add a view to toggle complete
				if let toggleableSet = set as? SetRecord {
					CompleteToggleView(completeBinding: makeCompleteBinding(for: toggleableSet))
				}
			}
		}
	}
	
	// Helper function to create the Binding
	private func makeCompleteBinding(for toggleableSet: SetRecord) -> Binding<Bool> {
		Binding(get: {
			toggleableSet.complete
		}, set: { _ in
			// Here we manually update the set with the new value
			var mutableSet = toggleableSet
			mutableSet.toggleComplete()
			set = mutableSet as! T // Cast back to T and assign to @Binding set
		})
	}
	
	
}

struct CompleteToggleView: View {
	@Binding var completeBinding: Bool
	
	var body: some View {
		Toggle(isOn: $completeBinding) {
			Image(systemName: "checkmark")
		}
		.toggleStyle(.button)
		.buttonStyle(.bordered)
		.tint(completeBinding ? .green : .black)
	}
}

#Preview(traits: .sizeThatFitsLayout) {
	do {
		let (container, _) = try setupPreview()
		
		let workout = getWorkoutRecord(container.mainContext)
		
		container.mainContext.insert(workout)
		
		let exercise = workout.exercises[0]
		
		return SetEditor(set: .constant(exercise.sets[0]), exercise: exercise.details, index: 0, delete: {_ in })
			.modelContainer(container)
	}  catch {
		return Text("Failed to build preview")
	}
}

