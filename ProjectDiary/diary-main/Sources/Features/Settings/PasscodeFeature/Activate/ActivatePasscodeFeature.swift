import Foundation
import ComposableArchitecture

public struct ActivatePasscodeFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		@PresentationState public var insert: InsertPasscodeFeature.State?
		
		public var faceIdEnabled: Bool
		public var hasPasscode: Bool
		
		public init(
			faceIdEnabled: Bool,
			hasPasscode: Bool
		) {
			self.faceIdEnabled = faceIdEnabled
			self.hasPasscode = hasPasscode
		}
	}
	
	public enum Action: Equatable {
		case insert(PresentationAction<InsertPasscodeFeature.Action>)
		case insertButtonTapped
	}
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case .insert(.dismiss):
					guard let insert = state.insert else { return .none }
					state.faceIdEnabled = insert.faceIdEnabled
					state.hasPasscode = insert.hasPasscode
					return .none
				case .insert:
					return .none
					
				case .insertButtonTapped:
					state.insert = InsertPasscodeFeature.State(faceIdEnabled: state.faceIdEnabled)
					return .none
			}
		}
		.ifLet(\.$insert, action: /Action.insert) {
			InsertPasscodeFeature()
		}
	}
}
