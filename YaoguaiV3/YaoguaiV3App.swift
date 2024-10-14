//
//  YaoguaiV3App.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 7/7/2024.
//

import SwiftUI
import SwiftData

@main
struct YaoguaiV3App: App {
	var sharedModelContainer: ModelContainer
	@State private var workoutManager: CurrentWorkoutManager
	
	init() {
		let schema = Schema([
			WorkoutRecord.self,
			WorkoutTemplate.self
		])
		
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
		
		do {
			let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
			self.sharedModelContainer = modelContainer
			self._workoutManager = State(initialValue: CurrentWorkoutManager(modelContext: modelContainer.mainContext))
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}
	
	var body: some Scene {
		WindowGroup {
			TabView {
				Group {
					Dashboard()
						.tabItem {
							Label("Home", systemImage: "figure.dance")
						}
					
					ExerciseDetailsList()
						.tabItem {
							Label("Exercises", systemImage: "list.bullet")
						}
				}
				.safeAreaInset(edge: .bottom) {
					ModelCounter()
				}
			}
			.overlay(alignment: .bottom) {
				AlertList()
			}
		}
		.modelContainer(sharedModelContainer)
		.environment(workoutManager)
	}
}

struct ModelCounter: View {
	@Query private var exercises: [Exercise]
	
	@Query private var exerciseRecords: [ExerciseRecord]
	@Query private var workoutRecords: [WorkoutRecord]
	
	@Query private var exerciseTemplates: [ExerciseTemplate]
	@Query private var workoutTemplates: [WorkoutTemplate]
	
	var body: some View {
		VStack(alignment: .leading) {
			Text("Exercises count: \(exercises.count)")
			
			Text("ExerciseRecords count: \(exerciseRecords.count)")
			Text("WorkoutRecords count: \(workoutRecords.count)")
			
			Text("ExerciseTemplates count: \(exerciseTemplates.count)")
			Text("WorkoutTemplates count: \(workoutTemplates.count)")
			
			Text("© 2024 Yaoguai.")
		}
		.font(.footnote.monospaced())
		.foregroundStyle(.secondary)
		.frame(maxWidth: .infinity)
		.padding()
	}
}

