//
//  PreviewSetup.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 16/9/2024.
//

import Foundation
import SwiftData

@MainActor
func setupPreview(noInitialData: Bool = false) throws -> (ModelContainer, CurrentWorkoutManager) {
	let modelContainer: ModelContainer
	modelContainer = try ModelContainer(for: WorkoutRecord.self, WorkoutTemplate.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
	
	if !noInitialData {
		let record = getWorkoutRecord(modelContainer.mainContext)
		modelContainer.mainContext.insert(record)
	}
		
	let workoutManager = CurrentWorkoutManager(modelContext: modelContainer.mainContext)
	
	return (modelContainer, workoutManager)
}

func getWorkoutRecord(_ context: ModelContext) -> WorkoutRecord {
	let pullups = Exercise(name: "Pullups", category: .weightAndReps)
	let pushups = Exercise(name: "Pushups", category: .weightAndReps)
	let militaryPress = Exercise(name: "Military Press", category: .weightAndReps)
	let farmersCarries = Exercise(name: "Farmers Carries", category: .durationAndWeight)
	context.insert(pullups)
	context.insert(pushups)
	
	let record1 = WorkoutRecord(name: "Upper")
	record1.addExercise(details: pullups)
	record1.addExercise(details: pushups)
	record1.addExercise(details: militaryPress)
	record1.addExercise(details: farmersCarries)
	record1.exercises.first?.addSet()
	
	let supersetGroup = SupersetGroup(order: 0)
	record1.exercises[2].supersetGroup = supersetGroup
	record1.exercises[3].supersetGroup = supersetGroup
	
	return record1
}
