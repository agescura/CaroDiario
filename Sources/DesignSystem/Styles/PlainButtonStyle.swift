import SwiftUI

public struct PlainButtonStyle: ButtonStyle {
	public let foregroundColor: Color
	
	@Environment(\.isEnabled) var isEnabled
	
	public init(
		foregroundColor: Color
	) {
		self.foregroundColor = foregroundColor
	}
	
	public func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.foregroundColor(.chambray)
			.adaptiveFont(.latoRegular, size: 12)
			.opacity(isEnabled ? 1.0 : 0.5)
	}
}

extension ButtonStyle where Self == PlainButtonStyle {
	static public func plain(
		_ foregroundColor: Color = .adaptiveGray
	) -> Self {
		PlainButtonStyle(
			foregroundColor: foregroundColor
		)
	}
}
