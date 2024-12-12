//
//  ExerciseDetailsEditor.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 28/9/2024.
//

import SwiftUI
import SwiftData

struct ExerciseDetailsEditor: View {
	// This may have to be a @Bindable
	let exercise: Exercise?
	
	@State private var name: String = ""
	@State private var category: ExerciseCategory = .weightAndReps
	
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	private var editorTitle: String {
		exercise == nil ? "Add Exercise" : "Edit Exercise"
	}
	
	init(exercise: Exercise? = nil) {
		self.exercise = exercise
	}
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading) {
					Text(name)
						.font(.title)
					Text(category.title)
						.font(.title3)
					
					LabeledContent {
						TextField("Name", text: $name)
							.textFieldStyle(.roundedBorder)
					} label: {
						Text("Name:")
					}
					
					ExerciseCategoryPicker(selectedCategory: $category)
				}
				.padding()
				.onAppear {
					if let exercise {
						// Edit the incoming exercise.
						name = exercise.name
						category = exercise.category
					}
				}
				.toolbar {
					ToolbarItem(placement: .principal) {
						Text(editorTitle)
					}
					
					ToolbarItem(placement: .confirmationAction) {
						Button("Save") {
							withAnimation {
								save()
								dismiss()
							}
						}
					}
					
					ToolbarItem(placement: .cancellationAction) {
						Button("Cancel", role: .cancel) {
							dismiss()
						}
					}
				}
			}
		}
	}
	
	struct ExerciseCategoryPicker: View {
		// The binding allows the view to modify an external state variable
		@Binding var selectedCategory: ExerciseCategory
		
		var body: some View {
			Picker("Exercise Category", selection: $selectedCategory) {
				// Loop through all cases of ExerciseCategory and display their titles
				ForEach(ExerciseCategory.allCases, id: \.self) { category in
					Text(category.title).tag(category)
				}
			}
			.background(.quinary)
			.clipShape(RoundedRectangle(cornerRadius: 8))
		}
	}
}

extension ExerciseDetailsEditor {
	private func save() {
		if let exercise {
			// Edit the exercise.
			exercise.name = name
			exercise.category = category
		} else {
			// Add an exercise.
			let newExercise = Exercise(name: name, category: category)
			modelContext.insert(newExercise)
			try? modelContext.save()
		}
	}
}

#Preview("Existing Exercise") {
	ExerciseDetailsEditor(exercise: Exercise(name: "Burpees", category: .reps))
}

#Preview("New Exercise") {
	ExerciseDetailsEditor()
}
