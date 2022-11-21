import Foundation
import Combine
import ComposableArchitecture
import Models
import Dependencies

extension DependencyValues {
  public var userDefaultsClient: UserDefaultsClient {
    get { self[UserDefaultsClient.self] }
    set { self[UserDefaultsClient.self] = newValue }
  }
}

public struct UserDefaultsClient {
  public var boolForKey: (String) -> Bool
  public var setBool: (Bool, String) -> Effect<Never, Never>
  
  public var stringForKey: (String) -> String?
  public var setString: (String, String) -> Effect<Never, Never>
  
  public var intForKey: (String) -> Int?
  public var setInt: (Int, String) -> Effect<Never, Never>
  
  public var dateForKey: (String) -> Date?
  public var setDate: (Date, String) -> Effect<Never, Never>
  public var remove: (String) -> Effect<Never, Never>
  
  public init(
    boolForKey: @escaping (String) -> Bool,
    setBool: @escaping (Bool, String) -> Effect<Never, Never>,
    stringForKey: @escaping (String) -> String?,
    setString: @escaping (String, String) -> Effect<Never, Never>,
    intForKey: @escaping (String) -> Int?,
    setInt: @escaping (Int, String) -> Effect<Never, Never>,
    dateForKey: @escaping (String) -> Date?,
    setDate: @escaping (Date, String) -> Effect<Never, Never>,
    remove: @escaping (String) -> Effect<Never, Never>
  ) {
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
  
  public func setHasShownFirstLaunchOnboarding(_ bool: Bool) -> Effect<Never, Never> {
    setBool(bool, hasShownOnboardingKey)
  }
  
  public var hideSplashScreen: Bool {
    boolForKey(hideSplashScreenKey)
  }
  
  public func setHideSplashScreen(_ bool: Bool) -> Effect<Never, Never> {
    setBool(bool, hideSplashScreenKey)
  }
  
  public var styleType: StyleType {
    guard let value = stringForKey(stringForStylingKey) else { return .rectangle }
    return StyleType(rawValue: value) ?? .rectangle
  }
  
  public func set(styleType: StyleType) -> Effect<Never, Never> {
    setString(styleType.rawValue, stringForStylingKey)
  }
  
  public var layoutType: LayoutType {
    guard let value = stringForKey(stringForLayoutKey) else { return .horizontal }
    return LayoutType(rawValue: value) ?? .horizontal
  }
  
  public func set(layoutType: LayoutType) -> Effect<Never, Never> {
    setString(layoutType.rawValue, stringForLayoutKey)
  }
  
  public var themeType: ThemeType {
    guard let value = stringForKey(stringForThemeKey) else { return .system }
    return ThemeType(rawValue: value) ?? .system
  }
  
  public func set(themeType: ThemeType) -> Effect<Never, Never> {
    setString(themeType.rawValue, stringForThemeKey)
  }
  
  public var passcodeCode: String? {
    stringForKey(passcodeKey)
  }
  
  public func setPasscode(_ string: String) -> Effect<Never, Never> {
    setString(string, passcodeKey)
  }
  
  public func removePasscode() -> Effect<Never, Never> {
    remove(passcodeKey)
  }
  
  public var isFaceIDActivate: Bool {
    boolForKey(faceIDActivateKey)
  }
  
  public func setFaceIDActivate(_ bool: Bool) -> Effect<Never, Never> {
    setBool(bool, faceIDActivateKey)
  }
  
  public var timeForAskPasscode: Date? {
    dateForKey(timeForAskPasscodeKey)
  }
  
  public func setTimeForAskPasscode(_ value: Date) -> Effect<Never, Never> {
    setDate(value, timeForAskPasscodeKey)
  }
  
  public func removeTimeForAskPasscode() -> Effect<Never, Never> {
    remove(timeForAskPasscodeKey)
  }
  
  public var optionTimeForAskPasscode: Int {
    intForKey(optionTimeForAskPasscodeKey) ?? 0
  }
  
  public func setOptionTimeForAskPasscode(_ value: Int) -> Effect<Never, Never> {
    setInt(value, optionTimeForAskPasscodeKey)
  }
  
  public func removeOptionTimeForAskPasscode() -> Effect<Never, Never> {
    remove(optionTimeForAskPasscodeKey)
  }
  
  public var language: String {
    stringForKey(languageCodeKey) ?? "en"
  }
  
  public func setLanguage(_ value: String) -> Effect<Never, Never> {
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
