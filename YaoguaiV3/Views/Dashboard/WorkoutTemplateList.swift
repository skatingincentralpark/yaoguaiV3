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
	var onTemplateTap: (WorkoutTemplate) -> Void = { _ in }
	
	var body: some View {
		NavigationStack() {
			Button("Add Template") {
				let template = WorkoutTemplate(name: "New Workout Template")
				modelContext.insert(template)
				try? modelContext.save()
				newTemplate = template
			}
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
					onTemplateTap(template)
				}
				.swipeActions(edge: .trailing, allowsFullSwipe: true) {
					Button("Delete") {
						modelContext.delete(template)
					}
					.tint(.red)
				}
				.swipeActions {
					Button("Edit") {
						templateBeingEdited = template
					}
					.tint(.yellow)
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
