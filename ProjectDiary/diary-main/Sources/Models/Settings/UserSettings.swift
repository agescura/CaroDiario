import ComposableArchitecture
import Foundation

public enum TimeForAskPasscode: Equatable, Hashable {
	case always
	case never
	case after(minutes: Int)
}

extension TimeForAskPasscode {
	public init(_ value: Int) {
		if value == -1 {
			self = .always
		} else if value > 0 {
			self = .after(minutes: value)
		} else {
			self = .never
		}
	}
	
	public var value: Int {
		switch self {
		case .always:
			return -1
		case .never:
			return -2
		case let .after(minutes: minutes):
			return minutes
		}
	}
}

public struct UserSettings: Equatable, Codable {
	public var showSplash: Bool
	public var hasShownOnboarding: Bool
	public var appearance: AppearanceSettings
	public var language: Localizable
	public var passcode: String?
	public var optionTimeForAskPasscode: Int
	public var faceIdEnabled: Bool
	
	public init(
		showSplash: Bool,
		hasShownOnboarding: Bool,
		appearance: AppearanceSettings,
		language: Localizable,
		passcode: String?,
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
	public var hasPasscode: Bool {
		self.passcode != nil
	}
	
	public var timeForAskPasscode: TimeForAskPasscode {
		get {
			TimeForAskPasscode(self.optionTimeForAskPasscode)
		} set {
			self.optionTimeForAskPasscode = newValue.value
		}
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
			passcode: nil,
			optionTimeForAskPasscode: 0,
			faceIdEnabled: false
		)
	}
}

extension PersistenceKey where Self == FileStorageKey<UserSettings> {
	public static var userSettings: Self {
		fileStorage(
			FileManager.default
				.urls(for: .documentDirectory, in: .userDomainMask)
				.first!
				.appendingPathComponent("user-settings")
				.appendingPathExtension("json")
		)
	}
}

