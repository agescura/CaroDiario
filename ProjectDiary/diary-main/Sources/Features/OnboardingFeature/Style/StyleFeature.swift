import Foundation
import ComposableArchitecture
import UserDefaultsClient
import FeedbackGeneratorClient
import EntriesFeature
import Models

public struct StyleFeature: Reducer {
  public init() {}
  
  public struct State: Equatable {
		@PresentationState public var alert: AlertState<Action.Alert>?
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		public var isAppClip = false
		public var navigateLayout: Bool = false
		public var layout: LayoutFeature.State? = nil
		public var layoutType: LayoutType
		public var styleType: StyleType
  }

  public enum Action: Equatable {
		case alert(PresentationAction<Alert>)
		case entries(id: UUID, action: DayEntriesRow.Action)
		case delegate(Delegate)
		case navigationLayout(Bool)
		case layout(LayoutFeature.Action)
		case skipAlertButtonTapped
    case styleChanged(StyleType)
		
		public enum Alert: Equatable {
			case skip
		}
		public enum Delegate: Equatable {
			case goToHome
		}
  }
  
	@Dependency(\.feedbackGeneratorClient) var feedbackGeneratorClient
	@Dependency(\.userDefaultsClient) var userDefaultsClient
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .alert(.presented(.skip)):
					return .run { send in
						await self.userDefaultsClient.setHasShownFirstLaunchOnboarding(true)
						await send(.delegate(.goToHome))
					}
				case .alert:
					return .none
					
				case .delegate:
					return .none
					
				case .entries:
					return .none
					
				case let .navigationLayout(value):
					state.navigateLayout = value
						state.layout = value ? LayoutFeature.State(
						entries: fakeEntries(
							with: state.styleType,
							layout: state.layoutType),
						isAppClip: state.isAppClip,
						layoutType: state.layoutType,
						styleType: state.styleType) : nil
					return .none
					
				case .layout:
					return .none

				case .skipAlertButtonTapped:
					state.alert = AlertState {
						TextState("OnBoarding.Skip.Title".localized)
					} actions: {
						ButtonState(role: .cancel, label: { TextState("Cancel".localized) })
						ButtonState(role: .destructive, action: .skip, label: { TextState("OnBoarding.Skip".localized) })
					} message: {
						TextState("OnBoarding.Skip.Alert".localized)
					}
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
		.ifLet(\.layout, action: /Action.layout) {
			LayoutFeature()
		}
		.ifLet(\.$alert, action: /Action.alert)
	}
}
