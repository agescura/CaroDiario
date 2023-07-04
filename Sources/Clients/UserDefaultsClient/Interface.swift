import Foundation
import Combine
import Models
import Dependencies

extension DependencyValues {
	public var userDefaultsClient: UserDefaultsClient {
		get { self[UserDefaultsClient.self] }
		set { self[UserDefaultsClient.self] = newValue }
	}
}

public struct UserDefaultsClient {
	public var setObject: @Sendable (Any, String) async -> Void
	public var objectForKey: @Sendable (String) -> Any?
	
	public init(
		setObject: @escaping @Sendable (Any, String) async -> Void,
		objectForKey: @escaping @Sendable (String) -> Any?
	) {
		self.setObject = setObject
		self.objectForKey = objectForKey
	}
	
	private let userSettingsKey = "UserSettingsKey"
	
	public func set(_ value: UserSettings) async -> Void {
		let encoder = JSONEncoder()
		if let encoded = try? encoder.encode(value) {
			await setObject(encoded, self.userSettingsKey)
		}
	}
	
	public var userSettings: UserSettings {
		if let object = objectForKey(self.userSettingsKey) as? Data {
			 let decoder = JSONDecoder()
			 if let userSettings = try? decoder.decode(UserSettings.self, from: object) {
				 return userSettings
			 }
		}
		return .defaultValue
	}
}
