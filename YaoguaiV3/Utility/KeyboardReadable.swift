//
//  KeyboardReadable.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 2/1/2025.
//

import Foundation
import Combine
import UIKit

/// Publisher to read keyboard changes.
protocol KeyboardReadable {
	var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardReadable {
	var keyboardPublisher: AnyPublisher<Bool, Never> {
		Publishers.Merge(
			NotificationCenter.default
				.publisher(for: UIResponder.keyboardDidShowNotification)
				.map { _ in true },
			
			NotificationCenter.default
				.publisher(for: UIResponder.keyboardDidHideNotification)
				.map { _ in false }
		)
		.eraseToAnyPublisher()
	}
}

extension KeyboardReadable {
	var keyboardPublisherWithPrevious: AnyPublisher<(previous: Bool, current: Bool), Never> {
		keyboardPublisher
			.removeDuplicates()
			.scan((previous: false, current: false)) { (state, new) in
				return (previous: state.current, current: new)
			}
			.removeDuplicates(by: { $0.previous == $1.previous && $0.current == $1.current })
			.eraseToAnyPublisher()
	}
}
