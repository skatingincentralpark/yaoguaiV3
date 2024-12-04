//
//  SetEditor.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 21/8/2024.
//

import SwiftUI

struct SetEditor<T: SetCommon>: View {
	@Binding var set: T
	let exercise: Exercise
	let index: Int
	var previousSet: SetRecord?
	
	var delete: (T) -> Void
	
	init(
		set: Binding<T>,
		exercise: Exercise,
		index: Int,
		delete: @escaping (T) -> Void
	) {
		self._set = set
		self.exercise = exercise
		self.index = index
		self.delete = delete
		self.previousSet = exercise.latestRecord?.sets[safe: index]
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
						.font(.footnote)
						.monospaced()
				} else {
					Text("No Previous Set ")
						.font(.footnote)
						.disabled(true)
				}
			})
			
			HStack {
				Group {
					switch exercise.category {
					case .weightAndReps:
						VStack {
//							Text("\(set.valueString) \(set.value?.unit.symbol ?? "")")
							UnitMassTextField(value: $set.value)
						}
						VStack {
//							Text("\(set.repsString) reps")
							SimpleTextFieldV2(value: $set.reps)
						}
						VStack {
//							Text("\(set.rpeString) rpe")
							SimpleTextFieldV2(value: $set.rpe)
						}
					case .distanceAndWeight:
						VStack {
//							Text(set.distanceString)
							UnitLengthTextField(value: $set.distance)
						}
						VStack {
//							Text("\(set.valueString) \(set.value?.unit.symbol ?? "")")
							UnitMassTextField(value: $set.value)
						}
					case .duration:
						VStack {
//							Text(set.durationString)
							TimeIntervalPicker(timeInterval: $set.duration)
						}
					case .durationAndWeight:
						VStack {
//							Text(set.durationString)
							TimeIntervalPicker(timeInterval: $set.duration)
						}
						VStack {
//							Text("\(set.valueString) \(set.value?.unit.symbol ?? "")")
							UnitMassTextField(value: $set.value)
						}
					case .reps:
						VStack {
//							Text("\(set.repsString) reps")
							SimpleTextFieldV2(value: $set.reps)
						}
					}
				}
				
				Spacer()
				
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
			mutableSet.toggleComplete(for: exercise.category)
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
			
		if let details = exercise.details {
			return SetEditor(
				set: .constant(exercise.sets[0]),
				exercise: details,
				index: 0,
				delete: { _ in }
			)
			.modelContainer(container)
		} else {
			return Text("No Details.")
		}
	}  catch {
		return Text("Failed to build preview")
	}
}

