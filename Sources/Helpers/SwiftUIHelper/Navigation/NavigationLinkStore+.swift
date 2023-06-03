import ComposableArchitecture
import CasePaths
import Foundation
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

extension NavigationLink {
  public init<Enum, Case, WrappedDestination>(
    route optionalValue: Enum?,
    case casePath: CasePath<Enum, Case>,
    onNavigate: @escaping (Bool) -> Void,
    @ViewBuilder destination: @escaping (Case) -> WrappedDestination,
    @ViewBuilder label: @escaping () -> Label
  ) where Destination == WrappedDestination? {
    let pattern = Binding.constant(optionalValue).case(casePath)
    
    self.init(
      isActive: Binding(
        get: { pattern.wrappedValue != nil },
        set: { isPresented in
          onNavigate(isPresented)
        }
      ),
      destination: {
        if let value = pattern.wrappedValue {
          destination(value)
        }
      },
      label: label
    )
  }
}

extension Binding {
  func `case`<Enum, Case>(
    _ casePath: CasePath<Enum, Case>
  ) -> Binding<Case?> where Value == Enum? {
    Binding<Case?>(
      get: {
        guard
          let wrappedValue = self.wrappedValue,
          let `case` = casePath.extract(from: wrappedValue)
        else { return nil }
        return `case`
      },
      set: { `case` in
        if let `case` = `case` {
          self.wrappedValue = casePath.embed(`case`)
        } else {
          self.wrappedValue = nil
        }
      }
    )
  }
}
