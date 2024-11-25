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
	var category: ExerciseCategory
	
	var value: Measurement<UnitMass>? {
		didSet { toggleCompleteOffIfInvalid(value) }
	}
	var reps: Int? {
		didSet { toggleCompleteOffIfInvalid(reps) }
	}
	var rpe: Double? {
		didSet { toggleCompleteOffIfInvalid(rpe) }
	}
	var duration: TimeInterval? {
		didSet { toggleCompleteOffIfInvalid(duration) }
	}
	var distance: Measurement<UnitLength>? {
		didSet { toggleCompleteOffIfInvalid(distance) }
	}
	
	private var _complete = false
	
	var isValid: Bool {
		switch category {
		case .weightAndReps:
			return value != nil && reps != nil
		case .reps:
			return reps != nil
		case .duration:
			return duration != nil
		case .durationAndWeight:
			return duration != nil && value != nil
		case .distanceAndWeight:
			return distance != nil && value != nil
		}
	}
	
	mutating func toggleComplete() {
		if isValid {
			complete.toggle()
		} else {
			Task { @MainActor in
				AlertManager.shared.addAlert("Didn't toggle complete because invalid", type: .warning)
			}
		}
	}
	
	var complete: Bool {
		get { _complete }
		set { _complete = newValue }
	}
	
	init(category: ExerciseCategory) {
		self.category = category
	}
	
	// Generic function to check if a value is non-nil
	private mutating func toggleCompleteOffIfInvalid<T>(_ field: T?) {
		if field == nil {
			_complete = false
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
