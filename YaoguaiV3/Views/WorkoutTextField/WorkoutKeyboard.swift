import SwiftUI

struct WorkoutKeyboard: View {
	let insertText: (String) -> Void
	let deleteText: () -> Void
	let hideKeyboard: () -> Void
	let minus: () -> Void
	let plus: () -> Void
	let next: () -> Void
	let valueIsDouble: Bool
	let keyboardHeight: CGFloat
	let backgroundColor: Color
	let spacing: CGFloat
	let rows: [GridItem]
	
	private let numbersRow1 = [1, 2, 3]
	private let numbersRow2 = [3, 4, 5]
	private let numbersRow3 = [7, 8, 9]
	private let numbersRow4 = [0]
	
	@State private var rpeSelectorShowing: Bool = false
	
	@Namespace private var animation
	
	init(
		insertText: @escaping (String) -> Void,
		deleteText: @escaping () -> Void,
		hideKeyboard: @escaping () -> Void,
		keyboardHeight: CGFloat,
		backgroundColor: Color,
		spacing: CGFloat = 5,
		valueIsDouble: Bool,
		minus: @escaping () -> Void,
		plus: @escaping () -> Void,
		next: @escaping () -> Void
	) {
		self.insertText = insertText
		self.deleteText = deleteText
		self.hideKeyboard = hideKeyboard
		self.keyboardHeight = keyboardHeight
		self.backgroundColor = backgroundColor
		self.spacing = spacing
		self.valueIsDouble = valueIsDouble
		self.minus = minus
		self.plus = plus
		self.next = next
		self.rows = Array(repeating: GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: spacing), count: 4)
	}
	
	var body: some View {
		LazyVGrid(
			columns: rows,
			alignment: .leading,
			spacing: spacing,
			content: {
				// ROW 1
				NumericButtons(numbers: numbersRow1, insertText: insertText)
				
				Button(action: hideKeyboard, label: {
					Image(systemName: "keyboard.chevron.compact.down")
						.workoutKeyboardStyle()
				})
				
				// ROW 2
				NumericButtons(numbers: numbersRow2, insertText: insertText)
				
				Button {
					withAnimation(.spring(duration: 0.1)) {
						rpeSelectorShowing.toggle()
					}
				} label: {
					Text("RPE")
						.workoutKeyboardStyle()
						.matchedGeometryEffect(id: "KeyboardChevronDownButton", in: animation)
				}
				
				// ROW 3
				NumericButtons(numbers: numbersRow3, insertText: insertText)
				
				HStack(spacing: 0 ) {
					Button(action: minus, label: {
						Image(systemName: "minus")
							.frame(maxWidth: .infinity, maxHeight: .infinity)
							.background(.orange)
					})
					
					Button(action: plus, label: {
						Image(systemName: "plus")
							.frame(maxWidth: .infinity, maxHeight: .infinity)
							.background(.orange)
					})
				}
				.workoutKeyboardStyle(backgroundColor: .clear)
				
				// ROW 4
				if valueIsDouble {
					Button(action: {
						insertText(".")
					}, label: {
						Text(".")
							.workoutKeyboardStyle()
							.font(.system(size: 32))
					})
				} else {
					Color.clear
				}
				
				NumericButtons(numbers: numbersRow4, insertText: insertText)
				
				Button(action: deleteText, label: {
					Image(systemName: "delete.backward")
						.workoutKeyboardStyle()
				})
				
				Button {} label: {
					Text("Next")
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.background(.orange)
						.clipShape(RoundedRectangle(cornerRadius: 8))
				}
			}
		)
		.bold()
		.padding(.horizontal, 5)
		.padding(.top, 32)
		.padding(.bottom, 16)
		.frame(height: keyboardHeight)
		.frame(maxWidth: .infinity)
		.background(backgroundColor)
		.overlay {
			if rpeSelectorShowing {
				ZStack {
					Color.purple
						.opacity(0.95)
					
					VStack(alignment: .trailing) {
						HStack {
							Spacer()
							
							Button {
								withAnimation(.spring(duration: 0.1)) {
									rpeSelectorShowing.toggle()
								}
							} label: {
								Image(systemName: "xmark.circle")
									.workoutKeyboardStyle()
							}
							.frame(height: 50, alignment: .topTrailing)
							.matchedGeometryEffect(id: "KeyboardChevronDownButton", in: animation)
						}
					}
				}
				.padding(.horizontal, 5)
				.padding(.top, 32)
				.padding(.bottom, 16)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(.purple)
			}
		}
	}
	
	struct NumericButtons: View {
		let numbers: [Int]
		var labels: [String] { numbers.map { String($0) } }
		let insertText: (String) -> Void
		
		var body: some View {
			ForEach(labels, id: \.self) { number in
				Button(action: {
					insertText(number)
				}, label: {
					Text(number)
						.workoutKeyboardStyle()
						.font(.system(size: 32))
				})
			}
		}
	}
}

fileprivate struct WorkoutButtonStyle: ViewModifier {
	let backgroundColor: Color
	
	func body(content: Content) -> some View {
		content
			.frame(maxWidth: .infinity, minHeight: 50, maxHeight: .infinity)
			.background(backgroundColor)
			.clipShape(RoundedRectangle(cornerRadius: 8))
	}
}

extension View {
	fileprivate func workoutKeyboardStyle(backgroundColor: Color = .orange) -> some View {
		self.modifier(WorkoutButtonStyle(backgroundColor: backgroundColor))
	}
}

#Preview("Without Decimal", traits: .sizeThatFitsLayout) {
	WorkoutKeyboard(
		insertText: { _ in },
		deleteText: { },
		hideKeyboard: { },
		keyboardHeight: 300,
		backgroundColor: Color.gray,
		valueIsDouble: false,
		minus: {},
		plus: {},
		next: {}
	)
}

#Preview("With Decimal", traits: .sizeThatFitsLayout) {
	WorkoutKeyboard(
		insertText: { _ in },
		deleteText: { },
		hideKeyboard: { },
		keyboardHeight: 300,
		backgroundColor: Color.gray,
		valueIsDouble: true,
		minus: {},
		plus: {},
		next: {}
	)
}
