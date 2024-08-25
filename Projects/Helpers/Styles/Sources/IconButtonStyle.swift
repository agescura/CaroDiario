import SwiftUI
import SwiftUIHelper

extension Button where Label == Image {
	public init(
		systemName: String,
		action: @escaping () -> Void
	) {
		self.init(
			action: action,
			label: {
				Image(systemName: systemName)
					.resizable()
			}
		)
	}
	
	public init(
		systemName: SystemImage,
		action: @escaping () -> Void
	) {
		self.init(
			action: action,
			label: {
				Image(systemName: systemName.rawValue)
					.resizable()
			}
		)
	}
}

public struct IconButtonStyle: ButtonStyle {
	public func makeBody(configuration: Configuration) -> some View {
		configuration
			.label
			.aspectRatio(contentMode: .fit)
			.foregroundColor(.chambray)
	}
}

extension ButtonStyle where Self == IconButtonStyle {
	static public var icon: IconButtonStyle { return Self() }
}
