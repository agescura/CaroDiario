import ComposableArchitecture
import Foundation
import Models

public struct LanguageFeature: Reducer {
	public init() {}
	
	public struct State: Equatable {
		public var language: Localizable
		
		public init(
			language: Localizable
		) {
			self.language = language
		}
	}
	
	public enum Action: Equatable {
		case updateLanguageTapped(Localizable)
	}
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case let .updateLanguageTapped(language):
					state.language = language
					return .none
			}
		}
	}
}
