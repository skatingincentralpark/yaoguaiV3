//
//  ExerciseEditor.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 21/8/2024.
//

import SwiftUI
import SwiftData

struct ExerciseEditor<T: WorkoutCommon>: View {
	var workout: T
	@Bindable var exercise: T.ExerciseType
	@Binding var exerciseToAddToSupersetGroup: T.ExerciseType?
	let modelContext: ModelContext
	var renderExercises: () -> Void
	
	@State private var replaceExerciseSheetPresented = false
	
	init(
		workout: T,
		exercise: T.ExerciseType,
		exerciseToAddToSupersetGroup: Binding<T.ExerciseType?>,
		renderExercises: @escaping () -> Void,
		modelContext: ModelContext
	) {
		self.workout = workout
		self.exercise = exercise
		self._exerciseToAddToSupersetGroup = exerciseToAddToSupersetGroup
		self.renderExercises = renderExercises
		self.modelContext = modelContext
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text(exercise.details?.name ?? "")
					.font(.title3.bold())
				Spacer()
				
				Button {
					exercise.addSet()
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
						}
					}
					
					Button(role: .destructive) {
						workout.removeExercise(exercise)
						modelContext.delete(exercise)
						renderExercises()
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
						ForEach(Array($exercise.sets.enumerated()), id: \.1.id) { index, set in
							SetEditor(
								set: set,
								exercise: exercise.details,
								index: index,
								delete: { _ in
									exercise.removeSet(set.wrappedValue)
								}
							)
							.padding(.leading)
						}
					}
					.overlay(alignment: .leading) {
						Rectangle()
							.frame(width: 1)
					}
				}
				.padding(.leading)
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

//#Preview(traits: .sizeThatFitsLayout) {
//	do {
//		let (container, _) = try setupPreview()
//		
//		let workout = getWorkoutRecord(container.mainContext)
//		
//		container.mainContext.insert(workout)
//		
//		return ExerciseEditor(exercise: workout.exercises[0], delete: {}, modelContext: container.mainContext)
//			.modelContainer(container)
//	}  catch {
//		return Text("Failed to build preview")
//	}
//}
