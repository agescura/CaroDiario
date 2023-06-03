import ComposableArchitecture
import Foundation

public struct InsertFeature: ReducerProtocol {
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
		case navigateToMenu
		case menu(PresentationAction<MenuPasscodeFeature.Action>)
		case update(code: String)
		case success
		case popToRoot
	}
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce(self.core)
			.ifLet(\.$menu, action: /Action.menu) {
				MenuPasscodeFeature()
			}
	}
	
	private func core(
		state: inout State,
		action: Action
	) -> EffectTask<Action> {
		switch action {
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
						return EffectTask(value: .navigateToMenu)
					} else {
						state.step = .firstCode
						state.code = ""
						state.firstCode = ""
						state.codeNotMatched = true
					}
				}
				return .none
				
			case .success:
				return .none
				
			case .popToRoot:
				return .none
				
			case .menu:
				return .none
				
			case .navigateToMenu:
				state.menu = MenuPasscodeFeature.State(
					authenticationType: .none,
					optionTimeForAskPasscode: TimeForAskPasscode.never.value,
					faceIdEnabled: state.faceIdEnabled
				)
				return .none
		}
	}
}
