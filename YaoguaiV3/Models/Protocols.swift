//
//  Protocols.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 11/9/2024.
//

import Foundation
import Observation
import SwiftData

protocol WorkoutCommon: Observable, AnyObject, Identifiable, PersistentModel {
	associatedtype ExerciseType: ExerciseCommon where ExerciseType.SupersetGroupType.ExerciseType == ExerciseType
	
	var name: String { get set }
	var created: Date { get set }
	var exercises: [ExerciseType] { get set }
	
	init()
	
	func addExercise(details: Exercise)
	func removeExercise(_ exercise: ExerciseType)
}

extension WorkoutCommon {
	/// Such as adding a WorkoutRecord
	func addExercise(details: Exercise) {
		if exercises.contains(where: { $0.details?.id == details.id }) {
			
			/// We don't need to print warning if in test environment
			if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
				Task { @MainActor in
					AlertManager.shared.addAlert("Cannot add duplicate exercises to the workout", type: .warning)
				}
			}
			
			return
		}
		
		let exercise = ExerciseType()
		exercise.details = details
		exercise.order = exercises.count
		exercises.append(exercise)
	}
	
	func removeExercise(_ exercise: ExerciseType) {
		exercises.removeFirst { $0 == exercise }
	}
	
	/// Maps all the visible textFields that can be cycled via WorkoutKeyboard "next".
	var setIdsAndInputIndexes: [(UUID, [Int])] {
		let sortedExercises = exercises.sorted(by: { $0.order < $1.order })
		var counter = 0
		var results: [(UUID, [Int])] = []
		
		sortedExercises.forEach { exercise in
			exercise.sets.forEach { set in
				let inputIndexes = generateInputIndexes(for: exercise.details?.category, counter: &counter)
				results.append((set.id, inputIndexes))
			}
		}
		
		return results
	}
	
	/// Generates input indexes for a given exercise category, updating the counter.
	private func generateInputIndexes(for category: ExerciseCategory?, counter: inout Int) -> [Int] {
		let inputsNeeded: Int
		
		switch category {
		case .weightAndReps:
			inputsNeeded = 3
		case .reps, .duration:
			inputsNeeded = 1
		case .durationAndWeight, .distanceAndWeight:
			inputsNeeded = 2
		case .none:
			return []
		}
		
		let inputIndexes = (0..<inputsNeeded).map { _ in
			let index = counter
			counter += 1
			return index
		}
		
		return inputIndexes
	}
	
	func updateOrderOfExercises() {
		// Sort children based on their Comparable conformance
		let sortedChildren = self.exercises.sorted()
		
		// Update each child's order to match its new position
		for (index, child) in sortedChildren.enumerated() {
			child.order = index
		}
		
		// Update group orders based on the order of their first child
		let groups = Set(self.exercises.compactMap { $0.supersetGroup })
		for group in groups {
			if let firstChild = group.exercises.sorted().first {
				group.order = firstChild.order
			}
		}
	}
}


enum ExerciseCategory: String, Codable, CaseIterable {
	case weightAndReps
	case reps
	case duration
	case durationAndWeight
	case distanceAndWeight
	
	var title: String {
		switch self {
		case .weightAndReps:
			return "Weight and Reps"
		case .reps:
			return "Reps"
		case .duration:
			return "Duration"
		case .durationAndWeight:
			return "Duration and Weight"
		case .distanceAndWeight:
			return "Distance and Weight"
		}
	}
}

protocol ExerciseCommon: Observable, AnyObject, Identifiable, PersistentModel, Comparable {
	associatedtype WorkoutType: WorkoutCommon
	associatedtype SetType: SetCommon
	associatedtype SupersetGroupType: SupersetGroupCommon where SupersetGroupType.ExerciseType == Self
	
	var created: Date { get set }
	var details: Exercise? { get set }
	var workout: (WorkoutType)? { get set }
	var sets: [SetType] { get set }
	var order: Int { get set }
	var supersetGroup: SupersetGroupType? { get set }
	
	func addSet()
	func removeSet(_ set: SetType)
	func replaceDetails(newDetails: Exercise)
	func addToNewGroup(with target: Self)
	func addToExistingGroup(_ group: SupersetGroupType)
	func removeFromGroup(using modelContext: ModelContext)
	
	init()
}

extension ExerciseCommon {
	func addSet() {
		if let category = details?.category {
			sets.append(SetType(category: category))
		}
	}
	
	func removeSet(_ set: SetType) {
		if let index = sets.firstIndex(where: { $0 == set }) {
			sets.remove(at: index)
		}
	}
	
	func replaceDetails(newDetails: Exercise) {
		self.details = newDetails
		self.sets = self.sets.map { set in
			var updatedSet = set
			updatedSet.category = newDetails.category
			return updatedSet
		}
	}
	
	// Compare children, considering their group order first, then individual order.
	static func < (lhs: Self, rhs: Self) -> Bool {
		// Compare by group order if both are in groups
		if let lhsGroup = lhs.supersetGroup, let rhsGroup = rhs.supersetGroup {
			if lhsGroup.order != rhsGroup.order {
				return lhsGroup.order < rhsGroup.order
			}
			
			return lhs.order < rhs.order
			
		} else if let lhsGroup = lhs.supersetGroup {
			// LHS is in a group, RHS is not
			return lhsGroup.order < rhs.order
		} else if let rhsGroup = rhs.supersetGroup {
			// RHS is in a group, LHS is not
			return lhs.order < rhsGroup.order
		}
		
		// Fallback to comparing individual orders
		return lhs.order < rhs.order
	}
	
	func addToNewGroup(with target: Self) {
		guard target.supersetGroup == nil else { return }
		guard self != target else { return }
		let newGroup = SupersetGroupType(order: target.order)
		self.supersetGroup = newGroup
		self.order = target.order + 1
		target.supersetGroup = newGroup
		self.workout?.updateOrderOfExercises()
	}
	
	func addToExistingGroup(_ group: SupersetGroupType) {
		guard let lastChild = group.exercises.sorted().last else { return }
		self.supersetGroup = group
		self.order = lastChild.order + 1
		self.workout?.updateOrderOfExercises()
	}
	
	func removeFromGroup(using modelContext: ModelContext) {
		 guard let supersetGroup = self.supersetGroup else { return }
		 
		 if supersetGroup.exercises.count == 2 {
			 // If there are only two exercises, clearing the group and deleting it
			 supersetGroup.exercises = []
			 modelContext.delete(supersetGroup)
		 } else {
			 // Otherwise, detach the exercise from the group
			 self.supersetGroup = nil
			 self.order = supersetGroup.order + supersetGroup.exercises.count
			 self.workout?.updateOrderOfExercises()
		 }
	 }
}

protocol SetCommon: Identifiable, Codable, Equatable {
	var id: UUID { get set }
	var category: ExerciseCategory { get set }
	
	var value: Measurement<UnitMass>? { get set }
	var reps: Int? { get set }
	var rpe: Double? { get set }
	var duration: TimeInterval? { get set }
	var distance: Measurement<UnitLength>? { get set }
	
	init(category: ExerciseCategory)
}

extension SetCommon {
	var valueString: String {
		guard let value = value else { return "" }
		return value.value.formatted()
	}
	
	var rpeString: String {
		guard let rpe = rpe else { return "" }
		return String(rpe)
	}
	
	var repsString: String {
		guard let reps = reps else { return "" }
		return String(reps)
	}
	
	var durationString: String {
		guard let duration = duration else { return "" }
		let seconds = Duration.seconds(duration)
		return seconds.formatted(.time(pattern: .minuteSecond))
	}
	
	var distanceString: String {
		guard let distance = distance else { return "" }
		return distance.formatted()
	}
}
