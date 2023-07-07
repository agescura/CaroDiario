import ComposableArchitecture
import Foundation

public struct InsertPasscodeFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		@PresentationState public var menu: MenuPasscodeFeature.State?
		
		public var step: Step = .firstCode
		public var code: String = ""
		public var firstCode: String = ""
		public let maxNumbersCode = 4
		public var codeActivated: Bool = false
		public var codeNotMatched: Bool = false
		
		public var faceIdEnabled: Bool
		public var hasPasscode: Bool {
			self.code == self.firstCode && self.code.count == self.maxNumbersCode
		}
		
		public init(
			faceIdEnabled: Bool
		) {
			self.faceIdEnabled = faceIdEnabled
		}
		
		public enum Step: Int {
			case firstCode
			case secondCode
			
			var title: String {
				switch self {
					case .firstCode:
						return "Passcode.Insert".localized
					case .secondCode:
						return "Passcode.Reinsert".localized
				}
			}
		}
	}
	
	public enum Action: Equatable {
		case delegate(Delegate)
		case menu(PresentationAction<MenuPasscodeFeature.Action>)
		case menuButtonTapped
		case popToRootButtonTapped
		case successButtonTapped
		case update(code: String)
		
		public enum Delegate: Equatable {
			case popToRoot
			case success
		}
	}
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case .delegate:
					return .none
					
				case .menu:
					return .none
					
				case .menuButtonTapped:
					state.menu = MenuPasscodeFeature.State(
						authenticationType: .none,
						optionTimeForAskPasscode: TimeForAskPasscode.never.value,
						faceIdEnabled: state.faceIdEnabled
					)
					return .none
					
				case .popToRootButtonTapped:
					return .send(.delegate(.popToRoot))
					
				case .successButtonTapped:
					return .send(.delegate(.success))
					
				case let .update(code: code):
					state.code = code
					if state.step == .firstCode,
						state.code.count == state.maxNumbersCode {
						state.codeNotMatched = false
						state.firstCode = state.code
						state.step = .secondCode
						state.code = ""
					}
					if state.step == .secondCode,
						state.code.count == state.maxNumbersCode {
						if state.code == state.firstCode {
							return Effect(value: .menuButtonTapped)
						} else {
							state.step = .firstCode
							state.code = ""
							state.firstCode = ""
							state.codeNotMatched = true
						}
					}
					return .none
			}
		}
		.ifLet(\.$menu, action: /Action.menu) {
			MenuPasscodeFeature()
		}
	}
}
