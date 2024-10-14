//
//  WorkoutTemplateList.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 15/9/2024.
//

import SwiftUI
import SwiftData

struct WorkoutTemplateList: View {
	@Environment(\.modelContext) private var modelContext
	@Query private var workoutTemplates: [WorkoutTemplate]
	@State var newTemplate: WorkoutTemplate? = nil
	@State var templateBeingEdited: WorkoutTemplate? = nil
	let alertManager = AlertManager.shared
	
	var body: some View {
		NavigationStack() {
			Button("Add Template") {
				let template = WorkoutTemplate(name: "New Workout Template")
				modelContext.insert(template)
				try? modelContext.save()
				newTemplate = template
			}
//			.onChange(of: newTemplate, { oldValue, newValue in
//				if newValue == nil {
//					if let oldValue {
//						if oldValue.name.isEmpty || oldValue.exercises.count == 0 {
//							alertManager.addAlert("Deleting new template because it's empty", type: .warning)
//							modelContext.delete(oldValue)
//						}
//					}
//				}
//			})
			.sheet(item: $newTemplate) { template in
				NavigationStack {
					WorkoutTemplateEditorWrapper(workoutId: template.id, in: modelContext.container, isNewWorkout: true)
				}
			}
			.sheet(item: $templateBeingEdited) { template in
				NavigationStack {
					WorkoutTemplateEditorWrapper(workoutId: template.id, in: modelContext.container, isNewWorkout: false)
				}
			}
		}
		
		ForEach(workoutTemplates) { template in
			HStack(spacing: 20) {
				Button(template.name) {
					templateBeingEdited = template
				}
				.swipeActions(edge: .trailing, allowsFullSwipe: true) {
					Button("Delete") {
						modelContext.delete(template)
					}
					.tint(.red)
				}
			}
		}
	}
}

#Preview {
	do {
		let modelContainer: ModelContainer
		modelContainer = try ModelContainer(for: WorkoutTemplate.self, WorkoutRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
		
		let pullups = Exercise(name: "Pullups", category: .weightAndReps)
		let pushups = Exercise(name: "Pushups", category: .weightAndReps)
		
		modelContainer.mainContext.insert(pullups)
		modelContainer.mainContext.insert(pushups)
		
		return WorkoutTemplateList()
			.modelContainer(modelContainer)
	} catch {
		return Text("Problem bulding ModelContainer.")
	}
}
