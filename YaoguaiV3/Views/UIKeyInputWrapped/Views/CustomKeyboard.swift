//
//  CustomKeyboard.swift
//  LearningPlaygroundV1
//
//  Created by Charles Zhao on 21/12/2024.
//

import SwiftUI

struct CustomKeyboard: View {
	// Callbacks to communicate with the hosting environment
	let onKeyPress: (String) -> Void
	let onDelete: () -> Void
	let onDismiss: () -> Void
	let keyboardHeight: CGFloat

	var body: some View {
		VStack(spacing: 16) {
			// A simple row of numbers
			HStack(spacing: 16) {
				ForEach(["1","2","3"], id: \.self) { key in
					Button(action: {
						onKeyPress(key)
					}) {
						Text(key)
							.frame(width: 40, height: 40)
							.background(Color.blue.opacity(0.2))
							.cornerRadius(8)
					}
				}
			}
			
			// A simple row of numbers
			HStack(spacing: 16) {
				ForEach(["3","4","5"], id: \.self) { key in
					Button(action: {
						onKeyPress(key)
					}) {
						Text(key)
							.frame(width: 40, height: 40)
							.background(Color.green.opacity(0.2))
							.cornerRadius(8)
					}
				}
			}
			
			// A simple row of numbers
			HStack(spacing: 16) {
				ForEach(["6","7","8"], id: \.self) { key in
					Button(action: {
						onKeyPress(key)
					}) {
						Text(key)
							.frame(width: 40, height: 40)
							.background(Color.orange.opacity(0.2))
							.cornerRadius(8)
					}
				}
			}

			// A simple row of numbers
			HStack(spacing: 16) {
				ForEach(["9",".","0"], id: \.self) { key in
					Button(action: {
						onKeyPress(key)
					}) {
						Text(key)
							.frame(width: 40, height: 40)
							.background(Color.pink.opacity(0.2))
							.cornerRadius(8)
					}
				}
			}

			// Delete and Dismiss buttons
			HStack(spacing: 16) {
				Button(action: {
					onDelete()
				}) {
					Text("Delete")
						.frame(width: 60, height: 40)
						.background(Color.red.opacity(0.2))
						.cornerRadius(8)
				}

				Button(action: {
					onDismiss()
				}) {
					Text("Done")
						.frame(width: 60, height: 40)
						.background(Color.gray.opacity(0.2))
						.cornerRadius(8)
				}
			}
		}
		.padding(16)
		.frame(height: keyboardHeight)
		.frame(maxWidth: .infinity)
		.background(.secondary.opacity(0.2))
	}
}

// MARK: - Preview
struct CustomKeyboard_Preview: View {
	var body: some View {
		CustomKeyboard(
			onKeyPress: { character in
				print("Key Pressed:", character)
			},
			onDelete: {
				print("Delete pressed")
			},
			onDismiss: {
				print("Dismiss pressed")
			},
			keyboardHeight: 250
		)
		.previewLayout(.sizeThatFits)
	}
}

#Preview {
	CustomKeyboard_Preview()
}
