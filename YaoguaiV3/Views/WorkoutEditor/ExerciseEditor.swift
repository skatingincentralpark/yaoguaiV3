//
//  ExerciseEditor.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 21/8/2024.
//

import SwiftUI
import SwiftData

struct ExerciseEditor<W: WorkoutCommon>: View {
	let workout: W
	@Bindable var exercise: W.ExerciseType
	@Binding var exerciseToAddToSupersetGroup: W.ExerciseType?
	let modelContext: ModelContext
	var renderExercises: () -> Void
	var fieldIndexMapping: [W.ExerciseType.SetType.ID: [Int]]
	let updateFieldIndexMapping: () -> Void
	@FocusState.Binding var focusedField: Int?
	
	@State private var replaceExerciseSheetPresented = false
	
	init(
		workout: W,
		exercise: W.ExerciseType,
		exerciseToAddToSupersetGroup: Binding<W.ExerciseType?>,
		renderExercises: @escaping () -> Void,
		modelContext: ModelContext,
		fieldIndexMapping: [W.ExerciseType.SetType.ID: [Int]],
		updateFieldIndexMapping: @escaping () -> Void,
		focusedField: FocusState<Int?>.Binding
	) {
		self.workout = workout
		self.exercise = exercise
		self._exerciseToAddToSupersetGroup = exerciseToAddToSupersetGroup
		self.renderExercises = renderExercises
		self.modelContext = modelContext
		self.fieldIndexMapping = fieldIndexMapping
		self.updateFieldIndexMapping = updateFieldIndexMapping
		self._focusedField = focusedField
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text(exercise.details?.name ?? "")
					.bold()
					.padding(.bottom, 10)

				Spacer()
				
				Button {
					exercise.addSet()
					updateFieldIndexMapping()
				} label: {
					Image(systemName: "plus.circle.fill")
						.aspectRatio(1, contentMode: .fit)
				}
				
				Menu {
					Button {
						replaceExerciseSheetPresented = true
					} label: {
						Text("Replace")
					}
					
					Button("Add To Group") {
						exerciseToAddToSupersetGroup = exercise
					}
					
					if exercise.supersetGroup != nil {
						Button("Remove From Superset") {
							exercise.removeFromGroup(using: modelContext)
							renderExercises()
							updateFieldIndexMapping()
						}
					}
					
					Button(role: .destructive) {
						workout.removeExercise(exercise, in: modelContext)
						renderExercises()
						updateFieldIndexMapping()
					} label: {
						Text("Remove From Workout")
					}
				} label: {
					Image(systemName: "ellipsis")
				}
				.buttonStyle(.bordered)
			}
			
			if exercise.sets.count > 0 {
				HStack {
					VStack(alignment: .leading) {
						HStack {
							if let category = exercise.details?.category {
								switch category {
								case .weightAndReps:
									Text("Weight")
										.frame(width: 70, alignment: .bottomLeading)
										.lineLimit(1)
										.bold()
										.foregroundStyle(.secondary)
									
									Text("Reps")
										.frame(width: 70, alignment: .bottomLeading)
										.lineLimit(1)
										.bold()
										.foregroundStyle(.secondary)
									
									Text("RPE")
										.frame(width: 70, alignment: .bottomLeading)
										.lineLimit(1)
										.bold()
										.foregroundStyle(.secondary)
								case .distanceAndWeight:
									Text("Distance")
										.frame(width: 70, alignment: .bottomLeading)
										.lineLimit(1)
										.bold()
										.foregroundStyle(.secondary)
									
									Text("Weight")
										.frame(width: 70, alignment: .bottomLeading)
										.lineLimit(1)
										.bold()
										.foregroundStyle(.secondary)
								case .duration:
									Text("Duration")
										.frame(width: 70, alignment: .bottomLeading)
										.lineLimit(1)
										.bold()
										.foregroundStyle(.secondary)
								case .durationAndWeight:
									Text("Duration")
										.frame(width: 70, alignment: .bottomLeading)
										.lineLimit(1)
										.bold()
										.foregroundStyle(.secondary)
									Text("Weight")
										.frame(width: 70, alignment: .bottomLeading)
										.lineLimit(1)
										.bold()
										.foregroundStyle(.secondary)
								case .reps:
									Text("Reps")
										.frame(width: 70, alignment: .bottomLeading)
										.lineLimit(1)
										.bold()
										.foregroundStyle(.secondary)
								}
							}
						}
						.padding(.bottom, 10)
						
						ForEach(Array($exercise.sets.enumerated()), id: \.1.id) { index, set in
							if let details = exercise.details {
								SetEditor(
									workout: workout,
									set: set,
									exercise: details,
									index: index,
									delete: { _ in
										exercise.removeSet(set.wrappedValue)
										updateFieldIndexMapping()
									},
									fieldIndexes: fieldIndexMapping[set.id] ?? [],
									focusedField: $focusedField
								)
							}
						}
					}
				}
			}
		}
		.sheet(isPresented: $replaceExerciseSheetPresented) {
			ExerciseDetailsList(
				onSelect: {
					if let replacementExercise = modelContext.model(for: $0.id) as? Exercise {
						exercise.replaceDetails(newDetails: replacementExercise)
					}
				},
				category: exercise.details?.category
			)
		}
	}
}

struct ExerciseEditorPreview: View {
	var container: ModelContainer
	var workout: WorkoutRecord
	var fieldIndexMapping: [WorkoutRecord.ExerciseType.SetType.ID: [Int]] = [:]
	@FocusState var focusedField: Int?
	
	init() {
		do {
			let (container, _) = try setupPreview()
			let workout = getWorkoutRecord(container.mainContext)
			workout.exercises[0].addSet()
			container.mainContext.insert(workout)
			self.container = container
			self.workout = workout
		} catch {
			fatalError("Something went wrong creating preview")
		}
	}
	
	var body: some View {
		ExerciseEditor(
			workout: workout,
			exercise: workout.exercises[0],
			exerciseToAddToSupersetGroup: .constant(nil),
			renderExercises: {},
			modelContext: container.mainContext,
			fieldIndexMapping: fieldIndexMapping,
			updateFieldIndexMapping: {},
			focusedField: $focusedField
		)
		.modelContainer(container)
		.padding()
	}
}

#Preview(traits: .sizeThatFitsLayout) {
	ExerciseEditorPreview()
}

