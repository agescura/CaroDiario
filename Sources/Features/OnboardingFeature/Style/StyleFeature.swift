import Foundation
import ComposableArchitecture
import UserDefaultsClient
import FeedbackGeneratorClient
import EntriesFeature
import Models

public struct StyleFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		@PresentationState public var alert: AlertState<Action.Alert>?
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		public var isAppClip = false
		@PresentationState public var layout: LayoutFeature.State?
		public var layoutType: LayoutType
		public var styleType: StyleType
	}
	
	public enum Action: Equatable {
		case alert(PresentationAction<Alert>)
		case alertButtonTapped
		case delegate(Delegate)
		case entries(id: UUID, action: DayEntriesRow.Action)
		case layout(PresentationAction<LayoutFeature.Action>)
		case layoutButtonTapped
		case styleChanged(StyleType)
		
		public enum Alert: Equatable {
			case skipButtonTapped
		}
		
		public enum Delegate: Equatable {
			case skip
		}
	}
	
	@Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case .alertButtonTapped:
					state.alert = .alert
					return .none

				case .alert(.presented(.skipButtonTapped)):
					return .run { send in
						await send(.delegate(.skip))
					}
					
				case .alert:
					return .none
					
				case .delegate:
					return .none
					
				case .layout:
					return .none
					
				case .layoutButtonTapped:
					state.layout = LayoutFeature.State(
						entries: fakeEntries(
							with: state.styleType,
							layout: state.layoutType
						),
						isAppClip: state.isAppClip,
						layoutType: state.layoutType,
						styleType: state.styleType
					)
					return .none
					
				case .entries:
					return .none
					
					
				case let .styleChanged(styleChanged):
					state.styleType = styleChanged
					state.entries = fakeEntries(with: state.styleType, layout: state.layoutType)
					return .fireAndForget {
						await self.feedbackGeneratorClient.selectionChanged()
					}
			}
		}
		.forEach(\.entries, action: /Action.entries) {
			DayEntriesRow()
		}
		.ifLet(\.$alert, action: /Action.alert)
		.ifLet(\.$layout, action: /Action.layout) {
			LayoutFeature()
		}
	}
}

extension AlertState where Action == StyleFeature.Action.Alert {
	static var alert: Self {
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
