//
//  BarebonesUIKeyInputIntTests.swift
//  BarebonesUIKeyInputIntTests
//
//  Created by Charles Zhao on 24/12/2024.
//

import Testing
@testable import YaoguaiV3

@MainActor
final class BarebonesUIKeyInputIntTests {
	
	var input: BarebonesUIKeyInput<Int>!
	
	init() async throws {
		input = nil
		input = BarebonesUIKeyInput<Int>(frame: .zero)
	}
	
	// MARK: - Initialization Tests
	
	@Test func testInitialization() {
		#expect(input.getValue() == nil, "Initial value should be nil.")
		#expect(input.internalString.isEmpty, "Initial internalString should be empty.")
	}
	
	// MARK: - Insert Text Tests
	
	@Test func testInsertValidSingleCharacter() {
		input.insertText("5")
		#expect(input.getValue() == 5, "Value should be updated to 5.")
		#expect(input.internalString == "5", "internalString should be '5'.")
	}
	
	@Test func testInsertMultipleCharacters() {
		input.insertText("12")
		#expect(input.getValue() == nil, "Value should remain nil for multiple characters.")
		#expect(input.internalString.isEmpty, "internalString should remain empty.")
	}
	
	@Test func testInsertNonNumericCharacter() {
		input.insertText("a")
		#expect(input.getValue() == nil, "Value should remain nil for non-numeric characters.")
		#expect(input.internalString.isEmpty, "internalString should remain empty.")
	}
	
	@Test func testInsertTabKey() {
		input.insertText("\t")
		// Assuming resignFirstResponder affects some state, but since it's UI-related, you might need to mock or observe changes.
		// For simplicity, we'll just check that internalString and value remain unchanged.
		#expect(input.getValue() == nil, "Value should remain nil after inserting tab.")
		#expect(input.internalString.isEmpty, "internalString should remain empty after inserting tab.")
	}
	
	@Test func testInsertWhenAllSelected() {
		input.selectAll()
		input.insertText("7")
		#expect(input.getValue() == 7, "Value should be updated to 7 after replacing all.")
		#expect(input.internalString == "7", "internalString should be '7' after replacing all.")
		#expect(!input.isAllSelected, "isAllSelected should be false after replacing all.")
	}
	
	// MARK: - Delete Backward Tests
	
	@Test func testDeleteBackwardWhenEmpty() {
		input.deleteBackward()
		#expect(input.getValue() == nil, "Value should remain nil when deleting from empty input.")
		#expect(input.internalString.isEmpty, "internalString should remain empty when deleting from empty input.")
	}
	
	@Test func testDeleteBackwardWithSingleCharacter() {
		input.insertText("9")
		input.deleteBackward()
		#expect(input.getValue() == nil, "Value should be nil after deleting the only character.")
		#expect(input.internalString.isEmpty, "internalString should be empty after deleting the only character.")
	}
	
	@Test func testDeleteBackwardWhenAllSelected() {
		input.insertText("5")
		input.insertText("5")
		input.selectAll()
		input.deleteBackward()
		#expect(input.getValue() == nil, "Value should be nil after deleting all selected text.")
		#expect(input.internalString.isEmpty, "internalString should be empty after deleting all selected text.")
		#expect(!input.isAllSelected, "isAllSelected should be false after deleting all text.")
	}
	
	@Test func testDeleteBackwardMultipleTimes() {
		input.insertText("1")
		input.insertText("2")
		input.insertText("3")
		input.deleteBackward()
		#expect(input.getValue() == 12, "Value should be updated to 12 after deleting last character.")
		#expect(input.internalString == "12", "internalString should be '12' after deleting last character.")
	}
	
	// MARK: - Constraint Tests
	
	@Test func testInsertBeyondMaxValue() {
		for char in "99999" {
			input.insertText(String(char))
		}
		#expect(input.getValue() == 9999, "Value should be clamped to 9999.")
		#expect(input.internalString == "9999", "internalString should be clamped to '9999'.")
	}
	
	@Test func testInsertLeadingZeros() {
		input.insertText("0")
		input.insertText("0")
		input.insertText("5")
		#expect(input.getValue() == 5, "Value should be 5 after inserting leading zeros.")
		#expect(input.internalString == "005", "internalString should be '005'.")
		// Depending on your trimming logic, you might want internalString to be '5'.
	}
	
	// MARK: - Selection Tests
	
	@Test func testSelectAllAndInsert() {
		input.insertText("3")
		input.insertText("4")
		input.selectAll()
		input.insertText("7")
		#expect(input.getValue() == 7, "Value should be updated to 7 after replacing all selected text.")
		#expect(input.internalString == "7", "internalString should be '7' after replacing all selected text.")
	}
	
	// MARK: - Value Management Tests
	
	@Test func testSetValue() {
		input.setValue(8)
		#expect(input.getValue() == 8, "Value should be set to 8.")
		#expect(input.internalString == "8", "internalString should be '8' after setting value.")
	}
	
	@Test func testSetValueNil() {
		input.setValue(nil)
		#expect(input.getValue() == nil, "Value should be nil after setting value to nil.")
		#expect(input.internalString.isEmpty, "internalString should be empty after setting value to nil.")
	}
}
