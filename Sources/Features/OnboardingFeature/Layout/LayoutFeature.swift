import Foundation
import ComposableArchitecture
import EntriesFeature
import Models
import FeedbackGeneratorClient
import UIApplicationClient
import UserDefaultsClient

public struct LayoutFeature: ReducerProtocol {
	public struct State: Equatable {
		@PresentationState public var alert: AlertState<Action.Alert>?
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		public var isAppClip: Bool
		public var layoutType: LayoutType
		public var styleType: StyleType
		@PresentationState public var theme: ThemeFeature.State? = nil
		
		public init(
			entries: IdentifiedArrayOf<DayEntriesRow.State>,
			isAppClip: Bool = false,
			layoutType: LayoutType,
			styleType: StyleType
		) {
			self.entries = entries
			self.isAppClip = isAppClip
			self.layoutType = layoutType
			self.styleType = styleType
		}
	}
	
	public enum Action: Equatable {
		case alert(PresentationAction<Alert>)
		case alertButtonTapped
		case delegate(Delegate)
		case entries(id: UUID, action: DayEntriesRow.Action)
		case layoutChanged(LayoutType)
		case theme(PresentationAction<ThemeFeature.Action>)
		case themeButtonTapped
		
		public enum Alert: Equatable {
			case skipButtonTapped
		}
		
		public enum Delegate: Equatable {
			case skip
		}
	}
	
	@Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
	@Dependency(\.applicationClient.setUserInterfaceStyle) private var setUserInterfaceStyle
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
					
				case let .layoutChanged(layoutChanged):
					state.layoutType = layoutChanged
					state.entries = fakeEntries(with: state.styleType, layout: state.layoutType)
					return .fireAndForget {
						await self.feedbackGeneratorClient.selectionChanged()
					}
					
				case .entries:
					return .none
					
				case .theme:
					return .none
					
				case .themeButtonTapped:
					let themeType = self.userDefaultsClient.userSettings.appearance.themeType
					state.theme = ThemeFeature.State(
						isAppClip: state.isAppClip,
						entries: fakeEntries(
							with: self.userDefaultsClient.userSettings.appearance.styleType,
							layout: self.userDefaultsClient.userSettings.appearance.layoutType
						),
						themeType: themeType
					)
					return .fireAndForget {
						await self.setUserInterfaceStyle(themeType.userInterfaceStyle)
					}
			}
		}
		.forEach(\.entries, action: /Action.entries) {
			DayEntriesRow()
		}
		.ifLet(\.$alert, action: /Action.alert)
		.ifLet(\.$theme, action: /Action.theme) {
			ThemeFeature()
		}
	}
}

extension AlertState where Action == LayoutFeature.Action.Alert {
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
