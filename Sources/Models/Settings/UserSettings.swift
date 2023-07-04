import Foundation

public struct UserSettings: Equatable, Codable {
	public var showSplash: Bool
	public var hasShownOnboarding: Bool
	public var appearance: AppearanceSettings
	public var language: Localizable
	public var passcode: String
	public var optionTimeForAskPasscode: Int
	public var faceIdEnabled: Bool
	
	public init(
		showSplash: Bool,
		hasShownOnboarding: Bool,
		appearance: AppearanceSettings,
		language: Localizable,
		passcode: String,
		optionTimeForAskPasscode: Int,
		faceIdEnabled: Bool
	) {
		self.showSplash = showSplash
		self.hasShownOnboarding = hasShownOnboarding
		self.appearance = appearance
		self.language = language
		self.passcode = passcode
		self.optionTimeForAskPasscode = optionTimeForAskPasscode
		self.faceIdEnabled = faceIdEnabled
	}
}

extension UserSettings {
	public static var defaultValue: Self {
		UserSettings(
			showSplash: true,
			hasShownOnboarding: false,
			appearance: AppearanceSettings(
				styleType: .rectangle,
				layoutType: .horizontal,
				themeType: .system,
				iconAppType: .light
			),
			language: .english,
			passcode: "",
			optionTimeForAskPasscode: 0,
			faceIdEnabled: false
		)
	}
}
