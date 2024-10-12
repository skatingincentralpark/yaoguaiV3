//
//  SimpleTextFieldV2.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 13/8/2024.
//

import SwiftUI

class PaddedTextField: UITextField {
	var textPadding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
	
	override func textRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.inset(by: textPadding)
	}
	
	override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.inset(by: textPadding)
	}
	
	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.inset(by: textPadding)
	}
}

struct SimpleTextFieldV2<V>: View where V: Numeric & LosslessStringConvertible {
	@Binding var value: V?
	var id: Int = UUID().hashValue
	
	@FocusState private var focused: Bool
	
	var body: some View {
		SimpleTextFieldImpl(value: $value, id: id, keyboardHeight: 300)
			.focused($focused)
			.frame(width: 70, height: 30)
			.background(.yellow)
			.clipShape(RoundedRectangle(cornerRadius: 6))
			.overlay {
				RoundedRectangle(cornerRadius: 6)
					.stroke(focused ? .green : .gray, lineWidth: 3.0)
			}
	}
}

struct SimpleTextFieldImpl<V>: UIViewRepresentable where V: Numeric & LosslessStringConvertible {
	@Binding var value: V?
	var id: Int
	var keyboardHeight: CGFloat
	
	func makeUIView(context: Context) -> UIView {
		let textField = PaddedTextField()
		textField.layer.cornerRadius = 8.0
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.tag = id
		textField.delegate = context.coordinator
		
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.opacity = 0.2
		button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
		button.tag = id
		
		let containerView = UIView()
		containerView.addSubview(textField)
		containerView.addSubview(button)
		
		func setupKeyboard() {
			let inputView = UIInputView()
			
			let AnimalKeyboardViewController = UIHostingController(
				rootView: NumericKeyboardView(
					insertText: { newText in
						if let selectedTextRange = textField.selectedTextRange {
							let currentText = textField.text ?? ""
							let valueIsDouble = V("1") is Double

							if valueIsDouble {
								if newText == "." {
									if currentText.contains(".") && !textField.isAllTextSelected {
										return
									}
									textField.replace(selectedTextRange, withText: newText)
								} else {
									textField.replace(selectedTextRange, withText: newText)
									if let updatedText = textField.text {
										value = V(updatedText)
									}
								}
							} else {
								if newText == "." {
									return
								}
								textField.replace(selectedTextRange, withText: newText)
								if let updatedText = textField.text {
									value = V(updatedText)
								}
							}
						}
					},
					deleteText: {
						textField.deleteBackward()
						
						if let newText = textField.text {
							textField.text = newText
							
							if let textFieldText = textField.text {
								value = V(textFieldText)
							}
						}
					},
					hideKeyboard: { textField.endEditing(true) },
					keyboardHeight: keyboardHeight,
					backgroundColor: .white
				))
			
			let animalKeyboardView = AnimalKeyboardViewController.view!
			animalKeyboardView.translatesAutoresizingMaskIntoConstraints = false
			
			inputView.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: keyboardHeight))
			inputView.addSubview(animalKeyboardView)
			
			NSLayoutConstraint.activate([
				animalKeyboardView.widthAnchor.constraint(equalToConstant: inputView.frame.width)
			])
			
			textField.inputView = inputView
			//			textField.inputView = UIPickerView()
		}
		
		setupKeyboard()
		
		NSLayoutConstraint.activate([
			// Text field constraints
			textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			textField.topAnchor.constraint(equalTo: containerView.topAnchor),
			textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
			
			// Button constraints
			button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			button.topAnchor.constraint(equalTo: textField.topAnchor),
			button.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
		])
		
		return containerView
	}
	
	/// Updates the state of the specified view with new information from SwiftUI.
	func updateUIView(_ uiView: UIView, context: Context) {
		//		if let textField = uiView.subviews.first(where: { $0 is UITextField }) as? UITextField {
		//			if let value {
		//				textField.text = String(value)
		//			}
		//		}
		if let textField = uiView.subviews.first(where: { $0 is UITextField }) as? UITextField {
			if let value = value {
				// Convert the value to a Double
				let doubleValue = Double(String(value)) ?? 0.0
				
				// Check if the value is a whole number
				if doubleValue == floor(doubleValue) {
					// If it's a whole number, remove the decimal part
					textField.text = String(Int(doubleValue))
				} else {
					// Otherwise, show the full number with decimal part
					textField.text = String(value)
				}
			}
		}
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(value: $value)
	}
	
	class Coordinator: NSObject, UITextFieldDelegate {
		var value: Binding<V?>
		
		init(value: Binding<V?>) {
			self.value = value
		}
		
		@objc func buttonTapped(_ sender: UIButton) {
			guard let containerView = sender.superview,
				  let textField = containerView.subviews.first(where: { $0 is UITextField && $0.tag == sender.tag }) as? UITextField else {
				return
			}
			
			/// Focuses and selects all
			textField.becomeFirstResponder()
			textField.selectAll(nil)
		}
		
		/// This delegate method is called when the user types or deletes characters in the UITextField.
		/// It attempts to convert the updated string (newValue) to the numeric type V.
		/// It ensures that the SwiftUI binding of `value` is updated
		func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
			let text = textField.text as NSString?
			let newValue = text?.replacingCharacters(in: range, with: string)
			if let number = V(newValue ?? "0") {
				self.value.wrappedValue = number
				return true
			} else {
				if nil == newValue || newValue!.isEmpty {
					self.value.wrappedValue = 0
				}
				return false
			}
		}
		
		func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
			if reason == .committed {
				textField.resignFirstResponder()
			}
		}
		
	}
}
