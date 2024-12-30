//
//  BarebonesUIKeyInput.swift
//  LearningPlaygroundV1
//
//  Created by Charles Zhao on 24/12/2024.
//

import Foundation
import UIKit

class BarebonesUIKeyInput<T: AllowedNumeric>: UIControl, UIKeyInput {
	
	// MARK: - Properties
	
	internal let label = UILabel()
	internal var currentValue: T?
	internal var internalString: String = "" {
		didSet {
			DispatchQueue.main.async {
				self.label.text = self.internalString
				self.sendActions(for: .valueChanged) // Notify listeners for .valueChanged
			}
		}
	}
	internal var isAllSelected = false
	internal var _customInputView: UIView? = nil
	override var inputView: UIView? {
		get { _customInputView }
		set { _customInputView = newValue }
	}
	internal var hasText: Bool { !internalString.isEmpty }
	
	// MARK: - Init
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("Use init(frame:) instead.")
	}
	
	// MARK: - Tap / Focus
	
	@objc internal func handleTap() {
		_ = becomeFirstResponder()
	}
	
	override var canBecomeFirstResponder: Bool { true }
	
	override func becomeFirstResponder() -> Bool {
		let didBecome = super.becomeFirstResponder()
		if didBecome { selectAll() }
		return didBecome
	}
	
	override func resignFirstResponder() -> Bool {
		let didResign = super.resignFirstResponder()
		if didResign { clearSelection() }
		return didResign
	}
	
	// MARK: - UIKeyInput
	
	internal func insertText(_ text: String) {
		// Only allow single character inputs
		if text.count != 1 { return }
		
		// 1. If it's a tab, resign first responder.
		if text == "\t" {
			_  = resignFirstResponder()
			return
		}
		
		// 2. "All selected" logic:
		if isAllSelected {
			replaceAllText(with: text)
			return
		}
		
		insert(text)
	}
	
	internal func deleteBackward() {
		guard !internalString.isEmpty else { return }
		
		if isAllSelected {
			internalString = ""
			currentValue = nil
			clearSelection()
			return
		}
		
		internalString.removeLast()
		currentValue = T(internalString)
	}
	
	// MARK: - Public Methods
	
	public func setValue(_ newValue: T?) {
		currentValue = newValue
		internalString = newValue?.formattedString() ?? ""
	}
	
	public func getValue() -> T? {
		currentValue
	}
	
	public func increment() {
		adjustValue(.increment)
	}
	
	public func decrement() {
		adjustValue(.decrement)
	}
}
