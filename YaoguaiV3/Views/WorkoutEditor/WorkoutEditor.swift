//
//  WorkoutEditor.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 21/8/2024.
//

import SwiftUI
import SwiftData

struct WorkoutEditor<T: WorkoutCommon>: View {
	@Bindable var workout: T
	let modelContext: ModelContext
	@State private var exerciseListSheetShown = false
	@State private var currentlyDragged: T.ExerciseType?
	
	init(workout: T, modelContext: ModelContext) {
		self.workout = workout
		self.modelContext = modelContext
	}
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading) {
				TextField("Name", text: $workout.name)
				Button("Add Exercise") {
					exerciseListSheetShown = true
				}
				ExerciseList(workout: workout, modelContext: modelContext, currentlyDragged: $currentlyDragged)
			}
			.padding()
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
		}
		.reorderableForEachContainer(active: $currentlyDragged)
		.sheet(isPresented: $exerciseListSheetShown, content: {
			ExerciseDetailsList { exerciseDetails in
				if let exercise = modelContext.model(for: exerciseDetails.id) as? Exercise {
					workout.addExercise(details: exercise)
				} else {
					fatalError("Exercise not found.")
				}
			}
		})
	}
	
	struct ExerciseList: View {
		@Bindable var workout: T
		let modelContext: ModelContext
		@Binding var currentlyDragged: T.ExerciseType?
		
		var body: some View {
			ReorderableForEach(workout.orderedExercises, active: $currentlyDragged) { exercise in
				ExerciseEditor(
					exercise: exercise,
					delete: {
						workout.removeExercise(exercise)
						modelContext.delete(exercise)
					},
					modelContext: modelContext
				)
				.padding(.bottom)
			} moveAction: { indices, newOffset in
				var s = workout.exercises.sorted(by: { $0.order < $1.order })
				s.move(fromOffsets: indices, toOffset: newOffset)
				for (index, item) in s.enumerated() {
					item.order = index
				}
				try? self.modelContext.save()
			}
		}
	}
}

#Preview(traits: .sizeThatFitsLayout) {
	do {
		let (container, _) = try setupPreview()
		
		let workout = getWorkoutRecord(container.mainContext)
		
		container.mainContext.insert(workout)
		
		return WorkoutEditor(workout: workout, modelContext: container.mainContext)
			.modelContainer(container)
	}  catch {
		return Text("Failed to build preview")
	}
}
