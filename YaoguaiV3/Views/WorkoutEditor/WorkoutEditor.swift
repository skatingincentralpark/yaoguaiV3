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
	
	// Compute a mapping of SetRecord IDs to their input field indexes
	@State private var fieldIndexMapping: [T.ExerciseType.SetType.ID: [Int]] = [:]
	
	@FocusState var focusedField: Int?
	/// Total number of fields
	var totalFields: Int {
		fieldIndexMapping.values.flatMap { $0 }.count
	}
	
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
		self._fieldIndexMapping = .init(initialValue: getFieldIndexMapping())
	}
	
	var body: some View {
		VStack(alignment: .trailing) {
			Text("Focused Index: \(focusedField ?? -1)")
			Text("Total Fields: \(totalFields)")
		}
		.frame(maxWidth: .infinity, alignment: .trailing)
		
		ReorderableForEach(
			renderedExercises,
			active: $currentlyDragged
		) { renderedExercise in
			VStack(alignment: .leading) {
				switch renderedExercise {
				case .single(let exercise):
					VStack(alignment: .leading, spacing: 10) {
						ExerciseEditor(
							workout: workout,
							exercise: exercise,
							exerciseToAddToSupersetGroup: $exerciseToAddToSupersetGroup,
							renderExercises: { renderedExercises = workout.exercises.makeItemsToRender() },
							modelContext: modelContext,
							fieldIndexMapping: fieldIndexMapping,
							updateFieldIndexMapping: { fieldIndexMapping = getFieldIndexMapping() },
							focusedField: $focusedField
						)
					}
				case .group(let group):
					VStack(alignment: .leading, spacing: 10) {
						ForEach(group.exercises.sorted()) { exercise in
							ExerciseEditor(
								workout: workout,
								exercise: exercise,
								exerciseToAddToSupersetGroup: $exerciseToAddToSupersetGroup,
								renderExercises: { renderedExercises = workout.exercises.makeItemsToRender() },
								modelContext: modelContext,
								fieldIndexMapping: fieldIndexMapping,
								updateFieldIndexMapping: { fieldIndexMapping = getFieldIndexMapping() },
								focusedField: $focusedField
							)
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
			fieldIndexMapping = getFieldIndexMapping()
		}
		.sheet(item: $exerciseToAddToSupersetGroup) { exercise in
			AddGroupSheetView(
				exercise: exercise,
				itemsToRender: renderedExercises,
				generateItemsToRender: { renderedExercises = workout.exercises.makeItemsToRender() },
				updateFieldIndexMapping: { fieldIndexMapping = getFieldIndexMapping() }
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
	
	// Computes the field index mapping
	func getFieldIndexMapping() -> [T.ExerciseType.SetType.ID: [Int]] {
		var index = 0
		var mapping: [T.ExerciseType.SetType.ID: [Int]] = [:]
		
		for exercise in workout.exercises.sorted() {
			for set in exercise.sets {
				var indexes: [Int] = []
				
				func appendAndIncrement() {
					indexes.append(index); index += 1
				}
				
				// appendAndIncrement depending on how many focusable inputs there are
				if let category = exercise.details?.category {
					switch category {
					case .weightAndReps:
						appendAndIncrement()
						appendAndIncrement()
						appendAndIncrement()
						
					case .distanceAndWeight:
						appendAndIncrement()
						appendAndIncrement()
						
					case .duration:
						appendAndIncrement()
						
					case .durationAndWeight:
						appendAndIncrement()
						appendAndIncrement()
						
					case .reps:
						appendAndIncrement()
					}
				}
				
				mapping[set.id] = indexes
			}
		}
		
		return mapping
	}
}

struct AddGroupSheetView<T: ExerciseCommon>: View {
	@Environment(\.dismiss) var dismiss
	var exercise: T
	var itemsToRender: [SingleOrGroup<T, T.SupersetGroupType>]
	let generateItemsToRender: () -> Void
	let updateFieldIndexMapping: () -> Void
	var filteredItemsToRender: [SingleOrGroup<T, T.SupersetGroupType>] {
		itemsToRender.filter({ item in
			item != .single(exercise)
		})
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			Text("Add \(exercise.details?.name ?? "") to:")
				.font(.title3.bold())
			
			ForEach(filteredItemsToRender) { renderedExercise in
				VStack(alignment: .leading) {
					switch renderedExercise {
					case .single(let targetExercise):
						HStack {
							Button {
								exercise.addToNewGroup(with: targetExercise)
								withAnimation {
									generateItemsToRender()
									updateFieldIndexMapping()
								}
								dismiss()
							} label: {
								Text("\(targetExercise.details?.name ?? "")")
									.lineLimit(0)
							}
							
						}
					case .group(let group):
						Button {
							exercise.addToExistingGroup(group)
							withAnimation {
								generateItemsToRender()
								updateFieldIndexMapping()
							}
							dismiss()
						} label: {
							VStack(alignment: .leading) {
								ForEach(group.exercises.sorted()) { exercise in
									Text("\(exercise.details?.name ?? "")")
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

