//
//  WorkoutCommonTests.swift
//  YaoguaiV3Tests
//
//  Created by Charles Zhao on 6/12/2024.
//

import Testing
import SwiftData
import Foundation
@testable import YaoguaiV3

@Suite("WorkoutCommon Tests") struct WorkoutCommonTests {
	@MainActor @Test func test_workoutCommon_addExercise_shouldAddToWorkoutExercisesArray() async throws {
		let container = try await createContainer()
		let workout = try await getNewWorkoutRecord(container: container)
		let exercises = try getExercises(container: container)
		workout.addExercise(details: exercises.dips)
		#expect(workout.exercises.count == 1)
	}
	
	@MainActor @Test func test_workoutCommon_addExercise_shouldAddDetails() async throws {
		let container = try await createContainer()
		let workout = try await getNewWorkoutRecord(container: container)
		let exercises = try getExercises(container: container)
		workout.addExercise(details: exercises.dips)
		#expect(workout.exercises[0].details == exercises.dips)
	}
	
	@MainActor @Test func test_workoutCommon_addExercise_wontAddDuplicateExercise() async throws {
		let container = try await createContainer()
		let workout = try await getNewWorkoutRecord(container: container)
		let exercises = try getExercises(container: container)
		workout.addExercise(details: exercises.dips)
		workout.addExercise(details: exercises.dips)
		#expect(workout.exercises.count == 1)
	}
	
	@MainActor @Test func test_workoutCommon_addExercise_canAddMultipleDifferentExercises() async throws {
		let container = try await createContainer()
		let workout = try await getNewWorkoutRecord(container: container)
		let exercises = try getExercises(container: container)
		workout.addExercise(details: exercises.dips)
		workout.addExercise(details: exercises.pushups)
		#expect(workout.exercises.count == 2)
	}
	
	@MainActor @Test func test_workoutCommon_addExercise_shouldAddToPersistentStorage() async throws {
		let container = try await createContainer()
		let workout = try await getNewWorkoutRecord(container: container)
		let exercises = try getExercises(container: container)
		workout.addExercise(details: exercises.dips)
		try fetchAndAssertCount(ofType: ExerciseRecord.self, in: container.mainContext, expectedCount: 1)
	}
	
	@MainActor @Test func test_workoutCommon_removeExercise_shouldRemoveFromPersistentStorage() async throws {
		let container = try await createContainer()
		let workout = try await getNewWorkoutRecord(container: container)
		let exercises = try getExercises(container: container)
		workout.addExercise(details: exercises.dips)
		try fetchAndAssertCount(ofType: ExerciseRecord.self, in: container.mainContext, expectedCount: 1)
		workout.removeExercise(workout.exercises[0], in: container.mainContext)
		try fetchAndAssertCount(ofType: ExerciseRecord.self, in: container.mainContext, expectedCount: 0)
	}
	
	@MainActor @Test func test_workoutCommon_removeExercise_shouldRemoveFromWorkoutExercisesArray() async throws {
		let container = try await createContainer()
		let workout = try await getNewWorkoutRecord(container: container)
		let exercises = try getExercises(container: container)
		workout.addExercise(details: exercises.dips)
		workout.removeExercise(workout.exercises[0], in: container.mainContext)
		#expect(workout.exercises.count == 0)
	}
	
	@MainActor @Test func test_workoutCommon_removeExercise_shouldRemoveFromSupersetExercisesArray() async throws {
		let container = try await createContainer()
		let workout = try await getNewWorkoutRecord(container: container)
		let exercises = try getExercises(container: container)
		workout.addExercise(details: exercises.dips)
		workout.addExercise(details: exercises.pushups)
		workout.addExercise(details: exercises.planks)
		workout.exercises[1].addToNewGroup(with: workout.exercises[0])
		if let group = workout.exercises[1].supersetGroup {
			workout.exercises[2].addToExistingGroup(group)
		}
		let groupReference = workout.exercises[0].supersetGroup
		workout.removeExercise(workout.exercises[1], in: container.mainContext)
		#expect(groupReference?.exercises.count == 2)
	}
	
	@MainActor @Test func test_workoutCommon_removeExercise_shouldRemoveSupersetFromPersistentStorageIfOnlyOneMoreInGroup() async throws {
		let container = try await createContainer()
		let workout = try await getNewWorkoutRecord(container: container)
		let exercises = try getExercises(container: container)
		workout.addExercise(details: exercises.dips)
		workout.addExercise(details: exercises.pushups)
		workout.exercises[1].addToNewGroup(with: workout.exercises[0])
		let groupReference = workout.exercises[0].supersetGroup
		workout.removeExercise(workout.exercises[1], in: container.mainContext)
		#expect(groupReference?.isDeleted == true)
		try fetchAndAssertCount(ofType: SupersetGroupRecord.self, in: container.mainContext, expectedCount: 0)
	}
	
	// Todo: Add this to ItemsToRenderTests.swift
	@MainActor @Test func test_makeItemsToRenderAfterRemovingExerciseInASuperset_shouldReturnOneSingleItem() async throws {
		let container = try await createContainer()
		let workout = try await getNewWorkoutRecord(container: container)
		let exercises = try getExercises(container: container)
		workout.addExercise(details: exercises.dips)
		workout.addExercise(details: exercises.pushups)
		workout.exercises[1].addToNewGroup(with: workout.exercises[0])
		workout.removeExercise(workout.exercises[1], in: container.mainContext)
		let itemsToRender = workout.exercises.makeItemsToRender()
		#expect(itemsToRender.count == 1)
		#expect(itemsToRender.first?.isGroup == false, "Expected the first item to be `.single`.")
	}
}

private extension WorkoutCommonTests {
	@MainActor func createContainer() async throws -> ModelContainer {
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		let container = try ModelContainer(for: WorkoutRecord.self, configurations: config)
		return container
	}
	
	@MainActor func getNewWorkoutRecord(container: ModelContainer) async throws -> WorkoutRecord {
		let workout = WorkoutRecord()
		container.mainContext.insert(workout)
		return workout
	}
	
	struct ExerciseCollection {
		let pullups: Exercise
		let pushups: Exercise
		let farmersCarries: Exercise
		let dips: Exercise
		let planks: Exercise
	}

	@MainActor func getExercises(container: ModelContainer) throws -> ExerciseCollection {
		let pullups = Exercise(name: "Pullups", category: .weightAndReps)
		let pushups = Exercise(name: "Pushups", category: .weightAndReps)
		let farmersCarries = Exercise(name: "Farmers Carries", category: .durationAndWeight)
		let dips = Exercise(name: "Dips", category: .weightAndReps)
		let planks = Exercise(name: "Planks", category: .duration)

		container.mainContext.insert(pullups)
		container.mainContext.insert(pushups)
		container.mainContext.insert(farmersCarries)
		container.mainContext.insert(dips)
		container.mainContext.insert(planks)

		try container.mainContext.save()

		return ExerciseCollection(
			pullups: pullups,
			pushups: pushups,
			farmersCarries: farmersCarries,
			dips: dips,
			planks: planks
		)
	}
	
	func printExercises(_ exercises: [ExerciseRecord]) {
		for exercise in exercises {
			let name = exercise.details?.name ?? "Unnamed Exercise"
			print("\(name) - order: \(exercise.order)")
		}
	}
	
	func fetchAndAssertCount<T: PersistentModel>(
		ofType type: T.Type,
		in context: ModelContext,
		expectedCount: Int
	) throws {
		let descriptor = FetchDescriptor<T>(predicate: #Predicate { _ in true })
		// This is needed so the context contains the most up-to-date objects
		try context.save()
		let fetchedModels = try context.fetch(descriptor)
		#expect(fetchedModels.count == expectedCount, "Expected \(expectedCount) but found \(fetchedModels.count) for \(T.self).")
	}
}
