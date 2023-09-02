import ComposableArchitecture
import EntriesFeature
import FeedbackGeneratorClient
import Models
import Foundation
import UserDefaultsClient

public struct StyleFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		@PresentationState public var destination: Destination.State?
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		public var isAppClip = false
		public var layoutType: LayoutType
		public var styleType: StyleType
	}
	
	public enum Action: Equatable {
		case alertButtonTapped
		case delegate(Delegate)
		case destination(PresentationAction<Destination.Action>)
		case entries(id: UUID, action: DayEntriesRow.Action)
		case layoutButtonTapped
		case styleChanged(StyleType)
		
		public enum Delegate: Equatable {
			case skip
		}
	}
	
	@Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	
	public struct Destination: ReducerProtocol {
		public enum State: Equatable {
			case alert(AlertState<Action.Alert>)
			case layout(LayoutFeature.State)
		}
		
		public enum Action: Equatable {
			case alert(Alert)
			case layout(LayoutFeature.Action)
			
			public enum Alert: Equatable {
				case skipButtonTapped
			}
		}
		
		public var body: some ReducerProtocolOf<Self> {
			Scope(state: /State.alert, action: /Action.alert) {}
			Scope(state: /State.layout, action: /Action.layout) {
				LayoutFeature()
			}
		}
	}
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case .alertButtonTapped:
					state.destination = .alert(.skip)
					return .none
					
				case .delegate:
					return .none
					
				case .destination(.presented(.alert(.skipButtonTapped))):
					return .run { send in
						self.userDefaultsClient.setHasShownFirstLaunchOnboarding(true)
						await send(.delegate(.skip))
					}
					
				case .destination:
					return .none
					
				case .entries:
					return .none
					
				case .layoutButtonTapped:
					let styleType = self.userDefaultsClient.styleType
					let layoutType = self.userDefaultsClient.layoutType
					state.destination = .layout(
						LayoutFeature.State(
							entries: fakeEntries(
								with: styleType,
								layout: layoutType
							),
							layoutType: layoutType,
							styleType: styleType
						)
					)
					return .none

				case let .styleChanged(styleChanged):
					state.styleType = styleChanged
					state.entries = fakeEntries(with: state.styleType, layout: state.layoutType)
					return .run { _ in
						await self.feedbackGeneratorClient.selectionChanged()
					}
					
			}
		}
		.forEach(\.entries, action: /Action.entries) {
			DayEntriesRow()
		}
		.ifLet(\.$destination, action: /Action.destination) {
			Destination()
		}
	}
}

extension AlertState where Action == StyleFeature.Destination.Action.Alert {
	static var skip: Self {
		AlertState {
			TextState("OnBoarding.Skip.Title".localized)
		} actions: {
			ButtonState.cancel(TextState("Cancel".localized))
			ButtonState.destructive(TextState("OnBoarding.Skip".localized), action: .send(.skipButtonTapped))
		} message: {
			TextState("OnBoarding.Skip.Alert".localized)
		}
	}
}
