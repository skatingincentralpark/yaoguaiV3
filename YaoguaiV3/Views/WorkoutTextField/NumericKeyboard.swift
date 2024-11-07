import SwiftUI

struct NumericKeyboardView: View {
	var insertText: (String) -> Void
	var deleteText: () -> Void
	var hideKeyboard: () -> Void
	
	let keyboardHeight: CGFloat
	var backgroundColor: Color
	var spacing: CGFloat
	
	private let numberList = [
		"1", "4", "7",
		".", "2", "5",
		"8", "0", "3",
		"6", "9"
	]
	
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
		spacing: CGFloat = 5
	) {
		self.insertText = insertText
		self.deleteText = deleteText
		self.hideKeyboard = hideKeyboard
		self.keyboardHeight = keyboardHeight
		self.backgroundColor = backgroundColor
		self.spacing = spacing
	}
	
	var body: some View {
		LazyHGrid(rows: rows, alignment: .top, spacing: spacing, content: {
			ForEach(numberList, id: \.self) { number in
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
			
			Button {} label: {
				Text("RPE")
					.numericButtonStyle(length: length)
			}
			
			HStack(spacing: 0 ) {
				Button(action: {}, label: {
					Image(systemName: "minus")
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.background(.orange)
				})
				
				Button(action: {}, label: {
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


#Preview(traits: .sizeThatFitsLayout) {
	NumericKeyboardView(
		insertText: { _ in },
		deleteText: { },
		hideKeyboard: { },
		keyboardHeight: 300,
		backgroundColor: Color.gray
	)
}
