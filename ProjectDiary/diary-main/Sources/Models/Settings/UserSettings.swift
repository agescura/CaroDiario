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
	public var appearance: AppearanceSettings
	public var audioRecordPermission: AudioRecordPermission
	public var authorizedVideoStatus: AuthorizedVideoStatus
	public var faceIdEnabled: Bool
	public var hasShownOnboarding: Bool
	public var language: Localizable
	public var localAuthenticationType: LocalAuthenticationType
	public var optionTimeForAskPasscode: Int
	public var passcode: String?
	public var showSplash: Bool
	
	public init(
		appearance: AppearanceSettings,
		audioRecordPermission: AudioRecordPermission,
		authorizedVideoStatus: AuthorizedVideoStatus,
		faceIdEnabled: Bool,
		hasShownOnboarding: Bool,
		language: Localizable,
		localAuthenticationType: LocalAuthenticationType,
		optionTimeForAskPasscode: Int,
		passcode: String?,
		showSplash: Bool
	) {
		self.appearance = appearance
		self.audioRecordPermission = audioRecordPermission
		self.authorizedVideoStatus = authorizedVideoStatus
		self.faceIdEnabled = faceIdEnabled
		self.hasShownOnboarding = hasShownOnboarding
		self.language = language
		self.localAuthenticationType = localAuthenticationType
		self.optionTimeForAskPasscode = optionTimeForAskPasscode
		self.passcode = passcode
		self.showSplash = showSplash
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
	public var listTimesForAskPasscode: [TimeForAskPasscode] {
		[
			.never,
			.always,
			.after(minutes: 1),
			.after(minutes: 5),
			.after(minutes: 30),
			.after(minutes: 60)
		]
	}
}

extension UserSettings {
	public static var defaultValue: Self {
		UserSettings(
			appearance: AppearanceSettings(
				styleType: .rectangle,
				layoutType: .horizontal,
				themeType: .system,
				iconAppType: .light
			),
			audioRecordPermission: .notDetermined,
			authorizedVideoStatus: .notDetermined,
			faceIdEnabled: false,
			hasShownOnboarding: false,
			language: .english,
			localAuthenticationType: .none,
			optionTimeForAskPasscode: 0,
			passcode: nil,
			showSplash: true
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

