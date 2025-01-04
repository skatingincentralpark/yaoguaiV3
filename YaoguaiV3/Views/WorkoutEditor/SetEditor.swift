//
//  SetEditor.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 21/8/2024.
//

import SwiftUI
import SwiftData

struct SetEditor<T: WorkoutCommon>: View {
	typealias SetType = T.ExerciseType.SetType
	
	let workout: T
	@Binding var set: SetType
	let exercise: Exercise
	let index: Int
	var previousSet: SetRecord?
	var delete: (SetType) -> Void
	var fieldIndexes: [Int]
	@FocusState.Binding var focusedField: Int?
	
	init(
		workout: T,
		set: Binding<SetType>,
		exercise: Exercise,
		index: Int,
		delete: @escaping (SetType) -> Void,
		fieldIndexes: [Int],
		focusedField: FocusState<Int?>.Binding
	) {
		self.workout = workout
		self._set = set
		self.exercise = exercise
		self.index = index
		self.delete = delete
		self.previousSet = exercise.latestRecord?.sets[safe: index]
		self.fieldIndexes = fieldIndexes
		self._focusedField = focusedField
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			if workout.isRecord {
				Button(action: {
					if let previousSet {
						set.reps = previousSet.reps
						set.value = previousSet.value
						set.rpe = previousSet.rpe
						set.duration = previousSet.duration
						set.distance = previousSet.distance
					}
				}, label: {
					if previousSet != nil {
						Group {
							switch exercise.category {
							case .weightAndReps:
								Text("Weight and reps")
								
							case .distanceAndWeight:
								Text("Distance and weight")
								
							case .duration:
								Text("Duration")
								
							case .durationAndWeight:
								Text("Duration and weight")
								
							case .reps:
								Text("Reps")
							}
						}
						.font(.footnote)
					} else {
						Text("No Previous Set ")
							.font(.footnote)
							.disabled(true)
					}
				})
			}
			
			HStack {
				Group {
					switch exercise.category {
					case .weightAndReps:
						UnitMassTextField(
							workout: workout,
							value: $set.value,
							index: fieldIndexes[safe: 0] ?? -1,
							focusedField: $focusedField
						)
						SimpleKeyInputV1(
							workout: workout,
							value: $set.reps,
							index: fieldIndexes[safe: 1] ?? -1,
							focusedField: $focusedField
						)
						SimpleKeyInputV1(
							workout: workout,
							value: $set.rpe,
							index: fieldIndexes[safe: 2] ?? -1,
							focusedField: $focusedField
						)
					case .distanceAndWeight:
						UnitLengthTextField(
							workout: workout,
							value: $set.distance,
							index: fieldIndexes[safe: 0] ?? -1,
							focusedField: $focusedField
						)
						UnitMassTextField(
							workout: workout,
							value: $set.value,
							index: fieldIndexes[safe: 1] ?? -1,
							focusedField: $focusedField
						)
					case .duration:
						TimeIntervalPicker(
							workout: workout,
							timeInterval: $set.duration,
							index: fieldIndexes[safe: 0] ?? -1,
							focusedField: $focusedField
						)
					case .durationAndWeight:
						TimeIntervalPicker(
							workout: workout,
							timeInterval: $set.duration,
							index: fieldIndexes[safe: 0] ?? -1,
							focusedField: $focusedField
						)
						UnitMassTextField(
							workout: workout,
							value: $set.value,
							index: fieldIndexes[safe: 1] ?? -1,
							focusedField: $focusedField
						)
					case .reps:
						SimpleKeyInputV1(
							workout: workout,
							value: $set.reps,
							index: fieldIndexes[safe: 0] ?? -1,
							focusedField: $focusedField
						)
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
			set = mutableSet as! SetType // Cast back to T and assign to @Binding set
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

struct SetEditorPreview: View {
	let workout: WorkoutRecord
	var container: ModelContainer
	var exercise: ExerciseRecord
	var fieldIndexMapping: [WorkoutRecord.ExerciseType.SetType.ID: [Int]] = [:]
	@FocusState var focusedField: Int?
	
	init() {
		do {
			let (container, _) = try setupPreview()
			let workout = getWorkoutRecord(container.mainContext)
			let exercise = workout.exercises[0]
			container.mainContext.insert(workout)
			
			self.workout = workout
			self.container = container
			self.exercise = exercise
		} catch {
			fatalError("Something went wrong creating preview")
		}
	}
	
	var body: some View {
		if let details = exercise.details {
			SetEditor<WorkoutRecord>(
				workout: workout,
				set: .constant(exercise.sets[0]),
				exercise: details,
				index: 0,
				delete: { _ in },
				fieldIndexes: [],
				focusedField: $focusedField
			)
			.modelContainer(container)
		}
	}
}

#Preview(traits: .sizeThatFitsLayout) {
	SetEditorPreview()
}

