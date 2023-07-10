import ComposableArchitecture
import EntriesFeature
import FeedbackGeneratorClient
import Foundation
import Models
import UIApplicationClient
import UserDefaultsClient

public struct LayoutFeature: ReducerProtocol {
	public struct State: Equatable {
		@PresentationState public var destination: Destination.State?
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		public var layoutType: LayoutType
		public var styleType: StyleType
		public var isAppClip = false
	}
	
	public enum Action: Equatable {
		case alertButtonTapped
		case delegate(Delegate)
		case destination(PresentationAction<Destination.Action>)
		case entries(id: UUID, action: DayEntriesRow.Action)
		case layoutChanged(LayoutType)
		case themeButtonTapped
		
		public enum Delegate: Equatable {
			case skip
		}
	}
	
	@Dependency(\.applicationClient.setUserInterfaceStyle) private var setUserInterfaceStyle
	@Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	
	public struct Destination: ReducerProtocol {
		public enum State: Equatable {
			case alert(AlertState<Action.Alert>)
			case theme(Theme.State)
		}
		
		public enum Action: Equatable {
			case alert(Alert)
			case theme(Theme.Action)
			
			public enum Alert: Equatable {
				case skipButtonTapped
			}
		}
		
		public var body: some ReducerProtocolOf<Self> {
			Scope(state: /State.alert, action: /Action.alert) {}
			Scope(state: /State.theme, action: /Action.theme) {
				Theme()
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
					
				case .destination:
					return .none
					
				case .entries:
					return .none
					
				case let .layoutChanged(layoutChanged):
					state.layoutType = layoutChanged
					state.entries = fakeEntries(with: state.styleType, layout: state.layoutType)
					return .fireAndForget {
						await self.feedbackGeneratorClient.selectionChanged()
					}
					
				case .themeButtonTapped:
					let type = self.userDefaultsClient.themeType
					state.destination = .theme(
						Theme.State(
							themeType: type,
							entries: fakeEntries(
								with: self.userDefaultsClient.styleType,
								layout: self.userDefaultsClient.layoutType
							)
						)
					)
					return .fireAndForget {
						await self.setUserInterfaceStyle(type.userInterfaceStyle)
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

extension AlertState where Action == LayoutFeature.Destination.Action.Alert {
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
