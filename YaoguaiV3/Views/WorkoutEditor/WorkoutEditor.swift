//
//  WorkoutEditor.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 21/8/2024.
//

import SwiftUI
import SwiftData

struct WorkoutEditor<W: WorkoutCommon>: View {
	typealias ExerciseType = W.ExerciseType
	typealias SupersetGroupType = W.ExerciseType.SupersetGroupType
	typealias SingleOrGroupType = SingleOrGroup<ExerciseType, SupersetGroupType>
	
	@Bindable var workout: W
	let modelContext: ModelContext
	@State private var exerciseListSheetShown = false
	@State private var currentlyDragged: SingleOrGroupType?
	@State var renderedExercises: [SingleOrGroupType] = []
	
	init(
		workout: W,
		modelContext: ModelContext
	) {
		self.workout = workout
		self.modelContext = modelContext
		self._renderedExercises = .init(initialValue: workout.exercises.makeItemsToRender())
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			VStack(alignment: .leading) {
				TextField("Name", text: $workout.name)
				Button("Add Exercise") {
					exerciseListSheetShown = true
				}
			}
			.padding()
			
			ExerciseList(
				workout: workout,
				modelContext: modelContext,
				currentlyDragged: $currentlyDragged,
				renderedExercises: $renderedExercises
			)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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

struct ExerciseList<W: WorkoutCommon>: View, KeyboardReadable {
	typealias ExerciseType = W.ExerciseType
	typealias SupersetGroupType = W.ExerciseType.SupersetGroupType
	typealias SingleOrGroupType = SingleOrGroup<ExerciseType, SupersetGroupType>
	
	@Bindable var workout: W
	let modelContext: ModelContext
	@Binding var currentlyDragged: SingleOrGroupType?
	@Binding var renderedExercises: [SingleOrGroupType]
	@State var exerciseToAddToSupersetGroup: ExerciseType?
	
	@State var keyboardIsVisible: Bool = false
	@State var focusManager: FocusManager<W>
	@FocusState var focusedField: Int?
	
	init(
		workout: W,
		modelContext: ModelContext,
		currentlyDragged: Binding<SingleOrGroupType?>,
		renderedExercises: Binding<[SingleOrGroupType]>
	) {
		self.workout = workout
		self.modelContext = modelContext
		self._currentlyDragged = currentlyDragged
		self._renderedExercises = renderedExercises
		self._focusManager = .init(initialValue: FocusManager(workout: workout))
	}
	
	var body: some View {
		ScrollViewReader { value in
			VStack(alignment: .trailing) {
				Text("Focused Index: \(focusedField ?? -1)")
				Text("Total Fields: \(focusManager.totalFields)")
				
				HStack {
					Spacer()
					
					Button("Prev") {
						focusManager.moveFocus(step: -1)
					}
					.disabled(focusedField == nil || focusedField == 0)
					.buttonStyle(.bordered)
					
					Button("Next") {
						focusManager.moveFocus(step: 1)
					}
					.disabled(focusedField == nil || (focusedField ?? 0) >= focusManager.totalFields - 1)
					.buttonStyle(.bordered)
					
					Button("Done") {
						focusedField = nil
					}
					.disabled(focusedField == nil)
					.buttonStyle(.bordered)
				}
			}
			.frame(maxWidth: .infinity, alignment: .trailing)
			.padding()
			
			ScrollView {
				VStack {
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
										fieldIndexMapping: focusManager.fieldIndexMapping,
										updateFieldIndexMapping: { focusManager.fieldIndexMapping = focusManager.getFieldIndexMapping(workout) },
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
											fieldIndexMapping: focusManager.fieldIndexMapping,
											updateFieldIndexMapping: { focusManager.fieldIndexMapping = focusManager.getFieldIndexMapping(workout) },
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
						focusManager.fieldIndexMapping = focusManager.getFieldIndexMapping(workout)
					}
					.sheet(item: $exerciseToAddToSupersetGroup) { exercise in
						AddGroupSheetView(
							exercise: exercise,
							itemsToRender: renderedExercises,
							generateItemsToRender: { renderedExercises = workout.exercises.makeItemsToRender() },
							updateFieldIndexMapping: { focusManager.fieldIndexMapping = focusManager.getFieldIndexMapping(workout) }
						)
					}
				}
				.padding()
			}
			.onChange(of: focusedField) { oldValue, newValue in
				if focusManager.focusedField != newValue {
					focusManager.focusedField = newValue
					Task { @MainActor in
						withAnimation {
							if let newValue {
								value.scrollTo("workoutKeyInput_\(newValue)")
							}
						}
					}
				}
			}
			.onChange(of: focusManager.focusedField, { oldValue, newValue in
				if focusedField != newValue {
					focusedField = newValue
					Task { @MainActor in
						withAnimation {
							if let newValue {
								value.scrollTo("workoutKeyInput_\(newValue)")
							}
						}
					}
				}
			})
			.onReceive(keyboardPublisher) { newIsKeyboardVisible in
				guard keyboardIsVisible != newIsKeyboardVisible else { return }
				
				keyboardIsVisible = newIsKeyboardVisible
				
				if newIsKeyboardVisible {
					Task { @MainActor in
						withAnimation {
							if let focusedField {
								value.scrollTo("workoutKeyInput_\(focusedField)")
							}
						}
					}
				}
			}
			.environment(focusManager)
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

