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
		let verificationContext = ModelContext(container)
		let workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: verificationContext).count
		#expect(templateViewModel.workout.id == template.id, "Expected \(template.id) but found \(templateViewModel.workout.id)")
		#expect(templateViewModel.workout.name == WorkoutTemplateTests.defaultWorkoutName, "Expected specific name")
		#expect(workoutTemplatesInDB == 1, "Expected 1 workout record in the database, but found \(workoutTemplatesInDB)")
	}
	
	@MainActor @Test func test_workoutTemplateViewModelSaveNewWorkout_shouldSaveNameAndExercisesIfValid() async throws {
		let container = try await createContainer()
		let template = try createWorkoutTemplate(in: container.mainContext)
		let templateViewModel = WorkoutTemplateEditorWrapper.ViewModel(workoutId: template.id, in: container, isNewWorkout: true)
		try templateViewModel.workout.addExercise(details: getExerciseDetail(from: templateViewModel.modelContext, name: .dips))
		templateViewModel.workout.name = "YEAH GEE"
		templateViewModel.saveNewWorkout()
		let verificationContext = ModelContext(container)
		let workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: verificationContext)
		let exerciseTemplatesInDB = try fetchModel(ofType: ExerciseTemplate.self, in: verificationContext)
		#expect(workoutTemplatesInDB.count == 1, "Expected 1 workout record in the database, but found \(workoutTemplatesInDB)")
		#expect(workoutTemplatesInDB[0].exercises.count == 1, "Expected workout to have 1 exercise, but found \(workoutTemplatesInDB[0].exercises.count)")
		#expect(exerciseTemplatesInDB.count == 1, "Expected 1 exercise record in the database, but found \(exerciseTemplatesInDB)")
		#expect(workoutTemplatesInDB[0].name == "YEAH GEE", "Expected workout name to be 'New Name', but found \(workoutTemplatesInDB[0].name)")
	}
	
	@MainActor @Test func test_workoutTemplateViewModelSaveNewWorkout_shouldRemoveWorkoutIfNoName() async throws {
		let container = try await createContainer()
		let template = try createWorkoutTemplate(in: container.mainContext, name: "")
		let templateViewModel = WorkoutTemplateEditorWrapper.ViewModel(workoutId: template.id, in: container, isNewWorkout: true)
		try templateViewModel.workout.addExercise(details: getExerciseDetail(from: templateViewModel.modelContext, name: .dips))
		templateViewModel.saveNewWorkout()
		let verificationContext = ModelContext(container)
		let workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: verificationContext).count
		#expect(workoutTemplatesInDB == 0, "Expected 0 workout record in the database, but found \(workoutTemplatesInDB)")
	}
	
	@MainActor @Test func test_workoutTemplateViewModelSaveNewWorkout_shouldRemoveWorkoutIfNoExercise() async throws {
		let container = try await createContainer()
		let template = try createWorkoutTemplate(in: container.mainContext, name: "New Workout")
		let templateViewModel = WorkoutTemplateEditorWrapper.ViewModel(workoutId: template.id, in: container, isNewWorkout: true)
		templateViewModel.saveNewWorkout()
		let verificationContext = ModelContext(container)
		let workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: verificationContext).count
		#expect(workoutTemplatesInDB == 0, "Expected 0 workout record in the database, but found \(workoutTemplatesInDB)")
	}
	
	@MainActor @Test func test_workoutTemplateViewModelCancelNewWorkout_shouldDeleteWorkoutAndExercisesFromDb() async throws {
		let container = try await createContainer()
		let template = try createWorkoutTemplate(in: container.mainContext)
		let templateViewModel = WorkoutTemplateEditorWrapper.ViewModel(workoutId: template.id, in: container, isNewWorkout: true)
		try templateViewModel.workout.addExercise(details: getExerciseDetail(from: templateViewModel.modelContext))
		let verificationContext = ModelContext(container)
		var workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: verificationContext).count
		#expect(workoutTemplatesInDB == 1, "Expected 1 workout template in the database, but found \(workoutTemplatesInDB)")
		templateViewModel.cancelNewWorkout()
		let updatedVerificationContext = ModelContext(container)
		workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: updatedVerificationContext).count
		let exerciseTemplatesInDB = try fetchModel(ofType: ExerciseTemplate.self, in: updatedVerificationContext).count
		#expect(workoutTemplatesInDB == 0, "Expected 0 workout templates in the database, but found \(workoutTemplatesInDB)")
		#expect(exerciseTemplatesInDB == 0, "Expected 0 exercise templates in the database, but found \(exerciseTemplatesInDB)")
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
		let verificationContext = ModelContext(container)
		let workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: verificationContext)
		let exerciseTemplatesInDB = try fetchModel(ofType: ExerciseTemplate.self, in: verificationContext)
		#expect(workoutTemplatesInDB.count == 1, "Expected 1 workout record in the database, but found \(workoutTemplatesInDB)")
		#expect(workoutTemplatesInDB[0].exercises.count == 1, "Expected workout to have 1 exercise, but found \(workoutTemplatesInDB[0].exercises.count)")
		#expect(exerciseTemplatesInDB.count == 1, "Expected 1 exercise record in the database, but found \(exerciseTemplatesInDB)")
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
		let verificationContext = ModelContext(container)
		let workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: verificationContext)
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
		let verificationContext = ModelContext(container)
		let workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: verificationContext)
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
		
		let verificationContext = ModelContext(container)
		var workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: verificationContext)
		#expect(workoutTemplatesInDB.count == 1, "Expected 1 workout template but had \(workoutTemplatesInDB[0].exercises.count)")
		#expect(workoutTemplatesInDB[0].exercises.count == 1, "Expected workout to have 1 exercise but had \(workoutTemplatesInDB[0].exercises.count)")
		
		templateViewModel.workout.name = "Lower"
		try templateViewModel.workout.addExercise(details: getExerciseDetail(from: templateViewModel.modelContext, name: .farmersCarries))
		try templateViewModel.workout.addExercise(details: getExerciseDetail(from: templateViewModel.modelContext, name: .pullups))
		
		let updatedVerificationContext = ModelContext(container)
		workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: updatedVerificationContext)
		#expect(workoutTemplatesInDB[0].name == WorkoutTemplateTests.defaultWorkoutName, "Expected workout name to be \(WorkoutTemplateTests.defaultWorkoutName) but was \(workoutTemplatesInDB[0].name)")
		#expect(workoutTemplatesInDB[0].exercises.count == 1, "Expected workout to have 1 exercise but had \(workoutTemplatesInDB[0].exercises.count)")
		
		templateViewModel.saveExistingWorkout()
		
		let updatedVerificationContext2 = ModelContext(container)
		workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: updatedVerificationContext2)
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
