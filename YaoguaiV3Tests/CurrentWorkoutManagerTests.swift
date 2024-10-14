//
//  YaoguaiV3Tests.swift
//  YaoguaiV3Tests
//
//  Created by Charles Zhao on 22/8/2024.
//

import Testing
import SwiftData
import Foundation
@testable import YaoguaiV3

@Suite("Current Workout Manager Tests") final class CurrentWorkoutManagerTests {
	let savePath = URL.documentsDirectory.appending(path: "CurrentWorkout")
	
	@MainActor init() async throws {
		if FileManager.default.fileExists(atPath: savePath.path) {
			try FileManager.default.removeItem(at: savePath)
		}
	}
	
	deinit {
		do {
			if FileManager.default.fileExists(atPath: savePath.path) {
				try FileManager.default.removeItem(at: savePath)
			}
		} catch {}
	}
	
	@MainActor @Test func test_currentWorkoutManagerInitialise_shouldStartEmpty() async throws {
		let container = try await createContainer()
		let workoutManager = CurrentWorkoutManager(modelContext: container.mainContext)
		
		// When: the app starts and we check initial state
		let currentWorkout = workoutManager.currentWorkout
		let currentWorkoutId = workoutManager.currentWorkoutId
		let savedWorkoutExists = FileManager.default.fileExists(atPath: savePath.path)
		let verificationContext = ModelContext(container)
		let workoutRecordsInDB = try fetchModel(ofType: WorkoutRecord.self, in: verificationContext)
		
		// Then: assert that the initial state is as expected
		try #require(currentWorkout == nil, "Expected no current workout on initial load")
		try #require(currentWorkoutId == nil, "Expected no current workout ID on initial load")
		try #require(!savedWorkoutExists, "Expected no saved workout file on initial load")
		try #require(workoutRecordsInDB.count == 0, "Expected no workout records in the database on initial load")
	}
	
	@MainActor @Test func test_currentWorkoutManagerStartNewWorkout_shouldSaveWorkoutToDbAndDocs() async throws {
		let container = try await createContainer()
		let workoutManager = CurrentWorkoutManager(modelContext: container.mainContext)
		
		workoutManager.startNewWorkout()
		
		let newCurrentWorkout = workoutManager.currentWorkout
		let newCurrentWorkoutId = workoutManager.currentWorkoutId
		let newSavedWorkoutExists = FileManager.default.fileExists(atPath: savePath.path)
		let verificationContext = ModelContext(container)
		let workoutRecordsInDB = try fetchModel(ofType: WorkoutRecord.self, in: verificationContext)
		
		// Then: assert that the initial state is as expected
		try #require(newCurrentWorkout != nil, "Expected a workout after starting a workout")
		try #require(newCurrentWorkoutId != nil, "Expected a workout ID after starting a workout")
		try #require(newSavedWorkoutExists, "Expected a saved workout file after starting a workout")
		try #require(workoutRecordsInDB.count == 1, "Expected 1 workout record in the database after starting a workout")
		
	}
	
	@MainActor @Test func test_currentWorkoutManagerInitialise_shouldRestoreCurrentWorkout() async throws {
		let container = try await createContainer()
		let workoutManager = CurrentWorkoutManager(modelContext: container.mainContext)
		
		workoutManager.startNewWorkout()
		
		guard let initialWorkoutId = workoutManager.currentWorkoutId else {
			Issue.record("No workoutId found.")
			return
		}
		
		let newWorkoutManager = CurrentWorkoutManager(modelContext: container.mainContext)
		
		let currentWorkout = newWorkoutManager.currentWorkout
		let currentWorkoutId = newWorkoutManager.currentWorkoutId
		let savedWorkoutExists = FileManager.default.fileExists(atPath: savePath.path)
		
		let verificationContext = ModelContext(container)
		let workoutRecordsInDB = try fetchModel(ofType: WorkoutRecord.self, in: verificationContext)
		
		try #require(currentWorkout != nil, "Expected current workout after starting a workout")
		try #require(currentWorkoutId != nil, "Expected current workout ID after starting a workout")
		try #require(savedWorkoutExists, "Expected saved workout file after starting a workout")
		try #require(workoutRecordsInDB.count == 1, "Expected 1 workout record in the database after starting a workout")
		try #require(initialWorkoutId == currentWorkoutId, "Expected the initial and current workoutId to be the same")
	}
	
	@MainActor @Test func test_currentWorkoutManagerInitialise_shouldNotRestoreCancelledWorkout() async throws {
		let container = try await createContainer()
		let workoutManager = CurrentWorkoutManager(modelContext: container.mainContext)
		
		workoutManager.startNewWorkout()
		workoutManager.cancel()
		
		let newWorkoutManager = CurrentWorkoutManager(modelContext: container.mainContext)
		
		let currentWorkout = newWorkoutManager.currentWorkout
		let currentWorkoutId = newWorkoutManager.currentWorkoutId
		let savedWorkoutExists = FileManager.default.fileExists(atPath: savePath.path)
		
		let verificationContext = ModelContext(container)
		let workoutRecordsInDB = try fetchModel(ofType: WorkoutRecord.self, in: verificationContext)
		
		// Then: assert that the initial state is as expected
		try #require(currentWorkout == nil, "Expected no workout after canceling")
		try #require(currentWorkoutId == nil, "Expected no current workout ID after canceling")
		try #require(!savedWorkoutExists, "Expected no saved workout file after canceling")
		try #require(workoutRecordsInDB.count == 0, "Expected no workout record in the database after after canceling")
	}
	
	@MainActor @Test func test_currentWorkoutManagerComplete_shouldSaveValidWorkoutToDbAndShouldRemoveIdFromDocs() async throws {
		let container = try await createContainer()
		let workoutManager = CurrentWorkoutManager(modelContext: container.mainContext)
		
		workoutManager.startNewWorkout()
		
		let exerciseRecord = ExerciseRecord()
		exerciseRecord.details = try getExerciseDetail(from: container.mainContext)
		
		exerciseRecord.addSet()
		exerciseRecord.sets[0].value = Measurement(value: 1.0, unit: .kilograms)
		exerciseRecord.sets[0].reps = 1
		exerciseRecord.sets[0].rpe = 1
		exerciseRecord.sets[0].toggleComplete()
		
		workoutManager.currentWorkout?.exercises.append(exerciseRecord)
		
		workoutManager.complete()
		
		let savedWorkoutExists = FileManager.default.fileExists(atPath: savePath.path)
		let verificationContext = ModelContext(container)
		let workoutRecordsInDB = try fetchModel(ofType: WorkoutRecord.self, in: verificationContext)
		let exerciseRecordsInDB = try fetchModel(ofType: ExerciseRecord.self, in: verificationContext)
		
		// Then: assert that the initial state is as expected
		try #require(workoutManager.currentWorkout == nil, "Expected no workout after completing")
		try #require(workoutManager.currentWorkoutId == nil, "Expected no current workout ID after completing")
		try #require(!savedWorkoutExists, "Expected no saved workout file after completing")
		try #require(workoutRecordsInDB.count == 1, "Expected 1 workout record in the database after after completing")
		try #require(exerciseRecordsInDB.count == 1, "Expected 1 exercise record in the database after after completing")
		try #require(workoutRecordsInDB[0].exercises.count == 1, "Expected 1 exercise in the workout record after completing")
	}
	
	@MainActor @Test func test_currentWorkoutManagerComplete_shouldNotSaveInvalidWorkoutToDbAndShouldRemoveIdFromDocs() async throws {
		let container = try await createContainer()
		let workoutManager = CurrentWorkoutManager(modelContext: container.mainContext)
		
		workoutManager.startNewWorkout()
		workoutManager.complete()
		
		let savedWorkoutExists = FileManager.default.fileExists(atPath: savePath.path)
		let verificationContext = ModelContext(container)
		let workoutRecordsInDB = try fetchModel(ofType: WorkoutRecord.self, in: verificationContext)
		
		// Then: assert that the initial state is as expected
		try #require(workoutManager.currentWorkout == nil, "Expected no workout after completing")
		try #require(workoutManager.currentWorkoutId == nil, "Expected no current workout ID after completing")
		try #require(!savedWorkoutExists, "Expected no saved workout file after completing")
		try #require(workoutRecordsInDB.count == 0, "Expected no workout records in the database after after completing")
	}
	
	@MainActor @Test func test_currentWorkoutManagerCancel_shouldDeleteFromDbAndDocs() async throws {
		let container = try await createContainer()
		let workoutManager = CurrentWorkoutManager(modelContext: container.mainContext)
		
		workoutManager.startNewWorkout()
		
		let exerciseRecord = ExerciseRecord()
		exerciseRecord.details = try getExerciseDetail(from: container.mainContext)
		exerciseRecord.addSet()
		exerciseRecord.sets[0].value = Measurement(value: 1.0, unit: .kilograms)
		exerciseRecord.sets[0].reps = 1
		exerciseRecord.sets[0].rpe = 1
		exerciseRecord.sets[0].toggleComplete()
		workoutManager.currentWorkout?.exercises.append(exerciseRecord)
		
		workoutManager.cancel()
		
		let savedWorkoutExists = FileManager.default.fileExists(atPath: savePath.path)
		let verificationContext = ModelContext(container)
		let workoutRecordsInDB = try fetchModel(ofType: WorkoutRecord.self, in: verificationContext)
		let exerciseRecordsInDB = try fetchModel(ofType: ExerciseRecord.self, in: verificationContext)
		
		// Then: assert that the initial state is as expected
		try #require(workoutManager.currentWorkout == nil, "Expected no workout after completing")
		try #require(workoutManager.currentWorkoutId == nil, "Expected no current workout ID after completing")
		try #require(!savedWorkoutExists, "Expected no saved workout file after completing")
		try #require(workoutRecordsInDB.count == 0, "Expected no workout records in the database after after completing")
		try #require(exerciseRecordsInDB.count == 0, "Expected 0 exercise records in the database after after canceling")
	}
	
	@MainActor @Test func test_workoutRecordAddExercise_shouldNotAddDuplicates() async throws {
		let container = try await createContainer()
		
		let workoutRecord = WorkoutRecord()
		let exercise = Exercise(name: "Burpees", category: .reps)
		container.mainContext.insert(workoutRecord)
		container.mainContext.insert(exercise)
		workoutRecord.addExercise(details: exercise)
		workoutRecord.addExercise(details: exercise)
		
		try #require(workoutRecord.exercises.count == 1, "Expected 1 exercise records after attempting to add duplicate")
	}
}

// Helpers moved to an extension for clarity
private extension CurrentWorkoutManagerTests {
	@MainActor func createContainer() async throws -> ModelContainer {
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		let container = try ModelContainer(for: WorkoutRecord.self, configurations: config)
		
		func addDummyExercises(in modelContext: ModelContext) throws {
			let pullups = Exercise(name: "Pullups", category: .weightAndReps)
			let pushups = Exercise(name: "Pushups", category: .weightAndReps)
			
			modelContext.insert(pullups)
			modelContext.insert(pushups)
			
			try modelContext.save()
		}
		
		try addDummyExercises(in: container.mainContext)
		
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
}
