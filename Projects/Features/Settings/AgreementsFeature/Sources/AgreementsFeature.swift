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
            return "https://www.raywenderlich.com/"
        }
    }
    
    public var title: String {
        switch self {
        case .composableArchitecture:
            return "The Composable Architecture"
        case .pointfree:
            return "pointfree.co"
        case .raywenderlich:
            return "raywenderlich.com"
        }
    }
}

@Reducer
public struct AgreementsFeature {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		public init() {}
	}
	
	public enum Action: Equatable {
		case open(AgreementType)
	}
	
	@Dependency(\.applicationClient.open) private var open
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case let .open(type):
					guard let url = URL(string: type.urlString) else { return .none }
					return .run { _ in await self.open(url, [:]) }
			}
		}
	}
}
