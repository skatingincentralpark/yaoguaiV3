//
//  BarebonesUIKeyInputDoubleTests.swift
//  BarebonesUIKeyInputDoubleTests
//
//  Created by Charles Zhao on 24/12/2024.
//

import Testing
@testable import YaoguaiV3

@MainActor
final class BarebonesUIKeyInputDoubleTests {
	
	var input: BarebonesUIKeyInput<Double>!
	
	init() async throws {
		input = nil
		input = BarebonesUIKeyInput<Double>(frame: .zero)
	}
	
	// MARK: - Initialization Tests
	
	@Test func testInitialization() {
		#expect(input.getValue() == nil, "Initial value should be nil.")
		#expect(input.internalString.isEmpty, "Initial internalString should be empty.")
	}
	
	// MARK: - Insert Text Tests
	
	@Test func testInsertValidSingleCharacter() {
		input.insertText("3")
		#expect(input.getValue() == 3.0, "Value should be updated to 3.0.")
		#expect(input.internalString == "3", "internalString should be '3'.")
	}
	
	@Test func testInsertDecimalPoint() {
		input.insertText("1")
		input.insertText(".")
		#expect(input.getValue() == 1.0, "Value should be updated to 1.0 after inserting decimal point.")
		#expect(input.internalString == "1.", "internalString should be '1.' after inserting decimal point.")
	}
	
	@Test func testInsertMultipleDecimalPoints() {
		input.insertText("1")
		input.insertText(".")
		input.insertText(".")
		#expect(input.internalString == "1.", "internalString should not allow multiple decimal points.")
		#expect(input.getValue() == 1.0, "Value should remain 1.0 after attempting to insert second decimal point.")
	}
	
	@Test func testInsertNonNumericCharacter() {
		input.insertText("a")
		#expect(input.getValue() == nil, "Value should remain nil for non-numeric characters.")
		#expect(input.internalString.isEmpty, "internalString should remain empty.")
	}
	
	@Test func testInsertMultipleCharacters() {
		input.insertText("12")
		#expect(input.getValue() == nil, "Value should remain nil for multiple characters.")
		#expect(input.internalString.isEmpty, "internalString should remain empty.")
	}
	
	@Test func testInsertWhenAllSelected() {
		input.insertText("4")
		input.insertText("2")
		input.selectAll()
		input.insertText("7")
		#expect(input.getValue() == 7.0, "Value should be updated to 7.0 after replacing all.")
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
		input.insertText("5")
		input.deleteBackward()
		#expect(input.getValue() == nil, "Value should be nil after deleting the only character.")
		#expect(input.internalString.isEmpty, "internalString should be empty after deleting the only character.")
	}
	
	@Test func testDeleteBackwardWithDecimal() {
		input.insertText("7")
		input.insertText(".")
		input.deleteBackward()
		#expect(input.getValue() == 7.0, "Value should be updated to 7.0 after deleting decimal point.")
		#expect(input.internalString == "7", "internalString should be '7' after deleting decimal point.")
	}
	
	@Test func testDeleteBackwardWhenAllSelected() {
		input.insertText("6")
		input.insertText("4")
		input.selectAll()
		input.deleteBackward()
		#expect(input.getValue() == nil, "Value should be nil after deleting all selected text.")
		#expect(input.internalString.isEmpty, "internalString should be empty after deleting all selected text.")
		#expect(!input.isAllSelected, "isAllSelected should be false after deleting all text.")
	}
	
	@Test func testDeleteBackwardMultipleTimes() {
		input.insertText("1")
		input.insertText("2")
		input.insertText(".")
		input.insertText("3")
		input.deleteBackward()
		#expect(input.getValue() == 12.0, "Value should be updated to 12.0 after deleting last character.")
		#expect(input.internalString == "12.", "internalString should be '12.' after deleting last character.")
	}
	
	// MARK: - Constraint Tests
	
	@Test func testInsertBeyondMaxValue() {
		let inputString = "10000.0" // Exceeds MAX_VALUE_DOUBLE = 9999.99
		for char in inputString {
			input.insertText(String(char))
		}
		#expect(input.getValue() == 1000.0, "Value should be clamped to 9999.99.")
		#expect(input.internalString == "1000.0", "internalString should be clamped to '9999.99'.")
	}
	
	@Test func testInsertDigitsBeforeDecimalLimit() {
		input.insertText("1")
		input.insertText("2")
		input.insertText("3")
		input.insertText("4")
		input.insertText("5") // Exceeds allowedDigitsBeforeDecimal = 4
		#expect(input.internalString == "1234", "internalString should not exceed 4 digits before decimal.")
		#expect(input.getValue() == 1234.0, "Value should be clamped to 1234.0.")
	}
	
	@Test func testInsertDigitsAfterDecimalLimit() {
		input.insertText("1")
		input.insertText(".")
		input.insertText("2")
		input.insertText("3")
		input.insertText("4")
		input.insertText("5") // Exceeds allowedDigitsAfterDecimal = 3
		#expect(input.internalString == "1.234", "internalString should not exceed 2 digits after decimal.")
		#expect(input.getValue() == 1.234, "Value should be 1.234.")
	}
	
	// MARK: - Selection Tests
	
	@Test func testSelectAllAndInsert() {
		input.insertText("8")
		input.insertText("9")
		input.selectAll()
		input.insertText("5")
		#expect(input.getValue() == 5.0, "Value should be updated to 5.0 after replacing all selected text.")
		#expect(input.internalString == "5", "internalString should be '5' after replacing all selected text.")
	}
	
	// MARK: - Value Management Tests
	
	@Test func testSetValue() {
		input.setValue(12.34)
		#expect(input.getValue() == 12.34, "Value should be set to 12.34.")
		#expect(input.internalString == "12.34", "internalString should be '12.34' after setting value.")
	}
	
	@Test func testSetValueWhole() {
		input.setValue(12)
		#expect(input.getValue() == 12.0, "Value should be set to 12.0.")
		#expect(input.internalString == "12", "internalString should be '12' after setting value.")
	}
	
	@Test func testSetValueBiggerThanMax() {
		input.setValue(99999.9999)
		#expect(input.getValue() == 99999.9999, "Value should be set to 99999.9999.")
		#expect(input.internalString == "99999.9999", "internalString should be '99999.9999' after setting value.")
	}
	
	@Test func testSetValueNil() {
		input.insertText("7")
		input.setValue(nil)
		#expect(input.getValue() == nil, "Value should be nil after setting value to nil.")
		#expect(input.internalString.isEmpty, "internalString should be empty after setting value to nil.")
	}
	
	// MARK: - Edge Case Tests
	
	@Test func testInsertLeadingDecimalPoint() {
		input.insertText(".")
		#expect(input.getValue() == nil, "Value should remain nil for leading decimal point.")
		#expect(input.internalString == "", "internalString should be '.' after inserting leading decimal point.")
	}
	
	@Test func testInsertDecimalPointAfterDigits() {
		input.insertText("9")
		input.insertText(".")
		#expect(input.getValue() == 9.0, "Value should be updated to 9.0 after inserting decimal point.")
		#expect(input.internalString == "9.", "internalString should be '9.' after inserting decimal point.")
	}
}

//enum InputError: Error {
//	case parsingFailed
//}
//
//class BarebonesUIKeyInput<T: AllowedNumeric>: UIControl, UIKeyInput {
//	
//	// Modify methods to throw errors
//	internal func insertForInt(_ c: String) throws {
//		let candidate = internalString + c
//		guard FormatterUtilities.isValidIntInput(candidate) else { return }
//		guard let parsed = Int(candidate) else { throw InputError.parsingFailed }
//		// ... rest of the logic
//	}
//	
//	// Update test cases to handle errors
//	func testInsertForIntThrows() {
//		XCTAssertThrowsError(try input.insertForInt("a")) { error in
//			XCTAssertEqual(error as? InputError, InputError.parsingFailed)
//		}
//	}
//}
