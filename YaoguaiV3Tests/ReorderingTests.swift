//
//  SupersetAndReoderingTests.swift
//  YaoguaiV3Tests
//
//  Created by Charles Zhao on 29/11/2024.
//

import Testing
import SwiftData
import Foundation
@testable import YaoguaiV3

/// - exercisesShouldBeInCorrectOrderAfterSetup
///
/// - exerciseCommonAddToNewGroup_shouldInsertSupersetIntoContext
/// - exerciseCommonAddToNewGroup_shouldBeCorrectOrder
///
/// - exerciseCommonAddToExistingGroup_shouldBeCorrectOrder
///
/// - exerciseCommonRemoveFromGroup_shouldBeCorrectOrder
/// - exerciseCommonRemoveFromGroupLastItem_shouldBeCorrectOrder
/// - exerciseCommonRemoveFromGroupLastItem_shouldRemoveFromPersistentStorage
///
/// - arrayOfExerciseCommonMakeItemsToRender_handlesEmptyArray
/// - arrayOfExerciseCommonMakeItemsToRender_handlesAllSingleItems
/// - arrayOfExerciseCommonMakeItemsToRender_handlesAllGrouped
/// - arrayOfExerciseCommonMakeItemsToRender_handlesSinglesAndGrouped

@Suite("Superset and Reordering Tests") struct ReorderingTests {
	@MainActor @Test func test_exercisesShouldBeInCorrectOrderAfterSetup() async throws {
		let container = try await createContainer()
		
		// Setup workout with 6 exercises
		let workout = try await setupWorkoutWithExercises(container: container, exerciseCount: 6)
		
		assertNoDuplicateOrders(workout.exercises.sorted())
	}

	@MainActor @Test func test_exerciseCommonAddToNewGroup_shouldInsertSupersetIntoContext() async throws {
		let container = try await createContainer()
		let workout = try await setupWorkoutWithExercises(container: container, exerciseCount: 6)
		let sortedExercises = workout.exercises.sorted()
		sortedExercises[2].addToNewGroup(with: sortedExercises[3])
		try fetchAndAssertCount(ofType: SupersetGroupRecord.self, in: container.mainContext, expectedCount: 1)
	}
	
	@MainActor @Test func test_exerciseCommonAddToNewGroup_shouldBeCorrectOrder() async throws {
		let container = try await createContainer()
		let workout = try await setupWorkoutWithExercises(container: container, exerciseCount: 6)
		let sortedExercises = workout.exercises.sorted()
		sortedExercises[2].addToNewGroup(with: sortedExercises[3])
		#expect(sortedExercises[2].order == 3)
		#expect(sortedExercises[3].order == 2)
		#expect(sortedExercises[3].supersetGroup?.order == 2)
		sortedExercises[1].addToNewGroup(with: sortedExercises[4])
		#expect(sortedExercises[1].order == 4)
		#expect(sortedExercises[4].order == 3)
		#expect(sortedExercises[4].supersetGroup?.order == 3)
		// Everything above shifts
		#expect(sortedExercises[2].order == 2)
		#expect(sortedExercises[3].order == 1)
		#expect(sortedExercises[3].supersetGroup?.order == 1)
		assertNoDuplicateOrders(sortedExercises.sorted())
	}
	@MainActor @Test func test_exerciseCommonAddToExistingGroup_shouldBeCorrectOrder() async throws {
		let container = try await createContainer()
		let workout = try await setupWorkoutWithExercises(container: container, exerciseCount: 6)
		let sortedExercises = workout.exercises.sorted()
		sortedExercises[2].addToNewGroup(with: sortedExercises[3])
		guard let group = sortedExercises[3].supersetGroup else {
			Issue.record("No superset found.")
			return
		}
		sortedExercises[1].addToExistingGroup(group)
		#expect(sortedExercises[1].order == 3)
		#expect(sortedExercises[1].supersetGroup?.order == 1)
		sortedExercises[5].addToExistingGroup(group)
		#expect(sortedExercises[5].order == 4)
		#expect(sortedExercises[5].supersetGroup?.order == 1)
		assertNoDuplicateOrders(sortedExercises.sorted())
	}
	@MainActor @Test func test_exerciseCommonRemoveFromGroup_shouldBeCorrectOrder() async throws {
		let container = try await createContainer()
		let workout = try await setupWorkoutWithExercises(container: container, exerciseCount: 6)
		let sortedExercises = workout.exercises.sorted()
		sortedExercises[2].addToNewGroup(with: sortedExercises[3])
		guard let group = sortedExercises[3].supersetGroup else {
			Issue.record("No superset found.")
			return
		}
		sortedExercises[1].addToExistingGroup(group)
		sortedExercises[5].addToExistingGroup(group)
		sortedExercises[1].removeFromGroup(using: container.mainContext)
		#expect(sortedExercises[1].order == 4)
		#expect(sortedExercises[1].supersetGroup == nil)
		assertNoDuplicateOrders(sortedExercises.sorted())
	}
	
	@MainActor @Test func test_exerciseCommonRemoveFromGroupLastItem_shouldBeCorrectOrder() async throws {
		let container = try await createContainer()
		let workout = try await setupWorkoutWithExercises(container: container, exerciseCount: 6)
		let sortedExercises = workout.exercises.sorted()
		sortedExercises[2].addToNewGroup(with: sortedExercises[3])
		sortedExercises[2].removeFromGroup(using: container.mainContext)
		#expect(sortedExercises[2].order == 3)
		#expect(sortedExercises[2].supersetGroup == nil)
		try fetchAndAssertCount(ofType: SupersetGroupRecord.self, in: container.mainContext, expectedCount: 0)
	}
	
	@MainActor @Test func test_exerciseCommonRemoveFromGroupLastItem_shouldRemoveFromPersistentStorage() async throws {
		let container = try await createContainer()
		let workout = try await setupWorkoutWithExercises(container: container, exerciseCount: 6)
		let sortedExercises = workout.exercises.sorted()
		sortedExercises[2].addToNewGroup(with: sortedExercises[3])
		sortedExercises[2].removeFromGroup(using: container.mainContext)
		try fetchAndAssertCount(ofType: SupersetGroupRecord.self, in: container.mainContext, expectedCount: 0)
	}
	
	@MainActor @Test func test_arrayOfExerciseCommonMakeItemsToRender_handlesEmptyArray() async throws {
		let exercises: [ExerciseRecord] = []
		let itemsToRender = exercises.makeItemsToRender()
		#expect(itemsToRender.isEmpty)
	}
	
	@MainActor @Test func test_arrayOfExerciseCommonMakeItemsToRender_handlesAllSingleItems() async throws {
		let container = try await createContainer()
		let workout = try await setupWorkoutWithExercises(container: container, exerciseCount: 6)
		let exercises = [workout.exercises[0], workout.exercises[1], workout.exercises[2], workout.exercises[3]]
		let itemsToRender = exercises.makeItemsToRender()
		let allAreSingle = itemsToRender.allSatisfy {
			if case .single = $0 { true } else { false }
		}
		#expect(allAreSingle)
	}
	
	@MainActor @Test func test_arrayOfExerciseCommonMakeItemsToRender_handlesAllGrouped() async throws {
		let container = try await createContainer()
		let workout = try await setupWorkoutWithExercises(container: container, exerciseCount: 6)
		workout.exercises[0].addToNewGroup(with: workout.exercises[1])
		let exercises = [workout.exercises[0], workout.exercises[1]]
		let itemsToRender = exercises.makeItemsToRender()
		guard case .group = itemsToRender.first else {
			Issue.record("Only item should be a group.")
			return
		}
		#expect(itemsToRender.count == 1)
	}
	
	@MainActor @Test func test_arrayOfExerciseCommonMakeItemsToRender_handlesSinglesAndGrouped() async throws {
		let container = try await createContainer()
		let workout = try await setupWorkoutWithExercises(container: container, exerciseCount: 6)
		workout.exercises[0].addToNewGroup(with: workout.exercises[1])
		workout.exercises[2].addToNewGroup(with: workout.exercises[3])
		let exercises = [workout.exercises[0], workout.exercises[1], workout.exercises[2], workout.exercises[3], workout.exercises[4], workout.exercises[5]]
		let itemsToRender = exercises.makeItemsToRender()
		let singleCount = itemsToRender.countSingleCases() // Using the `.single` enum case directly
		let groupCount = itemsToRender.countGroupCases()   // And for `.group`
		#expect(singleCount == 2, "There should be 2 single items")
		#expect(groupCount == 2, "There should be 2 group items")
		#expect(itemsToRender.count == 4, "Total items should be 4")
	}
}

private extension ReorderingTests {
	@MainActor func createContainer() async throws -> ModelContainer {
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		let container = try ModelContainer(for: WorkoutRecord.self, configurations: config)
		return container
	}
	
	@MainActor
	func setupWorkoutWithExercises(
		container: ModelContainer,
		exerciseCount: Int
	) async throws -> WorkoutRecord {
		let workout = WorkoutRecord()
		container.mainContext.insert(workout)
		
		for idx in 0..<exerciseCount {
			let details = Exercise(name: "Exercise \(idx)", category: .distanceAndWeight)
			workout.addExercise(details: details)
		}
		
		return workout
	}
	
	func printExercises(_ exercises: [ExerciseRecord]) {
		for exercise in exercises {
			let name = exercise.details?.name ?? "Unnamed Exercise"
			print("\(name) - order: \(exercise.order)")
		}
	}
	
	func assertNoDuplicateOrders(_ exercises: [ExerciseRecord]) {
		var count = 0
		for exercise in exercises {
			#expect(exercise.order == count)
			count += 1
		}
	}
	
	func fetchAndAssertCount<T: PersistentModel>(
		ofType type: T.Type,
		in context: ModelContext,
		expectedCount: Int
	) throws {
		let descriptor = FetchDescriptor<T>(predicate: #Predicate { _ in true })
		let fetchedModels = try context.fetch(descriptor)
		#expect(fetchedModels.count == expectedCount, "Expected \(expectedCount) but found \(fetchedModels.count) for \(T.self).")
	}
}

private extension Array where Element == SingleOrGroup<ExerciseRecord, SupersetGroupRecord> {
	// Example function to count occurrences of .single or .group
	func countSingleCases() -> Int {
		return self.filter { if case .single = $0 { return true } else { return false } }.count
	}
	
	func countGroupCases() -> Int {
		return self.filter { if case .group = $0 { return true } else { return false } }.count
	}
}
