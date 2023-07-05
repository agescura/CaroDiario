import ComposableArchitecture
import SwiftUI

extension NavigationLinkStore {
	public init(
	  _ store: Store<PresentationState<State>, PresentationAction<Action>>,
	  @ViewBuilder destination: @escaping (Store<State, Action>) -> Destination,
	  @ViewBuilder label: () -> Label
	) where State == DestinationState, Action == DestinationAction {
	  self.init(
		 store,
		 state: { $0 },
		 action: { $0 },
		 onTap: {},
		 destination: destination,
		 label: label
	  )
	}
}

extension NavigationLinkStore {
	public init(
	  _ store: Store<PresentationState<State>, PresentationAction<Action>>,
	  state toDestinationState: @escaping (State) -> DestinationState?,
	  action fromDestinationAction: @escaping (DestinationAction) -> Action,
	  @ViewBuilder destination: @escaping (Store<DestinationState, DestinationAction>) -> Destination,
	  @ViewBuilder label: () -> Label
	) {
		self.init(
			store,
			state: toDestinationState,
			action: fromDestinationAction,
			onTap: {},
			destination: destination,
			label: label
		)
	}
}
