import Foundation
import ComposableArchitecture
import EntriesFeature
import MicrophoneFeature
import AboutFeature
import AgreementsFeature
import AppearanceFeature
import CameraFeature
import ExportFeature
import LanguageFeature
import PasscodeFeature
import Models
import StoreKitClient
import LocalAuthenticationClient

@Reducer
public struct SettingsFeature {
	public init() {}
	
	@Reducer(state: .equatable, action: .equatable)
	public enum Path {
		case about(AboutFeature)
		case activate(ActivateFeature)
		case agreements(AgreementsFeature)
		case appearance(AppearanceFeature)
		case camera(CameraFeature)
		case export(ExportFeature)
		case iconApp(IconAppFeature)
		case insert(InsertFeature)
		case language(LanguageFeature)
		case layout(LayoutFeature)
		case menu(MenuFeature)
		case microphone(MicrophoneFeature)
		case style(StyleFeature)
		case theme(ThemeFeature)
	}
	
	@ObservableState
	public struct State: Equatable {
		public var path: StackState<Path.State>
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
		
		public init(
			path: StackState<Path.State> = StackState<Path.State>()
		) {
			self.path = path
		}
	}
	
	public enum Action: Equatable {
		case biometricResult(LocalAuthenticationType)
		case navigateToPasscode
		case path(StackActionOf<Path>)
		case reviewStoreKit
		case task
		case toggleShowSplash(isOn: Bool)
	}
	
	@Dependency(\.localAuthenticationClient) var localAuthenticationClient
	@Dependency(\.storeKitClient) var storeKitClient
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case let .biometricResult(localAuthenticationType):
					state.userSettings.localAuthenticationType = localAuthenticationType
					return .none
					
				case .navigateToPasscode:
					if state.userSettings.hasPasscode {
						state.path.append(.menu(MenuFeature.State()))
					} else {
						state.path.append(.activate(ActivateFeature.State()))
					}
					return .none
					
				case let .path(.element(id: _, action: pathAction)):
					switch pathAction {
						case .activate(.delegate(.navigateToInsert)):
							state.path.append(.insert(InsertFeature.State()))
							return .none
						case .appearance(.delegate(.navigateToIconApp)):
							state.path.append(.iconApp(IconAppFeature.State()))
							return .none
						case .appearance(.delegate(.navigateToLayout)):
							state.path.append(.layout(LayoutFeature.State(entries: fakeEntries)))
							return .none
						case .appearance(.delegate(.navigateToStyle)):
							state.path.append(.style(StyleFeature.State(entries: fakeEntries)))
							return .none
						case .appearance(.delegate(.navigateToTheme)):
							state.path.append(.theme(ThemeFeature.State(entries: fakeEntries)))
							return .none
						case .insert(.delegate(.navigateToMenu)):
							state.path.append(.menu(MenuFeature.State()))
							return .none
						case .insert(.delegate(.popToRoot)):
							state.path.removeAll()
							return .none
						case .menu(.delegate(.popToRoot)):
							state.path.removeAll()
							return .none
						default:
							return .none
					}
				case .path:
					return .none
					
				case .reviewStoreKit:
					return .run { _ in await self.storeKitClient.requestReview() }
					
				case .task:
					return .run { send in
						await send(.biometricResult(self.localAuthenticationClient.determineType()))
					}
					
				case let .toggleShowSplash(showSplash):
					state.userSettings.showSplash = showSplash
					return .none
			}
		}
		.forEach(\.path, action: \.path)
		._printChanges()
	}
}
