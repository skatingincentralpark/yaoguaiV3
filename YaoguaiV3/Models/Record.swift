//
//  Record.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 7/7/2024.
//

import Foundation
import SwiftData

struct SetRecord: SetCommon {
	var id = UUID()
	private(set) var complete = false
	
	var value: Measurement<UnitMass>? { didSet { toggleCompleteOffIfInvalid(value) } }
	var reps: Int? { didSet { toggleCompleteOffIfInvalid(reps) } }
	var rpe: Double? { didSet { toggleCompleteOffIfInvalid(rpe) } }
	var duration: TimeInterval? { didSet { toggleCompleteOffIfInvalid(duration) } }
	var distance: Measurement<UnitLength>? { didSet { toggleCompleteOffIfInvalid(distance) } }
	
	mutating func toggleComplete(for category: ExerciseCategory) {
		guard isValid(for: category) else {
			Task { @MainActor in
				AlertManager.shared.addAlert("Didn't toggle complete because invalid", type: .warning)
			}
			return
		}
		
		complete.toggle()
	}
	
	init() {}
	
	// Generic function to check if a value is non-nil
	private mutating func toggleCompleteOffIfInvalid<T>(_ field: T?) {
		if field == nil {
			complete = false
		}
	}
}

@Model final class ExerciseRecord: ExerciseCommon {
	var created: Date = Date()
	var details: Exercise?
	var workout: WorkoutRecord?
	var sets: [SetRecord] = []
	var order: Int = 0
	var supersetGroup: SupersetGroupRecord?
	
	init() {}
}

@Model final class WorkoutRecord: WorkoutCommon {
	var name: String = ""
	var created: Date = Date()
	@Relationship(deleteRule: .cascade, inverse: \ExerciseRecord.workout)
	var exercises: [ExerciseRecord] = []
	
	init() {}
	
	init(name: String) {
		self.name = name
	}
}
