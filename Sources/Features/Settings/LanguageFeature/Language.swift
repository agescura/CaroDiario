import ComposableArchitecture
import Foundation
import Models

public struct LanguageFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable, Identifiable {
		public var language: Localizable
		
		public var id: Localizable { self.language }
		
		public init(
			language: Localizable
		) {
			self.language = language
		}
	}
	
	public enum Action: Equatable {
		case updateLanguageTapped(Localizable)
	}
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case let .updateLanguageTapped(language):
					state.language = language
					return .none
			}
		}
	}
}
