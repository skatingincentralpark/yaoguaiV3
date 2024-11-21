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
	@State private var currentlyDragged: OrderedExerciseToRender<T.ExerciseType>?
	
	init(
		workout: T,
		modelContext: ModelContext
	) {
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
				ExerciseList(
					workout: workout,
					modelContext: modelContext,
					currentlyDragged: $currentlyDragged
				)
			}
			.padding()
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
		}
		.reorderableForEachContainer(active: $currentlyDragged)
		.sheet(
			isPresented: $exerciseListSheetShown,
			content: {
				ExerciseDetailsList { exerciseDetails in
					if let exercise = modelContext.model(for: exerciseDetails.id) as? Exercise {
						workout.addExercise(details: exercise)
					} else {
						fatalError("Exercise not found.")
					}
				}
			}
		)
	}
	
	struct ExerciseList: View {
		@Bindable var workout: T
		let modelContext: ModelContext
		@Binding var currentlyDragged: OrderedExerciseToRender<T.ExerciseType>?
		@State var renderedExercises: [OrderedExerciseToRender<T.ExerciseType>] = []
		
		init(
			workout: T,
			modelContext: ModelContext,
			currentlyDragged: Binding<OrderedExerciseToRender<T.ExerciseType>?>
		) {
			self.workout = workout
			self.modelContext = modelContext
			self._currentlyDragged = currentlyDragged
			
			let grouped = Dictionary(grouping: workout.exercises) { $0.supersetGroup?.id }
			let renderedExercises: [OrderedExerciseToRender<T.ExerciseType>] = grouped.flatMap { key, group in
				if key == nil {
					return group.map { item in
						return OrderedExerciseToRender(exerciseToRender: .single(item))
					}
				} else {
					return [OrderedExerciseToRender(exerciseToRender: .group(group))]
				}
			}.sorted()
			self._renderedExercises = .init(wrappedValue: renderedExercises)
		}
		
		var body: some View {
			ReorderableForEach(
				renderedExercises,
				active: $currentlyDragged
			) { renderedExercise in
				//				ExerciseEditor(
				//					exercise: exercise,
				//					delete: {
				//						workout.removeExercise(exercise)
				//						modelContext.delete(exercise)
				//					},
				//					modelContext: modelContext
				//				)
				
				VStack(alignment: .leading) {
					Text("\(renderedExercise.id.hashValue)").lineLimit(1)
						.font(.caption)
						.opacity(0.6)
						.padding(.bottom, 5)
					
					Text("ActualOrder Order: \(renderedExercise.order)")
						.font(.subheadline.bold())
					switch renderedExercise.exerciseToRender {
					case .single(let exercise):
						Text("\(exercise.details?.name ?? "") (Order: \(exercise.order))")
							.fontWeight(.heavy)
					case .group(let exercises):
						Text("SupersetGroupOrder: \(exercises.first?.supersetGroup?.order)")
							.font(.subheadline.bold())
						ForEach(exercises) { exercise in
							Text("\(exercise.details?.name ?? "") (Order: \(exercise.order))")
								.fontWeight(.heavy)
						}
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding()
				.background(.green.gradient)
				.clipShape(RoundedRectangle(cornerRadius: 14))
			} moveAction: { indices, newOffset in
				moveAction(indices, newOffset)
			}
		}
		
		func moveAction(_ indices: IndexSet, _ newOffset: Int) {
			var s = renderedExercises
			s.move(fromOffsets: indices, toOffset: newOffset)
			var counter = 0 // this counter is used to get the correct order for exercises in supersets
			
			s.enumerated().forEach { index, orderedExerciseToRender in
				switch orderedExerciseToRender.exerciseToRender {
				case .single(let exercise):
					exercise.order = counter
					counter += 1
				case .group(let exercises):
					exercises.enumerated().forEach { subIndex, exercise in
						exercise.order = counter
						exercise.supersetGroup?.order = counter
						counter += 1
					}
				}
			}
			
			withAnimation(.bouncy(duration: 0.4)) {
				renderedExercises = s
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
