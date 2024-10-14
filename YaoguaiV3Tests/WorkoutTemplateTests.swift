//
//  WorkoutTemplateTests.swift
//  YaoguaiV3Tests
//
//  Created by Charles Zhao on 8/10/2024.
//

import Testing
import SwiftData
import Foundation
@testable import YaoguaiV3

@Suite("Workout Template Tests") struct WorkoutTemplateTests {
	@MainActor @Test func test_workoutTemplateViewModelInitialise_shouldWork() async throws {
		let container = try await createContainer()
		let template = try createWorkoutTemplate(in: container.mainContext)
		let templateViewModel = WorkoutTemplateEditorWrapper.ViewModel(workoutId: template.id, in: container, isNewWorkout: true)
		
		let workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: container.mainContext).count
		#expect(templateViewModel.workout.id == template.id, "Expected \(template.id) but found \(templateViewModel.workout.id)")
		#expect(templateViewModel.workout.name == WorkoutTemplateTests.defaultWorkoutName, "Expected specific name")
		#expect(workoutTemplatesInDB == 1, "Expected 1 workout record in the database, but found \(workoutTemplatesInDB)")
	}
	
	@MainActor @Test func test_workoutTemplateViewModelComplete_shouldSaveNameAndExercisesIfValid() async throws {
		let container = try await createContainer()
		let template = try createWorkoutTemplate(in: container.mainContext)
		let templateViewModel = WorkoutTemplateEditorWrapper.ViewModel(workoutId: template.id, in: container, isNewWorkout: true)
		
		try templateViewModel.workout.addExercise(details: getExerciseDetail(from: templateViewModel.modelContext))
		templateViewModel.workout.name = "New Name"
		templateViewModel.completeNewWorkout()
		
		let anotherContext = ModelContext(container)
		let workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: anotherContext)
		#expect(workoutTemplatesInDB.count == 1, "Expected 1 workout record in the database, but found \(workoutTemplatesInDB)")
		#expect(workoutTemplatesInDB[0].exercises.count == 1, "Expected workout to have 1 exercise, but found \(workoutTemplatesInDB[0].exercises.count)")
		#expect(workoutTemplatesInDB[0].name == "New Name", "Expected workout name to be 'New Name', but found \(workoutTemplatesInDB[0].name)")
	}
	
	@MainActor @Test func test_workoutTemplateViewModelComplete_shouldRemoveWorkoutIfInvalid() async throws {
		let container = try await createContainer()
		let template = try createWorkoutTemplate(in: container.mainContext, name: "")
		let templateViewModel = WorkoutTemplateEditorWrapper.ViewModel(workoutId: template.id, in: container, isNewWorkout: true)
		
		try templateViewModel.workout.addExercise(details: getExerciseDetail(from: templateViewModel.modelContext, name: .dips))
		templateViewModel.completeNewWorkout()
		let workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: container.mainContext).count
		#expect(workoutTemplatesInDB == 0, "Expected 0 workout record in the database, but found \(workoutTemplatesInDB)")
	}
	
	@MainActor @Test func test_workoutTemplateViewModelCancel_shouldDeleteWorkoutFromDb() async throws {
		let container = try await createContainer()
		let template = try createWorkoutTemplate(in: container.mainContext)
		let templateViewModel = WorkoutTemplateEditorWrapper.ViewModel(workoutId: template.id, in: container, isNewWorkout: true)
		
		var workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: container.mainContext).count
		#expect(workoutTemplatesInDB == 1, "Expected 1 workout record in the database, but found \(workoutTemplatesInDB)")
		templateViewModel.cancelNewWorkout()
		workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: container.mainContext).count
		#expect(workoutTemplatesInDB == 0, "Expected 0 workout record in the database, but found \(workoutTemplatesInDB)")
	}
	
	/// Create, insert, save workout in context and initialise it in ViewModel
	/// Add an exercise via the ViewModel
	/// Save via the ViewModel
	/// Fetch WorkoutTemplates and assert there's 1 workout
	@MainActor @Test func test_workoutTemplateViewModelSave_shouldSaveNameAndExercisesIfValid() async throws {
		let container = try await createContainer()
		let template = try createWorkoutTemplate(in: container.mainContext)
		let templateViewModel = WorkoutTemplateEditorWrapper.ViewModel(workoutId: template.id, in: container)
		try templateViewModel.workout.addExercise(details: getExerciseDetail(from: templateViewModel.modelContext))
		templateViewModel.workout.name = "New Name"
		templateViewModel.saveExistingWorkout()
		let anotherContext = ModelContext(container)
		let workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: anotherContext)
		#expect(workoutTemplatesInDB.count == 1, "Expected 1 workout record in the database, but found \(workoutTemplatesInDB)")
		#expect(workoutTemplatesInDB[0].exercises.count == 1, "Expected workout to have 1 exercise, but found \(workoutTemplatesInDB[0].exercises.count)")
		#expect(workoutTemplatesInDB[0].name == "New Name", "Expected workout name to be 'New Name', but found \(workoutTemplatesInDB[0].name)")
	}
	
	/// Create, insert and save workout in context Initialise it in ViewModel
	/// Make the name an empty string via the ViewModel
	/// Save via the ViewModel
	/// Fetch WorkoutTemplates and assert that the name is still the same
	@MainActor @Test func test_workoutTemplateViewModelSave_shouldntSaveNameAndExercisesIfInvalid() async throws {
		let container = try await createContainer()
		let template = try createWorkoutTemplate(in: container.mainContext)
		let templateViewModel = WorkoutTemplateEditorWrapper.ViewModel(workoutId: template.id, in: container)
		templateViewModel.workout.name = ""
		templateViewModel.saveExistingWorkout()
		let anotherContext = ModelContext(container)
		let workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: anotherContext)
		#expect(workoutTemplatesInDB.count == 1, "Expected 1 workout record in the database, but found \(workoutTemplatesInDB)")
		#expect(workoutTemplatesInDB[0].exercises.count == 0, "Expected workout to have 0 exercise, but found \(workoutTemplatesInDB[0].exercises.count)")
		#expect(workoutTemplatesInDB[0].name == WorkoutTemplateTests.defaultWorkoutName, "Expected default workout name, but found \(workoutTemplatesInDB[0].name)")
	}
	
	/// Create, insert and save workout in context Initialise it in ViewModel
	/// Delete via ViewModel
	/// Fetch WorkoutTemplates and assert count is 0
	@MainActor @Test func test_workoutTemplateViewModelDelete_shouldDeleteWorkoutFromDb() async throws {
		let container = try await createContainer()
		let template = try createWorkoutTemplate(in: container.mainContext)
		let templateViewModel = WorkoutTemplateEditorWrapper.ViewModel(workoutId: template.id, in: container)
		templateViewModel.deleteExistingWorkout()
		let anotherContext = ModelContext(container)
		let workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: anotherContext)
		#expect(workoutTemplatesInDB.isEmpty, "Expected workout templates to be empty")
	}
	
	/// Create a workout template with 1 exercise and save
	/// Assert there's 1 template with 1 exercise
	/// Add 1 more exercise and change the name
	/// Assert nothing has changed
	/// Save
	/// Assert that template has changed
	@MainActor @Test func test_workoutTemplateViewModel_shouldntAutosave() async throws {
		let container = try await createContainer()
		let template = try createWorkoutTemplate(in: container.mainContext)
		let templateViewModel = WorkoutTemplateEditorWrapper.ViewModel(workoutId: template.id, in: container)
		try templateViewModel.workout.addExercise(details: getExerciseDetail(from: templateViewModel.modelContext, name: .dips))
		templateViewModel.saveExistingWorkout()
		
		let anotherContext = ModelContext(container)
		var workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: anotherContext)
		#expect(workoutTemplatesInDB.count == 1, "Expected 1 workout template but had \(workoutTemplatesInDB[0].exercises.count)")
		#expect(workoutTemplatesInDB[0].exercises.count == 1, "Expected workout to have 1 exercise but had \(workoutTemplatesInDB[0].exercises.count)")
		
		templateViewModel.workout.name = "Lower"
		try templateViewModel.workout.addExercise(details: getExerciseDetail(from: templateViewModel.modelContext, name: .farmersCarries))
		try templateViewModel.workout.addExercise(details: getExerciseDetail(from: templateViewModel.modelContext, name: .pullups))
		
		let anotherContext2 = ModelContext(container)
		workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: anotherContext2)
		#expect(workoutTemplatesInDB[0].name == WorkoutTemplateTests.defaultWorkoutName, "Expected workout name to be \(WorkoutTemplateTests.defaultWorkoutName) but was \(workoutTemplatesInDB[0].name)")
		#expect(workoutTemplatesInDB[0].exercises.count == 1, "Expected workout to have 1 exercise but had \(workoutTemplatesInDB[0].exercises.count)")
		
		templateViewModel.saveExistingWorkout()
		
		let anotherContext3 = ModelContext(container)
		workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: anotherContext3)
		#expect(workoutTemplatesInDB[0].name == "Lower", "Expected workout name to be \(WorkoutTemplateTests.defaultWorkoutName) but was \(workoutTemplatesInDB[0].name)")
		#expect(workoutTemplatesInDB[0].exercises.count == 3, "Expected workout to have 3 exercise but had \(workoutTemplatesInDB[0].exercises.count)")
	}
	
	/// Create, insert and save workout in context Initialise it in ViewModel
	/// Attempt to add the same Exercise twice
	/// Assert that exercise count is 1
	@MainActor @Test func test_workoutTemplateViewModel_shouldntBeAbleToAddDuplicateExercises() async throws {
		let container = try await createContainer()
		let template = try createWorkoutTemplate(in: container.mainContext)
		let templateViewModel = WorkoutTemplateEditorWrapper.ViewModel(workoutId: template.id, in: container)
		let exerciseDetails = try getExerciseDetail(from: templateViewModel.modelContext)
		templateViewModel.workout.addExercise(details: exerciseDetails)
		templateViewModel.workout.addExercise(details: exerciseDetails)
		#expect(templateViewModel.workout.getValue(forKey: \.exercises).count == 1, "Expected 1 exercise")
	}
}

// Constants moved to a separate struct or made static within the test suite
private extension WorkoutTemplateTests {
	static let defaultWorkoutName = "Upper"
}

// Helpers moved to an extension for clarity
private extension WorkoutTemplateTests {
	@MainActor func createContainer() async throws -> ModelContainer {
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		let container = try ModelContainer(for: WorkoutRecord.self, configurations: config)
		
		func addDummyExercises(in modelContext: ModelContext) throws {
			let pullups = Exercise(name: "Pullups", category: .weightAndReps)
			let pushups = Exercise(name: "Pushups", category: .weightAndReps)
			let farmersCarries = Exercise(name: "Farmers Carries", category: .durationAndWeight)
			let dips = Exercise(name: "Dips", category: .weightAndReps)
			let planks = Exercise(name: "Planks", category: .duration)
			
			modelContext.insert(pullups)
			modelContext.insert(pushups)
			modelContext.insert(farmersCarries)
			modelContext.insert(dips)
			modelContext.insert(planks)
			
			try modelContext.save()
		}
		
		try addDummyExercises(in: container.mainContext)
		
		return container
	}
	
	enum ExerciseName: String {
		case pullups = "Pullups"
		case pushups = "Pushups"
		case farmersCarries = "Farmers Carries"
		case dips = "Dips"
		case planks = "Planks"
		
		var displayName: String {
			return self.rawValue
		}
	}

	func getExerciseDetail(from modelContext: ModelContext, name: ExerciseName? = nil) throws -> Exercise {
		let descriptor = FetchDescriptor<Exercise>(predicate: #Predicate { _ in true })
		let exercises = try modelContext.fetch(descriptor)
		
		// Try to find exercise by name if name is provided
		if let name, let foundExercise = exercises.first(where: { $0.name == name.displayName }) {
			return foundExercise
		}
		
		// If name is nil or no exercise was found, return a random exercise
		if let randomExercise = exercises.randomElement() {
			return randomExercise
		}
		
		// If there are no exercises in the database, return a default exercise
		return Exercise(name: "AUTO_GENERATED", category: .durationAndWeight)
	}
	
	func fetchModel<T: PersistentModel>(ofType type: T.Type, in context: ModelContext) throws -> [T] {
		let descriptor = FetchDescriptor<T>(predicate: #Predicate { _ in true })
		return try context.fetch(descriptor)
	}
	
	func createWorkoutTemplate(in context: ModelContext, name: String = WorkoutTemplateTests.defaultWorkoutName) throws -> WorkoutTemplate {
		let template = WorkoutTemplate(name: name)
		context.insert(template)
		try context.save()
		return template
	}
}
