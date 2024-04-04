import Foundation
import ComposableArchitecture
import EntriesFeature
import Models
import FeedbackGeneratorClient
import UIApplicationClient
import UserDefaultsClient

public struct LayoutFeature: Reducer {
  public struct State: Equatable {
		@PresentationState public var alert: AlertState<Action.Alert>?
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		public var isAppClip = false
		public var layoutType: LayoutType
		public var navigateTheme: Bool = false
		 public var styleType: StyleType
    public var theme: Theme.State? = nil
  }

  public enum Action: Equatable {
		case alert(PresentationAction<Alert>)
		case delegate(Delegate)
		case entries(id: UUID, action: DayEntriesRow.Action)
    case layoutChanged(LayoutType)
		case navigateTheme(Bool)
		case skipAlertButtonTapped
    case theme(Theme.Action)
		
		public enum Alert: Equatable {
			case skip
		}
		public enum Delegate: Equatable {
			case goToHome
		}
  }
  
	@Dependency(\.feedbackGeneratorClient) var feedbackGeneratorClient
	@Dependency(\.applicationClient.setUserInterfaceStyle) var setUserInterfaceStyle
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
					
				case let .layoutChanged(layoutChanged):
					state.layoutType = layoutChanged
					state.entries = fakeEntries(with: state.styleType, layout: state.layoutType)
					return .run { _ in
						await self.feedbackGeneratorClient.selectionChanged()
					}
					
				case let .navigateTheme(value):
					state.navigateTheme = value
					let themeType = self.userDefaultsClient.themeType
					state.theme = value ? .init(
						themeType: themeType,
						entries: fakeEntries(with: self.userDefaultsClient.styleType,
																 layout: self.userDefaultsClient.layoutType),
						isAppClip: state.isAppClip) : nil
					return .run { _ in
						await self.setUserInterfaceStyle(themeType.userInterfaceStyle)
					}
					
				case .skipAlertButtonTapped:
					state.alert = AlertState {
						TextState("OnBoarding.Skip.Title".localized)
					} actions: {
						ButtonState(role: .cancel, label: { TextState("Cancel".localized) })
						ButtonState(role: .destructive, action: .skip, label: { TextState("OnBoarding.Skip".localized) })
					}
					return .none
					
				case .theme:
					return .none
			}
		}
		.forEach(\.entries, action: /Action.entries) {
			DayEntriesRow()
		}
		.ifLet(\.$alert, action: /Action.alert)
		.ifLet(\.theme, action: /Action.theme) {
			Theme()
		}
	}
}

