import Dependencies
import Foundation
import Models

extension DependencyValues {
	public var userDefaultsClient: UserDefaultsClient {
		get { self[UserDefaultsClient.self] }
		set { self[UserDefaultsClient.self] = newValue }
	}
}

public struct UserDefaultsClient {
	public var userSettings: () -> UserSettings
	public var setUserSettings: (UserSettings) -> Void
	
	public var boolForKey: (String) -> Bool
	public var setBool: (Bool, String) -> Void
	
	public var stringForKey: (String) -> String?
	public var setString: (String, String) -> Void
	
	public var intForKey: (String) -> Int?
	public var setInt: (Int, String) -> Void
	
	public var dateForKey: (String) -> Date?
	public var setDate: (Date, String) -> Void
	public var remove: (String) -> Void
	
	public init(
		userSettings: @escaping () -> UserSettings,
		setUserSettings: @escaping (UserSettings) -> Void,
		
		boolForKey: @escaping (String) -> Bool,
		setBool: @escaping (Bool, String) -> Void,
		stringForKey: @escaping (String) -> String?,
		setString: @escaping (String, String) -> Void,
		intForKey: @escaping (String) -> Int?,
		setInt: @escaping (Int, String) -> Void,
		dateForKey: @escaping (String) -> Date?,
		setDate: @escaping (Date, String) -> Void,
		remove: @escaping (String) -> Void
	) {
		self.userSettings = userSettings
		self.setUserSettings = setUserSettings
		
		self.boolForKey = boolForKey
		self.setBool = setBool
		self.stringForKey = stringForKey
		self.setString = setString
		self.intForKey = intForKey
		self.setInt = setInt
		self.dateForKey = dateForKey
		self.setDate = setDate
		self.remove = remove
	}
	
	public var hasShownFirstLaunchOnboarding: Bool {
		boolForKey(hasShownOnboardingKey)
	}
	
	public func setHasShownFirstLaunchOnboarding(_ bool: Bool) -> Void {
		setBool(bool, hasShownOnboardingKey)
	}
	
	public var hideSplashScreen: Bool {
		boolForKey(hideSplashScreenKey)
	}
	
	public func setHideSplashScreen(_ bool: Bool) -> Void {
		setBool(bool, hideSplashScreenKey)
	}
	
	public var styleType: StyleType {
		guard let value = stringForKey(stringForStylingKey) else { return .rectangle }
		return StyleType(rawValue: value) ?? .rectangle
	}
	
	public func set(styleType: StyleType) -> Void {
		setString(styleType.rawValue, stringForStylingKey)
	}
	
	public var layoutType: LayoutType {
		guard let value = stringForKey(stringForLayoutKey) else { return .horizontal }
		return LayoutType(rawValue: value) ?? .horizontal
	}
	
	public func set(layoutType: LayoutType) -> Void {
		setString(layoutType.rawValue, stringForLayoutKey)
	}
	
	public var themeType: ThemeType {
		guard let value = stringForKey(stringForThemeKey) else { return .system }
		return ThemeType(rawValue: value) ?? .system
	}
	
	public func set(themeType: ThemeType) -> Void {
		setString(themeType.rawValue, stringForThemeKey)
	}
	
	public var passcodeCode: String? {
		stringForKey(passcodeKey)
	}
	
	public func setPasscode(_ string: String) -> Void {
		setString(string, passcodeKey)
	}
	
	public func removePasscode() -> Void {
		remove(passcodeKey)
	}
	
	public var isFaceIDActivate: Bool {
		boolForKey(faceIDActivateKey)
	}
	
	public func setFaceIDActivate(_ bool: Bool) -> Void {
		setBool(bool, faceIDActivateKey)
	}
	
	public var timeForAskPasscode: Date? {
		dateForKey(timeForAskPasscodeKey)
	}
	
	public func setTimeForAskPasscode(_ value: Date) -> Void {
		setDate(value, timeForAskPasscodeKey)
	}
	
	public func removeTimeForAskPasscode() -> Void {
		remove(timeForAskPasscodeKey)
	}
	
	public var optionTimeForAskPasscode: Int {
		intForKey(optionTimeForAskPasscodeKey) ?? 0
	}
	
	public func setOptionTimeForAskPasscode(_ value: Int) -> Void {
		setInt(value, optionTimeForAskPasscodeKey)
	}
	
	public func removeOptionTimeForAskPasscode() -> Void {
		remove(optionTimeForAskPasscodeKey)
	}
	
	public var language: String {
		stringForKey(languageCodeKey) ?? "en"
	}
	
	public func setLanguage(_ value: String) -> Void {
		setString(value, languageCodeKey)
	}
	
	let hasShownOnboardingKey = "hasShownOnboardingKey"
	let hideSplashScreenKey = "hideSplashScreenKey"
	let stringForStylingKey = "stringForStylingKey"
	let stringForLayoutKey = "stringForLayoutKey"
	let stringForThemeKey = "stringForThemeKey"
	let passcodeKey = "passcodeKey"
	let faceIDActivateKey = "isFaceIDActivateKey"
	let timeForAskPasscodeKey = "timeForAskPasscode"
	let optionTimeForAskPasscodeKey = "optionTimeForAskPasscode"
	let languageCodeKey = "LanguageCodeKey"
}
