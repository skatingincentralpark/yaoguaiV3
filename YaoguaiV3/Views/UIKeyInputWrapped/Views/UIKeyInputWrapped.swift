//
//  UIKeyInputWrapped.swift
//  LearningPlaygroundV1
//
//  Created by Charles Zhao on 24/12/2024.
//

import Foundation
import UIKit
import SwiftUI

struct UIKeyInputWrapped<T: AllowedNumeric>: UIViewRepresentable {
	@Binding var value: T?
	
	// Keyboard size can be configured
	let keyboardHeight: CGFloat = 300
	
	@Environment(FocusManager<WorkoutRecord>.self) var focusManager
	
	func makeUIView(context: Context) -> BarebonesUIKeyInput<T> {
		let uiKeyInput = BarebonesUIKeyInput<T>(frame: .zero)
		
		// Set initial value
		uiKeyInput.setValue(value)
		
		let valueIsDouble = T("1") is Double
		
		let inputView = CustomKeyboardFactory.createKeyboardV2(
			insertText: { uiKeyInput.insertText($0)},
			deleteText: uiKeyInput.deleteBackward,
			hideKeyboard: { _ = uiKeyInput.resignFirstResponder() },
			keyboardHeight: 250,
			backgroundColor: .brown,
			valueIsDouble: valueIsDouble,
			minus: uiKeyInput.decrement,
			plus: uiKeyInput.increment,
			next: { focusManager.moveFocus(step: 1) }
		)
		
		uiKeyInput.inputView = inputView
		
		// Listen for .valueChanged from the control
		uiKeyInput.addTarget(
			context.coordinator,
			action: #selector(Coordinator.valueDidChange(_:)),
			for: .valueChanged
		)
		
		return uiKeyInput
	}
	
	func updateUIView(_ uiView: BarebonesUIKeyInput<T>, context: Context) {
		context.coordinator.parent = self
		if uiView.getValue() != value {
			uiView.setValue(value)
		}
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	class Coordinator: NSObject {
		var parent: UIKeyInputWrapped
		
		init(_ parent: UIKeyInputWrapped) {
			self.parent = parent
		}
		
		@MainActor
		@objc func valueDidChange(_ sender: Any?) {
			// Because 'sender' is generic, we accept `Any?`, then cast.  We need to do this because objc can't work with generics.
			guard let typedSender = sender as? BarebonesUIKeyInput<T> else { return }
			DispatchQueue.main.async {
				self.parent.value = typedSender.getValue()
			}
		}
	}
}

struct UIKeyInputWrapped_Preview: View {
	@State private var str1: Int? = 1234
	@State private var str2: Double? = 3456789
	@FocusState private var focused: Int?
	
	var body: some View {
		VStack(alignment: .leading, spacing: 5) {
			TextField("", text: .constant("hey"))
				.textFieldStyle(.roundedBorder)
				.frame(width: 80)
			Button("Next") {
				if focused == 0 {
					focused = 1
				} else {
					focused = 0
				}
			}
			.disabled(focused == nil)
			HStack {
				UIKeyInputWrapped(value: $str1)
					.frame(width: 80, height: 34)
					.clipShape(RoundedRectangle(cornerRadius: 6))
					.focused($focused, equals: 0)
					.overlay {
						if focused == 0 {
							RoundedRectangle(cornerRadius: 6)
								.stroke(.green, lineWidth: 4)
						}
					}
				Text("\(str1?.description ?? "Nil")")
				Button("Set Value") {
					str1 = 4321
				}
			}
			HStack {
				UIKeyInputWrapped(value: $str2)
					.frame(width: 80, height: 34)
					.clipShape(RoundedRectangle(cornerRadius: 6))
					.focused($focused, equals: 1)
					.overlay {
						if focused == 1 {
							RoundedRectangle(cornerRadius: 6)
								.stroke(.green, lineWidth: 4)
						}
					}
				Text("\(str2?.description ?? "Nil")")
				Button("Set Value") {
					str2 = 6543
				}
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding()
	}
}

#Preview {
	UIKeyInputWrapped_Preview()
}
