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
	associatedtype ExerciseType: ExerciseCommon
	
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
		exercises.append(exercise)
	}
	
	func removeExercise(_ exercise: ExerciseType) {
		exercises.removeFirst { $0 == exercise }
	}
	
	var orderedExercises: [ExerciseType] {
		exercises.sorted(by: { $0.order < $1.order })
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

protocol ExerciseCommon: Observable, AnyObject, Identifiable, PersistentModel {
	associatedtype WorkoutType: WorkoutCommon
	associatedtype SetType: SetCommon
	
	var created: Date { get set }
	var details: Exercise? { get set }
	var workout: (WorkoutType)? { get set }
	var sets: [SetType] { get set }
	var order: Int { get set }
	
	func addSet()
	func removeSet(_ set: SetType)
	func replaceDetails(newDetails: Exercise)
	
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
