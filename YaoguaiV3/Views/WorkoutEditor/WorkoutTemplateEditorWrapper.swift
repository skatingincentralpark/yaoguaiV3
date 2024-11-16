//
//  WorkoutTemplateEditorWrapper.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 21/8/2024.
//

import SwiftUI
import SwiftData

/// Unlike the `WorkoutRecordEditorWrapper`, we don't ever use
/// the main context.
///
/// Having the child context allows us to easily revert all changes while
/// editing.
struct WorkoutTemplateEditorWrapper: View {
	@Environment(\.dismiss) var dismiss
	@State private var viewModel: ViewModel
	
	init(
		workoutId: PersistentIdentifier,
		in container: ModelContainer,
		isNewWorkout: Bool = false
	) {
		self.viewModel = ViewModel(
			workoutId: workoutId,
			in: container,
			isNewWorkout: isNewWorkout
		)
	}
	
	var body: some View {
		WorkoutEditor(workout: viewModel.workout, modelContext: viewModel.modelContext)
			.toolbar {
				if viewModel.isNewWorkout {
					newToolbarContent()
				} else {
					existingToolbarContent()
				}
			}
	}
	
	@ToolbarContentBuilder @MainActor
	func existingToolbarContent() -> some ToolbarContent {
		ToolbarItem(placement: .confirmationAction) {
			Button("Save") {
				viewModel.saveExistingWorkout()
				dismiss()
			}
			.tint(.green)
		}
		
		ToolbarItem(placement: .destructiveAction) {
			Button("Delete") {
				viewModel.deleteExistingWorkout()
				dismiss()
			}
			.tint(.red)
		}
		
		ToolbarItem(placement: .cancellationAction) {
			Button("Cancel") {
				dismiss()
			}
		}
	}
	
	@ToolbarContentBuilder @MainActor
	func newToolbarContent() -> some ToolbarContent {
		ToolbarItem(placement: .confirmationAction) {
			Button("Save") {
				viewModel.saveNewWorkout()
				dismiss()
			}
			.tint(.green)
		}
		
		ToolbarItem(placement: .destructiveAction) {
			Button("Discard") {
				viewModel.cancelNewWorkout()
				dismiss()
			}
			.tint(.red)
		}
		
		ToolbarItem(placement: .cancellationAction) {
			Button("Cancel") {
				viewModel.cancelNewWorkout()
				dismiss()
			}
		}
	}
}

extension WorkoutTemplateEditorWrapper {
	@Observable @MainActor
	class ViewModel {
		var workout: WorkoutTemplate
		let modelContext: ModelContext
		let isNewWorkout: Bool
		let alertManager = AlertManager.shared
		
		init(
			workoutId: PersistentIdentifier,
			in container: ModelContainer,
			isNewWorkout: Bool = false
		) {
			self.modelContext = ModelContext(container)
			self.modelContext.autosaveEnabled = false
			self.workout = modelContext.model(for: workoutId) as? WorkoutTemplate ?? WorkoutTemplate()
			self.isNewWorkout = isNewWorkout
		}
		
		func saveExistingWorkout() {
			if modelContext.hasChanges {
				if workout.name.isEmpty {
					alertManager.addAlert("Didn't save, name can't be empty", type: .warning)
					return
				}
				
				if workout.exercises.count == 0 {
					alertManager.addAlert("Didn't save, exercises can't be empty", type: .warning)
					return
				}
				
				try? modelContext.save()
			}
		}
		
		func deleteExistingWorkout() {
			alertManager.addAlert("Deleting existing workout template", type: .info)
			try? modelContext.transaction {
				workout.exercises.forEach { exercise in
					modelContext.delete(exercise)
				}
				
				modelContext.delete(workout)
			}
		}
		
		func cancelNewWorkout() {
			alertManager.addAlert("Cancelling new workout template", type: .info)
			try? modelContext.transaction {
				workout.exercises.forEach { template in
					modelContext.delete(template)
				}
				
				modelContext.delete(workout)
			}
		}
		
		func saveNewWorkout() {
			alertManager.addAlert("Attempting to complete adding new workout template", type: .info)
			
			if workout.name.isEmpty {
				alertManager.addAlert("Didn't save, name can't be empty", type: .warning)
				modelContext.delete(workout)
				try? modelContext.save()
				return
			}
			
			if workout.exercises.count == 0 {
				alertManager.addAlert("Didn't save, exercises can't be empty", type: .warning)
				modelContext.delete(workout)
				try? modelContext.save()
				return
			}
			
			try? modelContext.save()
		}
	}
}
