//
//  CurrentWorkoutManager.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 12/7/2024.
//

import Foundation
import SwiftData
import SwiftUI
import Observation

@Observable
final class CurrentWorkoutManager {
	private(set) var modelContext: ModelContext
	private(set) var currentWorkoutId: PersistentIdentifier? {
		didSet {
			save()
		}
	}
	private(set) var currentWorkout: WorkoutRecord? {
		didSet {
			self.currentWorkoutId = currentWorkout?.id
		}
	}
	private(set) var startTime: Date
	let alertManager = AlertManager.shared
	
	let savePath = URL.documentsDirectory.appending(path: "CurrentWorkout")
	
	@MainActor
	init(modelContext: ModelContext) {
		self.modelContext = modelContext
		self.startTime = Date()
		
		if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
			return
		}
		
		loadCurrentWorkout()
	}
	
	@MainActor
	func loadCurrentWorkout() {
		/// Need to early return if we're in preview otherwise I get FatalError "Failed to create a managed objectID"
		if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
			return
		}
		
		do {
			guard FileManager.default.fileExists(atPath: savePath.path) else {
				return
			}
			
			let data = try Data(contentsOf: savePath)
			let savedPersistentIdentifier = try JSONDecoder().decode(PersistentIdentifier.self, from: data)

			if let savedWorkout = modelContext.model(for: savedPersistentIdentifier) as? WorkoutRecord {
				modelContext.insert(savedWorkout)
				currentWorkout = savedWorkout
			
				alertManager.addAlert("Initialised current workout with saved workout", type: .info)

			} else {
				alertManager.addAlert("No workout saved, won't initialise current workout", type: .warning)
			}
		} catch {
			alertManager.addAlert("Unable to load data. \(error.localizedDescription)", type: .warning)
		}
	}
	
	private func save() {
		if let currentWorkoutId {
			do {
				let data = try JSONEncoder().encode(currentWorkoutId)
				try data.write(to: savePath, options: [.atomic, .completeFileProtection])
			} catch {
				alertManager.addAlert("Unable to save current workout. \(error.localizedDescription)", type: .warning)
			}
		}
	}
	
	@MainActor
	func cancel() {
		if let currentWorkout {
			try? modelContext.transaction {
				modelContext.delete(currentWorkout)
				
				// Although these will be cascade deleted, it won't happen immediately, XCTest assertions fail
				currentWorkout.exercises.forEach { record in
					modelContext.delete(record)
				}
			}
		}
		
		self.currentWorkoutId = nil
		self.currentWorkout = nil
		
		do {
			try FileManager.default.removeItem(at: savePath)
		} catch {
			alertManager.addAlert("Unable to delete saved workout file. \(error.localizedDescription)", type: .error)
		}
	}
	
	@MainActor
	func complete() {
		alertManager.addAlert("Completing workout", type: .info)
		guard let currentExercises = currentWorkout?.exercises else { return }
		guard let currentWorkout else { return }
		
		/// Ensures complete is toggled on for all valid sets
		currentExercises.enumerated().forEach({ idx, exercise in
			currentWorkout.exercises[idx].sets.enumerated().forEach({ setIdx, setRecord in
				if !setRecord.complete && setRecord.isValid {
					currentExercises[idx].sets[setIdx].toggleComplete()
				}
			})
		})
		
		/// For all exercises, filter out any sets that haven't been completed
		currentExercises.enumerated().forEach({ idx, exercise in
			currentExercises[idx].sets = currentExercises[idx].sets.filter({ setRecord in
				setRecord.complete
			})
		})
		
		/// Remember, transaction saves at the end of the closure
		try? modelContext.transaction {
			currentExercises.enumerated().forEach { idx, exercise in
				if exercise.sets.isEmpty {
					alertManager.addAlert("🗑️ Deleting an exercise record because it's empty", type: .info)
					modelContext.delete(exercise)
				}
			}
		}
		
		/// Here we DON'T use currentExercises to check, as it's a constant.  We use the original array.
		/// Items will be auto removed when deleted from the context.
		alertManager.addAlert("Remaining exercise records: \(currentWorkout.exercises.count)", type: .info)
		
		/// If there's 0 exercises remaining, don't save the workout
		if currentWorkout.exercises.count == 0 {
			alertManager.addAlert("Deleting workout record because it's empty", type: .info)
			modelContext.delete(currentWorkout)
			try? modelContext.save()
		} else {
			/// Update the latest exercise records
			currentWorkout.exercises.forEach { record in
				record.details?.latestRecord = record
			}
		}

		self.currentWorkoutId = nil
		self.currentWorkout = nil
		
		do {
			try FileManager.default.removeItem(at: savePath)
			alertManager.addAlert("Removed workoutId from documents", type: .info)
		} catch {
			alertManager.addAlert("Unable to delete saved workout file. \(error.localizedDescription)", type: .error)
		}
	}
	
	@MainActor
	func startNewWorkout(from template: WorkoutTemplate? = nil) {
		var newRecord: WorkoutRecord?
		
		if let template {
			alertManager.addAlert("Starting new workout from template", type: .info)
			let workoutRecord = WorkoutRecord(name: template.name)
			template.exercises.forEach { exerciseTemplate in
				if let details = exerciseTemplate.details {
					workoutRecord.addExercise(details: details)
					
					let sets = exerciseTemplate.sets.map { SetRecord(category: $0.category) }
					
					workoutRecord.exercises.last?.sets.append(contentsOf: sets)
				}
			}
			newRecord = workoutRecord
		} else {
			alertManager.addAlert("Starting new workout", type: .info)
			let newWorkout = WorkoutRecord(name: "New Workout")
			newRecord = newWorkout
		}
		
		guard let newRecord else {
			alertManager.addAlert("Failed to start new workout", type: .error)
			return
		}
		
		// Need to call save here to guarantee it's saved, otherwise, we could have an ID with no actual workout
		modelContext.insert(newRecord)
		try? modelContext.save()
		currentWorkout = newRecord
	}
	
}
