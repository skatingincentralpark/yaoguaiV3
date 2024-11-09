import SwiftUI

struct WorkoutKeyboard: View {
	var insertText: (String) -> Void
	var deleteText: () -> Void
	var hideKeyboard: () -> Void
	var minus: () -> Void
	var plus: () -> Void
	var valueIsDouble: Bool
	
	let keyboardHeight: CGFloat
	var backgroundColor: Color
	var spacing: CGFloat
	
	private var numbers1 = [ "1", "4", "7" ]
	private var numbers2 = [ "2", "5", "8", "0", "3", "6", "9" ]
	
	@State private var rpeSelectorShowing: Bool = false
	
	@Namespace private var animation
	
	var rows: [GridItem] {
		[
			.init(.flexible(minimum: 0, maximum: .infinity), spacing: spacing),
			.init(.flexible(minimum: 0, maximum: .infinity), spacing: spacing),
			.init(.flexible(minimum: 0, maximum: .infinity), spacing: spacing),
			.init(.flexible(minimum: 0, maximum: .infinity), spacing: spacing),
		]
	}
	
	let length: (CGFloat, Axis) -> CGFloat = { length, axis in
		return (length - 25) / 4 // essentially rows.count
	}
	
	init(
		insertText: @escaping (String) -> Void,
		deleteText: @escaping () -> Void,
		hideKeyboard: @escaping () -> Void,
		keyboardHeight: CGFloat,
		backgroundColor: Color,
		spacing: CGFloat = 5,
		valueIsDouble: Bool,
		minus: @escaping () -> Void = {},
		plus: @escaping () -> Void = {}
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
	}
	
	var body: some View {
		LazyHGrid(rows: rows, alignment: .top, spacing: spacing, content: {
			ForEach(numbers1, id: \.self) { number in
				Button(action: {
					insertText(number)
				}, label: {
					Text(number)
						.numericButtonStyle(length: length)
						.font(.system(size: 32))
				})
			}
			
			if valueIsDouble {
				Button(action: {
					insertText(".")
				}, label: {
					Text(".")
						.numericButtonStyle(length: length)
						.font(.system(size: 32))
				})
			} else {
				Color.clear
			}
			
			ForEach(numbers2, id: \.self) { number in
				Button(action: {
					insertText(number)
				}, label: {
					Text(number)
						.numericButtonStyle(length: length)
						.font(.system(size: 32))
				})
			}
			
			Button(action: deleteText, label: {
				Image(systemName: "delete.backward")
					.numericButtonStyle(length: length)
			})
			
			Button(action: hideKeyboard, label: {
				Image(systemName: "keyboard.chevron.compact.down")
					.numericButtonStyle(length: length)
			})
			
			Button {
				withAnimation(.spring(duration: 0.1)) {
					rpeSelectorShowing.toggle()
				}
			} label: {
				Text("RPE")
					.numericButtonStyle(length: length)
					.matchedGeometryEffect(id: "KeyboardChevronDownButton", in: animation)
			}
			
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
			.numericButtonStyle(length: length, backgroundColor: .clear)
			
			Button {} label: {
				Text("Next")
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.containerRelativeFrame(.horizontal, length)
					.background(.orange)
					.clipShape(RoundedRectangle(cornerRadius: 8))
			}
		})
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
									.numericButtonStyle(length: length)
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
}

fileprivate struct NumericButtonStyle: ViewModifier {
	let length: (CGFloat, Axis) -> CGFloat
	let backgroundColor: Color

	func body(content: Content) -> some View {
		content
			.frame(maxHeight: .infinity)
			.containerRelativeFrame(.horizontal, length)
			.background(backgroundColor)
			.clipShape(RoundedRectangle(cornerRadius: 8))
	}
}

extension View {
	fileprivate func numericButtonStyle(length: @escaping (CGFloat, Axis) -> CGFloat, backgroundColor: Color = .orange) -> some View {
		self.modifier(NumericButtonStyle(length: length, backgroundColor: backgroundColor))
	}
}

#Preview("Without Decimal", traits: .sizeThatFitsLayout) {
	WorkoutKeyboard(
		insertText: { _ in },
		deleteText: { },
		hideKeyboard: { },
		keyboardHeight: 300,
		backgroundColor: Color.gray,
		valueIsDouble: false
	)
}

#Preview("With Decimal", traits: .sizeThatFitsLayout) {
	WorkoutKeyboard(
		insertText: { _ in },
		deleteText: { },
		hideKeyboard: { },
		keyboardHeight: 300,
		backgroundColor: Color.gray,
		valueIsDouble: true
	)
}
