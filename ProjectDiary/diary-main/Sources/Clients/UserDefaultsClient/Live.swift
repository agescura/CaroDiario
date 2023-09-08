import Foundation
import Dependencies
import Models

extension UserDefaultsClient: DependencyKey {
	public static var liveValue: UserDefaultsClient { .live() }
}

extension UserDefaultsClient {
	public static func live(userDefaults: UserDefaults = UserDefaults(suiteName: "group.albertgil.carodiario")!) -> Self {
		Self(
			userSettings: {
				guard
					let data = userDefaults.data(forKey: "userSettingsKey"),
					let userSettings = try? JSONDecoder().decode(UserSettings.self, from: data)
				else {
					if userDefaults.migrationNeeded {
						let userSettings = UserSettings(
							showSplash: userDefaults.bool(forKey: "hideSplashScreenKey"),
							hasShownOnboarding: userDefaults.bool(forKey: "hasShownOnboardingKey"),
							appearance: AppearanceSettings(
								styleType: StyleType(rawValue: userDefaults.string(forKey: "stringForStylingKey") ?? "") ?? .rectangle,
								layoutType: LayoutType(rawValue: userDefaults.string(forKey: "stringForLayoutKey") ?? "") ?? .horizontal,
								themeType: ThemeType(rawValue: userDefaults.string(forKey: "stringForThemeKey") ?? "") ?? .system,
								iconAppType: IconAppType(rawValue: userDefaults.string(forKey: "stringForIconAppKey") ?? "") ?? .light
							),
							language: Localizable(rawValue: userDefaults.string(forKey: "LanguageCodeKey") ?? "") ?? .english,
							passcode: userDefaults.string(forKey: "passcodeKey") ?? "",
							optionTimeForAskPasscode: userDefaults.integer(forKey: "optionTimeForAskPasscode"),
							faceIdEnabled: userDefaults.bool(forKey: "isFaceIDActivateKey")
						)
						if let encoded = try? JSONEncoder().encode(userSettings) {
							userDefaults.set(encoded, forKey: "userSettingsKey")
							
							userDefaults.removeObject(forKey: "hideSplashScreenKey")
							userDefaults.removeObject(forKey: "hasShownOnboardingKey")
							userDefaults.removeObject(forKey: "stringForStylingKey")
							userDefaults.removeObject(forKey: "stringForLayoutKey")
							userDefaults.removeObject(forKey: "stringForThemeKey")
							userDefaults.removeObject(forKey: "stringForIconAppKey")
							userDefaults.removeObject(forKey: "LanguageCodeKey")
							userDefaults.removeObject(forKey: "passcodeKey")
							userDefaults.removeObject(forKey: "optionTimeForAskPasscode")
							userDefaults.removeObject(forKey: "isFaceIDActivateKey")
						}
						return userSettings
					}
					return .defaultValue
				}
				return userSettings
			},
			setUserSettings: { userSettings in
				if let encoded = try? JSONEncoder().encode(userSettings) {
					userDefaults.set(encoded, forKey: "userSettingsKey")
				}
			},
			boolForKey: userDefaults.bool(forKey:),
			setBool: { value, key in
				userDefaults.set(value, forKey: key)
			},
			stringForKey: userDefaults.string(forKey:),
			setString: { value, key in
				userDefaults.set(value, forKey: key)
			},
			intForKey: userDefaults.integer(forKey:),
			setInt: { value, key in
				userDefaults.set(value, forKey: key)
			},
			dateForKey: { key in
				Date(timeIntervalSince1970: userDefaults.double(forKey: key))
			},
			setDate: { value, key in
				userDefaults.set(value.timeIntervalSince1970, forKey: key)
			},
			remove: { key in
				userDefaults.removeObject(forKey: key)
			}
		)
	}
}

extension UserDefaults {
	var migrationNeeded: Bool {
		self.bool(forKey: "hasShownOnboardingKey") == true
	}
}
