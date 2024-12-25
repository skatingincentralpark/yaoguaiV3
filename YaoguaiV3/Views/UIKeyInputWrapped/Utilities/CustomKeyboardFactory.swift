//
//  CustomKeyboardFactory.swift
//  LearningPlaygroundV1
//
//  Created by Charles Zhao on 24/12/2024.
//

import Foundation
import SwiftUI

@MainActor
struct CustomKeyboardFactory {
	static private let keyboardHeight: CGFloat = 250
	
	static func createKeyboard(
		onKeyPress: @escaping (String) -> Void,
		onDelete: @escaping () -> Void,
		onDismiss: @escaping () -> Void
	) -> UIInputView {
		let keyboardController = UIHostingController(
			rootView: CustomKeyboard(
				onKeyPress: onKeyPress,
				onDelete: onDelete,
				onDismiss: onDismiss
			)
		)
		
		let inputView = UIInputView(frame: .zero, inputViewStyle: .keyboard)
		inputView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		let keyboardView = keyboardController.view!
		keyboardView.translatesAutoresizingMaskIntoConstraints = false
		inputView.addSubview(keyboardView)
		
		NSLayoutConstraint.activate([
			keyboardView.leadingAnchor.constraint(equalTo: inputView.leadingAnchor),
			keyboardView.trailingAnchor.constraint(equalTo: inputView.trailingAnchor),
			keyboardView.topAnchor.constraint(equalTo: inputView.topAnchor),
			keyboardView.bottomAnchor.constraint(equalTo: inputView.bottomAnchor),
			inputView.heightAnchor.constraint(equalToConstant: keyboardHeight) // Adjust as needed
		])
		
		return inputView
	}
}

