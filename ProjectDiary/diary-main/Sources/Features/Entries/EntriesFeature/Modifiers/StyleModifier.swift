import Models
import Styles
import SwiftUI

struct StyleModifier: ViewModifier {
	let style: StyleType
	
	func body(content: Content) -> some View {
		content
			.modifier(HourEntryModifier(style: style))
		
	}
}

struct HourEntryModifier: ViewModifier {
	let style: StyleType
	
	func body(content: Content) -> some View {
		content
			.padding(style.padding)
			.border(style.boderColor)
			.background(style.backgroundColor)
			.cornerRadius(style.cornerRadius)
	}
}

extension StyleType {
	
	var boderColor: Color {
		switch self {
			case .rectangle:
				return .adaptiveGray
			case .rounded:
				return .clear
		}
	}
	
	var padding: CGFloat {
		switch self {
			case .rectangle:
				return 0
			case .rounded:
				return 4
		}
	}
	
	var backgroundColor: Color {
		switch self {
			case .rectangle:
				return .clear
			case .rounded:
				return .adaptiveBackground
		}
	}
	
	var cornerRadius: CGFloat {
		switch self {
			case .rectangle:
				return 0
			case .rounded:
				return 16
		}
	}
}
