import Foundation
import ComposableArchitecture
import LocalAuthenticationClient
import Models
import UserDefaultsClient

@Reducer
public struct LockScreenFeature {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		public var authenticationType: LocalAuthenticationType = .none
		public var buttons: [LockScreenNumber] = []
		public var codeToMatch: String = ""
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
		public var wrongAttempts: Int = 0
		
		public init() {}
	}
	
	public enum Action: Equatable {
		case checkFaceId
		case delegate(Delegate)
		case determine(LocalAuthenticationType)
		case faceIdResponse(Bool)
		case failedCode
		case numberButtonTapped(LockScreenNumber)
		case onAppear
		case reset
		
		@CasePathable
		public enum Delegate: Equatable {
			case matchedCode
		}
	}
	
	@Dependency(\.continuousClock) var clock
	@Dependency(\.localAuthenticationClient) var localAuthenticationClient
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .checkFaceId:
					if state.userSettings.faceIdEnabled {
						return .run { send in
							await send(.faceIdResponse(self.localAuthenticationClient.evaluate("JIJIJAJAJ")))
						}
					} else {
						return .none
					}
				case .delegate:
					return .none
				case let .determine(type):
					state.authenticationType = type
					let leftButton: LockScreenNumber = type == .none || !state.userSettings.faceIdEnabled ? .emptyLeft : .biometric(type)
					state.buttons = [
						.number(1),
						.number(2),
						.number(3),
						.number(4),
						.number(5),
						.number(6),
						.number(7),
						.number(8),
						.number(9),
						leftButton,
						.number(0),
						.emptyRight
					]
					return .none
				case let .faceIdResponse(value):
					if value {
						return .run { send in
							try await self.clock.sleep(for: .seconds(0.3))
							await send(.delegate(.matchedCode))
						}
					}
					return .none
				case .failedCode:
					state.wrongAttempts = 4
					state.codeToMatch = ""
					return .run { send in
						try await self.clock.sleep(for: .seconds(0.5))
						await send(.reset)
					}
				case let .numberButtonTapped(item):
					if item == .biometric(.touchId) || item == .biometric(.faceId) {
						return .send(.checkFaceId)
					}
					if let value = item.value {
						state.codeToMatch.append("\(value)")
					}
					if state.userSettings.passcode == state.codeToMatch {
						return .send(.delegate(.matchedCode))
					} else if state.userSettings.passcode?.count == state.codeToMatch.count {
						return .send(.failedCode)
					}
					return .none
					
				case .onAppear:
					return .merge(
						.send(.checkFaceId),
						.run { send in
							await send(.determine(self.localAuthenticationClient.determineType()))
						}
					)
				case .reset:
					state.wrongAttempts = 0
					return .none
			}
		}
	}
}
