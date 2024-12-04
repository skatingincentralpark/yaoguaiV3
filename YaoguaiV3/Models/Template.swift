//
//  Template.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 11/9/2024.
//

import Foundation
import SwiftData

struct SetTemplate: SetCommon {
	var id = UUID()
	
	var value: Measurement<UnitMass>?
	var reps: Int?
	var rpe: Double?
	var duration: TimeInterval?
	var distance: Measurement<UnitLength>?
	
	init() {}
}

@Model final class ExerciseTemplate: ExerciseCommon {
	var created: Date = Date()
	var details: Exercise?
	var workout: WorkoutTemplate?
	var sets: [SetTemplate] = []
	var order: Int = 0
	var supersetGroup: SupersetGroupTemplate?
	
	init() {}
}

@Model final class WorkoutTemplate: WorkoutCommon {
	var name: String = ""
	var created: Date = Date()
	@Relationship(deleteRule: .cascade, inverse: \ExerciseTemplate.workout)
	var exercises: [ExerciseTemplate] = []
	
	init() {}
	
	init(name: String) {
		self.name = name
	}
}
