import Foundation
import ComposableArchitecture
import Models
import EntriesFeature

@Reducer
public struct WelcomeFeature {
	public init() {}
	
	@Reducer(state: .equatable, action: .equatable)
	public enum Path {
		case layout(LayoutFeature)
		case privacy(PrivacyFeature)
		case style(StyleFeature)
		case theme(ThemeFeature)
	}
	
	@ObservableState
	public struct State: Equatable {
		@Presents public var alert: AlertState<OnboardingAlert>?
		public var isAppClip: Bool
		public var path: StackState<Path.State>
		public var selectedPage = 0
		public var tabViewAnimated = false
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
		
		public init(
			alert: AlertState<OnboardingAlert>? = nil,
			isAppClip: Bool = false,
			path: StackState<Path.State> = StackState<Path.State>(),
			selectedPage: Int = 0
		) {
			self.alert = alert
			self.isAppClip = isAppClip
			self.path = path
			self.selectedPage = selectedPage
		}
	}
	
	public enum Action: Equatable {
		case alert(PresentationAction<OnboardingAlert>)
		case delegate(Delegate)
		case nextPage
		case path(StackAction<Path.State, Path.Action>)
		case privacyButtonTapped
		case skipAlertButtonTapped
		case selectedPage(Int)
		case task
		
		@CasePathable
		public enum Alert: Equatable {
			case skip
		}
		@CasePathable
		public enum Delegate: Equatable {
			case navigateToHome
		}
	}
	
	@Dependency(\.continuousClock) var clock
	private enum CancelID {
		case timer
	}
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .alert(.presented(.skip)):
					state.alert = nil
					state.userSettings.hasShownOnboarding = true
					return .merge(
						.cancel(id: CancelID.timer),
						.run { send in await send(.delegate(.navigateToHome)) }
					)
					
				case .alert(.dismiss):
					state.alert = nil
					return .none
					
				case .delegate:
					return .none
					
				case .nextPage:
					state.tabViewAnimated = true
					if state.selectedPage == 2 {
						state.selectedPage = 0
					} else {
						state.selectedPage += 1
					}
					return .none
					
				case let .path(.element(id: _, action: pathAction)):
					switch pathAction {
						case .privacy(.delegate(.navigateToStyle)):
							state.path.append(.style(StyleFeature.State(entries: fakeEntries)))
							return .none
						case .style(.delegate(.navigateToLayout)):
							state.path.append(.layout(LayoutFeature.State(entries: fakeEntries)))
							return .none
						case .layout(.delegate(.navigateToTheme)):
							state.path.append(.theme(ThemeFeature.State(entries: fakeEntries)))
							return .none
						default:
							return .none
					}
				case .path:
					return .none
					
				case .privacyButtonTapped:
					state.path.append(.privacy(PrivacyFeature.State()))
					return .cancel(id: CancelID.timer)
					
				case .skipAlertButtonTapped:
					state.alert = .skip
					return .none
					
				case .task:
					return .run { send in
						while true {
							try await self.clock.sleep(for: .seconds(5))
							await send(.nextPage)
						}
					}
					.cancellable(id: CancelID.timer)
					
				case let .selectedPage(value):
					state.selectedPage = value
					return .merge(
						.cancel(id: CancelID.timer),
						.run { send in
							while true {
								try await self.clock.sleep(for: .seconds(5))
								await send(.nextPage)
							}
						}
							.cancellable(id: CancelID.timer)
					)
			}
		}
		.forEach(\.path, action: \.path)
	}
}

@CasePathable
public enum OnboardingAlert: Equatable {
	case skip
}

extension AlertState where Action == OnboardingAlert {
	public static var skip: AlertState {
		AlertState {
			TextState("OnBoarding.Skip.Title".localized)
		} actions: {
			ButtonState(role: .cancel, label: { TextState("Cancel".localized) })
			ButtonState(role: .destructive, action: .skip, label: { TextState("OnBoarding.Skip".localized) })
		} message: {
			TextState("OnBoarding.Skip.Alert".localized)
		}
	}
}
