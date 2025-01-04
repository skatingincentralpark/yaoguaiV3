//
//  FocusManager.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 2/1/2025.
//

import Foundation
import SwiftUI

@Observable
class FocusManager<T: WorkoutCommon> {
	typealias SetIdToFieldIndexMapping = [T.ExerciseType.SetType.ID: [Int]]
	
	var fieldIndexMapping: SetIdToFieldIndexMapping = [:]
	
	var focusedField: Int?
	
	var totalFields: Int {
		fieldIndexMapping.values.flatMap { $0 }.count
	}
	
	init(
		workout: T
	) {
		self.fieldIndexMapping = getFieldIndexMapping(workout)
	}
	
	func moveFocus(step: Int) {
		guard let current = focusedField else {
			return
		}
		let newFocus = current + step
		if newFocus >= 0 && newFocus < totalFields {
			focusedField = newFocus
		}
	}
	
	func getFieldIndexMapping(_ workout: T) -> SetIdToFieldIndexMapping {
		var index = 0
		var mapping: SetIdToFieldIndexMapping = [:]
		
		for exercise in workout.exercises.sorted() {
			for set in exercise.sets {
				var indexes: [Int] = []
				
				func appendAndIncrement() {
					indexes.append(index); index += 1
				}
				
				// appendAndIncrement depending on how many focusable inputs there are
				if let category = exercise.details?.category {
					switch category {
					case .weightAndReps:
						appendAndIncrement()
						appendAndIncrement()
						appendAndIncrement()
						
					case .distanceAndWeight:
						appendAndIncrement()
						appendAndIncrement()
						
					case .duration:
						appendAndIncrement()
						
					case .durationAndWeight:
						appendAndIncrement()
						appendAndIncrement()
						
					case .reps:
						appendAndIncrement()
					}
				}
				
				mapping[set.id] = indexes
			}
		}
		
		return mapping
	}
}
