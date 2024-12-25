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
	static private let keyboardHeight: CGFloat = 350
	
	static func createKeyboard(
		onKeyPress: @escaping (String) -> Void,
		onDelete: @escaping () -> Void,
		onDismiss: @escaping () -> Void
	) -> UIInputView {
		let keyboardController = UIHostingController(
			rootView: CustomKeyboard(
				onKeyPress: onKeyPress,
				onDelete: onDelete,
				onDismiss: onDismiss,
				keyboardHeight: keyboardHeight
			)
		)
		
		let inputView = UIInputView(
			frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: keyboardHeight)),
			inputViewStyle: .keyboard
		)
		
		let keyboardView = keyboardController.view!
		keyboardView.translatesAutoresizingMaskIntoConstraints = false
		inputView.addSubview(keyboardView)
		
		NSLayoutConstraint.activate([
			keyboardView.widthAnchor.constraint(equalToConstant: inputView.frame.width)
		])
		
		return inputView
	}
}

