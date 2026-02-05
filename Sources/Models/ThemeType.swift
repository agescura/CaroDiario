import UIKit

public enum ThemeType: String, CaseIterable, Codable, Sendable {
	case system = "Style.System"
	case light = "Style.Light"
	case dark = "Style.Dark"
	
	public var userInterfaceStyle: UIUserInterfaceStyle {
		switch self {
			case .dark:
				.dark
			case .light:
				.light
			case .system:
				.unspecified
		}
	}
	
	public var icon: String {
		switch self {
			case .system:
				"star.circle.fill"
			case .light:
				"star.fill"
			case .dark:
				"star"
		}
	}
}
