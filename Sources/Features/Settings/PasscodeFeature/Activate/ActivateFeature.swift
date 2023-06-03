import Foundation
import ComposableArchitecture

public struct ActivateFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable, Identifiable {
		@PresentationState public var insert: InsertFeature.State?
		public var faceIdEnabled: Bool
		public var hasPasscode: Bool
		
		public var id: Int { 1 }
		
		public init(
			faceIdEnabled: Bool,
			hasPasscode: Bool
		) {
			self.faceIdEnabled = faceIdEnabled
			self.hasPasscode = hasPasscode
		}
	}
	
	public enum Action: Equatable {
		case insert(PresentationAction<InsertFeature.Action>)
		case navigateToInsert
	}
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case .insert:
					return .none
					
				case .navigateToInsert:
					state.insert = .init(faceIdEnabled: state.faceIdEnabled)
					return .none
			}
		}
			.ifLet(\.$insert, action: /Action.insert) {
				InsertFeature()
			}
	}
}
