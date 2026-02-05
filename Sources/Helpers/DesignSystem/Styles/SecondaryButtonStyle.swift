import SwiftUI

public struct SecondaryButtonStyle: ButtonStyle {
	@Environment(\.isEnabled) var isEnabled
	
	public func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.frame(maxWidth: .infinity)
			.foregroundColor(.chambray)
			.adaptiveFont(.latoRegular, size: 16)
			.opacity(isEnabled ? 1.0 : 0.5)
	}
}

extension ButtonStyle where Self == SecondaryButtonStyle {
	static public var secondary: Self {
		SecondaryButtonStyle()
	}
}
