import Foundation

public struct AppearanceSettings: Equatable, Codable {
	public var styleType: StyleType
	public var layoutType: LayoutType
	public var themeType: ThemeType
	public var iconAppType: IconAppType
	
	public init(
		styleType: StyleType,
		layoutType: LayoutType,
		themeType: ThemeType,
		iconAppType: IconAppType
	) {
		self.styleType = styleType
		self.layoutType = layoutType
		self.themeType = themeType
		self.iconAppType = iconAppType
	}
}

extension AppearanceSettings {
	public static var defaultValue: Self {
		AppearanceSettings(
			styleType: .rectangle,
			layoutType: .horizontal,
			themeType: .system,
			iconAppType: .light
		)
	}
}
