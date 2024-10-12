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
	@MainActor @Test func testInitialise() async throws {
		/// Create, insert and save workout in context Initialise it in ViewModel
		let container = try await createContainer()
		let template = try createWorkoutTemplate(in: container.mainContext)
		let templateViewModel = WorkoutTemplateEditorWrapper.ViewModel(workoutId: template.id, in: container, isNewWorkout: true)
		
		let workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: container.mainContext).count
		#expect(templateViewModel.workout.id == template.id, "Expected \(template.id) but found \(templateViewModel.workout.id)")
		#expect(templateViewModel.workout.name == WorkoutTemplateTests.defaultWorkoutName, "Expected specific name")
		#expect(workoutTemplatesInDB == 1, "Expected 1 workout record in the database, but found \(workoutTemplatesInDB)")
	}
	
	@MainActor @Test func testCompleteValidWorkout() async throws {
		/// Create, insert and save workout in context Initialise it in ViewModel
		let container = try await createContainer()
		let template = try createWorkoutTemplate(in: container.mainContext)
		let templateViewModel = WorkoutTemplateEditorWrapper.ViewModel(workoutId: template.id, in: container, isNewWorkout: true)
		
		let exercise = Exercise(name: "Burpees", category: .reps)
		templateViewModel.workout.addExercise(details: exercise)
		templateViewModel.completeNewWorkout()
		let workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: container.mainContext).count
		#expect(workoutTemplatesInDB == 1, "Expected 1 workout record in the database, but found \(workoutTemplatesInDB)")
	}
	
	@MainActor @Test func testCompleteInvalidWorkout() async throws {
		/// Create, insert and save workout in context Initialise it in ViewModel
		let container = try await createContainer()
		let template = try createWorkoutTemplate(in: container.mainContext, name: "")
		let templateViewModel = WorkoutTemplateEditorWrapper.ViewModel(workoutId: template.id, in: container, isNewWorkout: true)
		
		let exercise = Exercise(name: "Burpees", category: .reps)
		templateViewModel.workout.addExercise(details: exercise)
		templateViewModel.completeNewWorkout()
		let workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: container.mainContext).count
		#expect(workoutTemplatesInDB == 0, "Expected 0 workout record in the database, but found \(workoutTemplatesInDB)")
	}
	
	@MainActor @Test func testCanCancelNewWorkout() async throws {
		/// Create, insert and save workout in context Initialise it in ViewModel
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
	@MainActor @Test func testSaveValidWorkout() async throws {
		let container = try await createContainer()
		let template = try createWorkoutTemplate(in: container.mainContext)
		let templateViewModel = WorkoutTemplateEditorWrapper.ViewModel(workoutId: template.id, in: container)
		try templateViewModel.workout.addExercise(details: getExerciseDetail(from: container.mainContext))
		templateViewModel.saveExistingWorkout()
		let workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: container.mainContext).count
		#expect(workoutTemplatesInDB == 1, "Expected 1 workout template in database")
		
	}
	
	/// Create, insert and save workout in context Initialise it in ViewModel
	/// Make the name an empty string via the ViewModel
	/// Save via the ViewModel
	/// Fetch WorkoutTemplates and assert that the name is still the same
	@MainActor @Test func testSaveInvalidWorkout() async throws {
		let container = try await createContainer()
		let template = try createWorkoutTemplate(in: container.mainContext)
		let templateViewModel = WorkoutTemplateEditorWrapper.ViewModel(workoutId: template.id, in: container)
		templateViewModel.workout.name = ""
		templateViewModel.saveExistingWorkout()
		let workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: container.mainContext)
		#expect(workoutTemplatesInDB[0].name == WorkoutTemplateTests.defaultWorkoutName, "Expected name to not change")
	}
	
	/// Create, insert and save workout in context Initialise it in ViewModel
	/// Delete via ViewModel
	/// Fetch WorkoutTemplates and assert count is 0
	@MainActor @Test func testCanDeleteExistingWorkout() async throws {
		let container = try await createContainer()
		let template = try createWorkoutTemplate(in: container.mainContext)
		let templateViewModel = WorkoutTemplateEditorWrapper.ViewModel(workoutId: template.id, in: container)
		templateViewModel.deleteExistingWorkout()
		let workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: container.mainContext)
		#expect(workoutTemplatesInDB.isEmpty, "Expected workout templates to be empty")
	}
	
	/// Create, insert and save workout in context Initialise it in ViewModel
	/// Add an exercise and save
	/// Fetch WorkoutTemplates and assert there's 1 exercise
	/// Change the name via the ViewModel
	/// Add an exercise via the ViewModel
	/// Fetch WorkoutTemplates and assert name and exercise count didn't change
	@MainActor @Test func testShouldntAutosave() async throws {
		let container = try await createContainer()
		let template = try createWorkoutTemplate(in: container.mainContext)
		let templateViewModel = WorkoutTemplateEditorWrapper.ViewModel(workoutId: template.id, in: container)
		try templateViewModel.workout.addExercise(details: getExerciseDetail(from: container.mainContext))
		templateViewModel.saveExistingWorkout()
		var workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: container.mainContext)
		#expect(workoutTemplatesInDB[0].exercises.count == 1, "Expected workout to have 1 exercise but had \(workoutTemplatesInDB[0].exercises.count)")
		templateViewModel.workout.name = "Lower"
		try templateViewModel.workout.addExercise(details: getExerciseDetail(from: container.mainContext))
		workoutTemplatesInDB = try fetchModel(ofType: WorkoutTemplate.self, in: container.mainContext)
		#expect(workoutTemplatesInDB[0].name == WorkoutTemplateTests.defaultWorkoutName, "Expected workout name to be \(WorkoutTemplateTests.defaultWorkoutName) but was \(workoutTemplatesInDB[0].name)")
		#expect(workoutTemplatesInDB[0].exercises.count == 1, "Expected workout to have 1 exercise but had \(workoutTemplatesInDB[0].exercises.count)")
		
	}
	
	/// Create, insert and save workout in context Initialise it in ViewModel
	/// Attempt to add the same Exercise twice
	/// Assert that exercise count is 1
	@MainActor @Test func testAddDuplicateExercisesToWorkout() async throws {
		let container = try await createContainer()
		let template = try createWorkoutTemplate(in: container.mainContext)
		let templateViewModel = WorkoutTemplateEditorWrapper.ViewModel(workoutId: template.id, in: container)
		let exerciseDetails = try getExerciseDetail(from: container.mainContext)
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
		
		func addDummyExercises(in modelContext: ModelContext) {
			let pullups = Exercise(name: "Pullups", category: .weightAndReps)
			let pushups = Exercise(name: "Pushups", category: .weightAndReps)
			
			modelContext.insert(pullups)
			modelContext.insert(pushups)
		}
		
		addDummyExercises(in: container.mainContext)
		
		return container
	}
	
	func getExerciseDetail(from modelContext: ModelContext) throws -> Exercise {
		let descriptor = FetchDescriptor<Exercise>(predicate: #Predicate { _ in true })
		let exercises = try modelContext.fetch(descriptor)
		let id = exercises.randomElement()!.id
		return modelContext.model(for: id) as? Exercise ?? Exercise(name: "AUTO_GENERATED", category: .durationAndWeight)
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
