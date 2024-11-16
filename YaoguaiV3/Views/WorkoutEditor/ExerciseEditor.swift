//
//  ExerciseEditor.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 21/8/2024.
//

import SwiftUI
import SwiftData

struct ExerciseEditor<T: ExerciseCommon>: View {
	@Bindable var exercise: T
	let modelContext: ModelContext
	var delete: () -> Void
	
	@State private var replaceExerciseSheetPresented = false
	
	init(
		exercise: T,
		delete: @escaping () -> Void,
		modelContext: ModelContext
	) {
		self.exercise = exercise
		self.delete = delete
		self.modelContext = modelContext
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text(exercise.id.hashValue.formatted().prefix(7))
					.lineLimit(1)
					.padding(.horizontal)
					.background(.bar)
				Text(exercise.details?.name ?? "")
				Button("Delete", role: .destructive, action: delete)
				Button("Replace", role: .none, action: {
					replaceExerciseSheetPresented = true
				})
				Spacer()
				Button("Add Set") {
					exercise.addSet()
				}
			}
			
			if exercise.sets.count > 0 {
				HStack {
					VStack(alignment: .leading) {
						ForEach(Array($exercise.sets.enumerated()), id: \.1.id) { index, set in
							SetEditor(
								set: set,
								exercise: exercise.details,
								index: index,
								delete: { _ in
									exercise.removeSet(set.wrappedValue)
								}
							)
							.padding(.leading)
						}
					}
					.overlay(alignment: .leading) {
						Rectangle()
							.frame(width: 1)
					}
				}
				.padding(.leading)
			}
		}
		.sheet(isPresented: $replaceExerciseSheetPresented) {
			ExerciseDetailsList(
				onSelect: {
					if let replacementExercise = modelContext.model(for: $0.id) as? Exercise {
						exercise.replaceDetails(newDetails: replacementExercise)
					}
				},
				category: exercise.details?.category
			)
		}
	}
}

#Preview(traits: .sizeThatFitsLayout) {
	do {
		let (container, _) = try setupPreview()
		
		let workout = getWorkoutRecord(container.mainContext)
		
		container.mainContext.insert(workout)
		
		return ExerciseEditor(exercise: workout.exercises[0], delete: {}, modelContext: container.mainContext)
			.modelContainer(container)
	}  catch {
		return Text("Failed to build preview")
	}
}
