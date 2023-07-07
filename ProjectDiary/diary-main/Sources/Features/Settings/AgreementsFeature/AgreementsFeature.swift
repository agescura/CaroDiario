import Foundation
import ComposableArchitecture
import UIApplicationClient

public enum AgreementType {
	case composableArchitecture
	case pointfree
	case raywenderlich
	
	public var urlString: String {
		switch self {
			case .composableArchitecture:
				return "https://github.com/pointfreeco/swift-composable-architecture"
			case .pointfree:
				return "https://www.pointfree.co/"
			case .raywenderlich:
				return "https://www.kodeco.com/"
		}
	}
	
	public var title: String {
		switch self {
			case .composableArchitecture:
				return "The Composable Architecture"
			case .pointfree:
				return "pointfree.co"
			case .raywenderlich:
				return "kodeco.com"
		}
	}
}

public struct AgreementsFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		public init() {}
		
		public var id: Int { 1 }
	}
	
	public enum Action: Equatable {
		case open(AgreementType)
	}
	
	@Dependency(\.applicationClient.open) private var open
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case let .open(type):
					guard let url = URL(string: type.urlString) else { return .none }
					return .fireAndForget { await self.open(url, [:]) }
			}
		}
	}
}
