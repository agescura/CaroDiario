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
  public var setBool: @Sendable (Bool, String) async -> Void
  
  public var stringForKey: (String) -> String?
  public var setString: @Sendable (String, String) async -> Void
  
  public var intForKey: (String) -> Int?
  public var setInt: @Sendable (Int, String) async -> Void
  
  public var dateForKey: (String) -> Date?
  public var setDate: @Sendable (Date, String) async -> Void
  public var remove: @Sendable (String) async -> Void
  
  public init(
    boolForKey: @escaping (String) -> Bool,
    setBool: @escaping @Sendable (Bool, String) async -> Void,
    stringForKey: @escaping (String) -> String?,
    setString: @escaping @Sendable (String, String) async -> Void,
    intForKey: @escaping (String) -> Int?,
    setInt: @escaping @Sendable (Int, String) async -> Void,
    dateForKey: @escaping (String) -> Date?,
    setDate: @escaping @Sendable (Date, String) async -> Void,
    remove: @escaping @Sendable (String) async -> Void
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
  
  public func setHasShownFirstLaunchOnboarding(_ bool: Bool) async -> Void {
    await setBool(bool, hasShownOnboardingKey)
  }
  
  public var hideSplashScreen: Bool {
    boolForKey(hideSplashScreenKey)
  }
  
  public func setHideSplashScreen(_ bool: Bool) async -> Void {
    await setBool(bool, hideSplashScreenKey)
  }
  
  public var styleType: StyleType {
    guard let value = stringForKey(stringForStylingKey) else { return .rectangle }
    return StyleType(rawValue: value) ?? .rectangle
  }
  
  public func set(styleType: StyleType) async -> Void {
    await setString(styleType.rawValue, stringForStylingKey)
  }
  
  public var layoutType: LayoutType {
    guard let value = stringForKey(stringForLayoutKey) else { return .horizontal }
    return LayoutType(rawValue: value) ?? .horizontal
  }
  
  public func set(layoutType: LayoutType) async -> Void {
    await setString(layoutType.rawValue, stringForLayoutKey)
  }
  
  public var themeType: ThemeType {
    guard let value = stringForKey(stringForThemeKey) else { return .system }
    return ThemeType(rawValue: value) ?? .system
  }
  
  public func set(themeType: ThemeType) async -> Void {
    await setString(themeType.rawValue, stringForThemeKey)
  }
  
  public var passcodeCode: String? {
    stringForKey(passcodeKey)
  }
  
  public func setPasscode(_ string: String) async -> Void {
    await setString(string, passcodeKey)
  }
  
  public func removePasscode() async -> Void {
    await remove(passcodeKey)
  }
  
  public var isFaceIDActivate: Bool {
    boolForKey(faceIDActivateKey)
  }
  
  public func setFaceIDActivate(_ bool: Bool) async -> Void {
    await setBool(bool, faceIDActivateKey)
  }
  
  public var timeForAskPasscode: Date? {
    dateForKey(timeForAskPasscodeKey)
  }
  
  public func setTimeForAskPasscode(_ value: Date) async -> Void {
    await setDate(value, timeForAskPasscodeKey)
  }
  
  public func removeTimeForAskPasscode() async -> Void {
    await remove(timeForAskPasscodeKey)
  }
  
  public var optionTimeForAskPasscode: Int {
    intForKey(optionTimeForAskPasscodeKey) ?? 0
  }
  
  public func setOptionTimeForAskPasscode(_ value: Int) async -> Void {
    await setInt(value, optionTimeForAskPasscodeKey)
  }
  
  public func removeOptionTimeForAskPasscode() async -> Void {
    await remove(optionTimeForAskPasscodeKey)
  }
  
  public var language: String {
    stringForKey(languageCodeKey) ?? "en"
  }
  
  public func setLanguage(_ value: String) async -> Void {
    await setString(value, languageCodeKey)
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
