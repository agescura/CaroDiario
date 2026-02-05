import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {
	@Environment(\.isEnabled) var isEnabled
	
	public func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding()
			.frame(maxWidth: .infinity)
			.background(Color.chambray)
			.foregroundColor(.adaptiveWhite)
			.cornerRadius(16)
			.opacity(isEnabled ? 1.0 : 0.5)
	}
}

extension ButtonStyle where Self == PrimaryButtonStyle {
	static public var primary: Self {
		PrimaryButtonStyle()
	}
}
