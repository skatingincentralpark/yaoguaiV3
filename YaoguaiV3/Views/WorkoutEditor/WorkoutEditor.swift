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
	@State private var currentlyDragged: SingleOrGroup<T.ExerciseType, T.ExerciseType.SupersetGroupType>?
	
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
		@Binding var currentlyDragged: SingleOrGroup<T.ExerciseType, T.ExerciseType.SupersetGroupType>?
		@State var renderedExercises: [SingleOrGroup<T.ExerciseType, T.ExerciseType.SupersetGroupType>] = []
		@State var exerciseToAddToSupersetGroup: T.ExerciseType?
		
		init(
			workout: T,
			modelContext: ModelContext,
			currentlyDragged: Binding<SingleOrGroup<T.ExerciseType, T.ExerciseType.SupersetGroupType>?>
		) {
			self.workout = workout
			self.modelContext = modelContext
			self._currentlyDragged = currentlyDragged
			self._renderedExercises = .init(wrappedValue: workout.exercises.makeItemsToRender())
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
					switch renderedExercise {
					case .single(let exercise):
						Text("\(exercise.details?.name ?? "") (Order: \(exercise.order))")
							.fontWeight(.heavy)
					case .group(let group):
						Text("SupersetGroupOrder: \(group.exercises.first?.supersetGroup?.order)")
							.font(.subheadline.bold())
						ForEach(group.exercises) { exercise in
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
			
			var count = 0
			
			s.forEach { item in
				switch item {
				case .single(let child):
					child.order = count
					count += 1
				case .group(let group):
					group.order = count
					group.exercises.forEach { exercise in
						exercise.order = count
						count += 1
					}
				}
			}
			
			withAnimation {
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

