import ComposableArchitecture
import Foundation
import Models

extension String {
	public var localized: String {
		@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
		let path = Bundle.module.path(forResource: userSettings.language.rawValue, ofType: "lproj")!
		let bundle = Bundle(path: path)!
		
		return NSLocalizedString(
			self,
			bundle: bundle,
			comment: ""
		)
	}
	
	public func localized(with arguments: [CVarArg]) -> String {
		String(
			format: localized,
			locale: nil,
			arguments: arguments
		)
	}
}
