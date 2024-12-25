//
//  BarebonesUIKeyInput+SelectionHandling.swift
//  LearningPlaygroundV1
//
//  Created by Charles Zhao on 24/12/2024.
//

import UIKit

extension BarebonesUIKeyInput {
	
	/// Selects all text and highlights it.
	func selectAll() {
		isAllSelected = true
		label.backgroundColor = .systemGray2
	}
	
	/// Clears any text selection and removes highlighting.
	func clearSelection() {
		isAllSelected = false
		label.backgroundColor = .clear
	}
	
}
