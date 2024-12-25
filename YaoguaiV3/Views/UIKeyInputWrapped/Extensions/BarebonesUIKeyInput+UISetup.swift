//
//  BarebonesUIKeyInput+UISetup.swift
//  LearningPlaygroundV1
//
//  Created by Charles Zhao on 24/12/2024.
//

import Foundation
import UIKit

extension BarebonesUIKeyInput {
	
	/// Sets up the UI components and constraints.
	func setupUI() {
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .left
		label.backgroundColor = .clear
		label.lineBreakMode = .byClipping
		clipsToBounds = true
		
		addSubview(label)
		
		let padding: CGFloat = 8
		NSLayoutConstraint.activate([
			label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
			label.topAnchor.constraint(equalTo: topAnchor, constant: padding),
			label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
		])
		
		backgroundColor = .systemGray6
		addTarget(self, action: #selector(handleTap), for: .touchUpInside)
	}
	
}
