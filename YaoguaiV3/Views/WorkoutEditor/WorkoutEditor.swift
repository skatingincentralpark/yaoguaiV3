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
	@State var renderedExercises: [SingleOrGroup<T.ExerciseType, T.ExerciseType.SupersetGroupType>] = []
	
	init(
		workout: T,
		modelContext: ModelContext
	) {
		self.workout = workout
		self.modelContext = modelContext
		self._renderedExercises = .init(initialValue: workout.exercises.makeItemsToRender())
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
					currentlyDragged: $currentlyDragged,
					renderedExercises: $renderedExercises
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
						renderedExercises = workout.exercises.makeItemsToRender()
					} else {
						fatalError("Exercise not found.")
					}
				}
			}
		)
	}
}

struct ExerciseList<T: WorkoutCommon>: View {
	@Bindable var workout: T
	let modelContext: ModelContext
	@Binding var currentlyDragged: SingleOrGroup<T.ExerciseType, T.ExerciseType.SupersetGroupType>?
	@Binding var renderedExercises: [SingleOrGroup<T.ExerciseType, T.ExerciseType.SupersetGroupType>]
	@State var exerciseToAddToSupersetGroup: T.ExerciseType?
	
	init(
		workout: T,
		modelContext: ModelContext,
		currentlyDragged: Binding<SingleOrGroup<T.ExerciseType, T.ExerciseType.SupersetGroupType>?>,
		renderedExercises: Binding<[SingleOrGroup<T.ExerciseType, T.ExerciseType.SupersetGroupType>]>
	) {
		self.workout = workout
		self.modelContext = modelContext
		self._currentlyDragged = currentlyDragged
		self._renderedExercises = renderedExercises
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
				
				Text("Order: \(renderedExercise.order)")
					.font(.subheadline.bold())
				
				switch renderedExercise {
				case .single(let exercise):
					HStack {
						Text("\(exercise.details?.name ?? "") (Order: \(exercise.order))")
							.fontWeight(.heavy)
							.lineLimit(0)
						Spacer()
						Button("Add To Group") {
							exerciseToAddToSupersetGroup = exercise
						}
						Button(role: .destructive) {
							workout.exercises.removeFirst(where: { $0 == exercise })
							modelContext.delete(exercise)
							renderedExercises = workout.exercises.makeItemsToRender()
						} label: {
							Image(systemName: "xmark")
						}

					}
				case .group(let group):
					ForEach(group.exercises.sorted()) { exercise in
						HStack {
							Text("\(exercise.details?.name ?? "") (Order: \(exercise.order))")
								.fontWeight(.heavy)
								.lineLimit(0)
							Spacer()
							
							Menu {
								Button("Add To Group") {
									exerciseToAddToSupersetGroup = exercise
								}
								
								Button("Delete") {
									workout.exercises.removeFirst(where: { $0 == exercise })
									modelContext.delete(exercise)
									renderedExercises = workout.exercises.makeItemsToRender()
								}
								
								Button("Remove from superset") {
									exercise.removeFromSuperset(using: modelContext)
									renderedExercises = workout.exercises.makeItemsToRender()
								}
								
							} label: {
								Image(systemName: "ellipsis")
							}
							.buttonStyle(.bordered)
						}
					}
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding()
			.background(.gray.opacity(0.2))
			.clipShape(RoundedRectangle(cornerRadius: 14))
		} moveAction: { indices, newOffset in
			moveAction(indices, newOffset)
		}
		.sheet(item: $exerciseToAddToSupersetGroup) { exercise in
			AddGroupSheetView(
				exercise: exercise,
				itemsToRender: renderedExercises,
				generateItemsToRender: {
					renderedExercises = workout.exercises.makeItemsToRender()
				}
			)
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

struct AddGroupSheetView<T: ExerciseCommon>: View {
	@Environment(\.dismiss) var dismiss
	var exercise: T
	var itemsToRender: [SingleOrGroup<T, T.SupersetGroupType>]
	var generateItemsToRender: () -> Void
	var filteredItemsToRender: [SingleOrGroup<T, T.SupersetGroupType>] {
		itemsToRender.filter({ item in
			item != .single(exercise)
		})
	}
	
	var body: some View {
		VStack {
			Text("\(exercise.details?.name)")
				.font(.headline)
			
			ForEach(filteredItemsToRender) { renderedExercise in
				VStack(alignment: .leading) {
					Text("SingleOrGroupOrder: \(renderedExercise.order)")
					
					switch renderedExercise {
					case .single(let targetExercise):
						HStack {
							Button {
								exercise.addToNewGroup(with: targetExercise)
								withAnimation {
									generateItemsToRender()
								}
								dismiss()
							} label: {
								Text("\(targetExercise.details?.name ?? "") (Order: \(targetExercise.order))")
									.fontWeight(.heavy)
									.lineLimit(0)
							}
							
						}
					case .group(let group):
						Button {
							exercise.addToGroup(group)
							withAnimation {
								generateItemsToRender()
							}
							dismiss()
						} label: {
							VStack(alignment: .leading) {
								ForEach(group.exercises.sorted()) { exercise in
									Text("\(exercise.details?.name ?? "") (Order: \(exercise.order))")
										.fontWeight(.heavy)
										.lineLimit(0)
								}
							}
						}
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding()
				.background(.gray.opacity(0.2))
				.clipShape(RoundedRectangle(cornerRadius: 14))
			}
		}
		.padding()
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

