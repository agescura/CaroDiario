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
		case activate(ActivateFeature)
		case appearance(AppearanceFeature)
		case camera(CameraFeature)
		case iconApp(IconAppFeature)
		case insert(InsertFeature)
		case language(LanguageFeature)
		case layout(LayoutFeature)
		case menu(MenuFeature)
		case style(StyleFeature)
		case theme(ThemeFeature)
	}
	
	@ObservableState
	public struct State: Equatable {
		public var localAuthenticationType: LocalAuthenticationType = .none
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
		case path(StackAction<Path.State, Path.Action>)
		case task
		case toggleShowSplash(isOn: Bool)
		
		case appearance(AppearanceFeature.Action)
		case navigateAppearance(Bool)
		
		case language(LanguageFeature.Action)
		case navigateLanguage(Bool)
		
		case activate(ActivateFeature.Action)
		case navigateActivate(Bool)
		
		case menu(MenuFeature.Action)
		case navigateMenu(Bool)
		
		case camera(CameraFeature.Action)
		case navigateCamera(Bool)
		
		case microphone(Microphone.Action)
		case navigateMicrophone(Bool)
		
		case agreements(Agreements.Action)
		case navigateAgreements(Bool)
		
		case reviewStoreKit
		
		case export(Export.Action)
		case navigateExport(Bool)
		
		case about(AboutFeature.Action)
		case navigateAbout(Bool)
	}
	
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.localAuthenticationClient) private var localAuthenticationClient
	@Dependency(\.storeKitClient) private var storeKitClient
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case let .biometricResult(localAuthenticationType):
					state.localAuthenticationType = localAuthenticationType
					return .none
					
				case .navigateToPasscode:
					if state.userSettings.hasPasscode {
						state.path.append(.menu(MenuFeature.State(authenticationType: state.localAuthenticationType, optionTimeForAskPasscode: 5)))
					} else {
						state.path.append(.activate(ActivateFeature.State()))
					}
					return .none
					
				case let .path(.element(id: _, action: pathAction)):
					switch pathAction {
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
						default:
							return .none
					}
				case .path:
					return .none
					
				case .task:
					return .run { send in
						await send(.biometricResult(self.localAuthenticationClient.determineType()))
					}
					
				case let .navigateAppearance(value):
					//				state.destination = value ? .appearance(
					//					.init(
					//						styleType: state.styleType,
					//						layoutType: state.layoutType,
					//						themeType: state.themeType,
					//						iconAppType: state.iconAppType
					//					)
					//				) : nil
					return .none
					
				case .appearance:
					return .none
					
				case let .navigateLanguage(value):
					//				state.destination = value ? .language(
					//					.init(language: state.language)
					//				) : nil
					return .none
					
				case .language:
					return .none
					
				case let .toggleShowSplash(showSplash):
					state.userSettings.showSplash = showSplash
					return .none
					
//				case .activate(.insert(.navigateMenu(true))):
//					//				state.hasPasscode = true
//					return .none
					
//				case .menu(.dialog(.presented(.turnOff))),
//						.activate(.insert(.menu(.dialog(.presented(.turnOff))))):
//					//				state.hasPasscode = false
//					return .run { send in
//						try await self.mainQueue.sleep(for: .seconds(0.1))
//						await send(.navigateActivate(false))
//					}
					
//				case .activate(.insert(.menu(.popToRoot))),
//						.activate(.insert(.popToRoot)),
//						.menu(.popToRoot),
//						.activate(.insert(.success)):
//					return .send(.navigateActivate(false))
					
				case .activate:
					return .none
					
				case let .navigateActivate(value):
					//				state.destination = value ? .activate(
					//					.init(
					//						faceIdEnabled: state.faceIdEnabled,
					//						hasPasscode: state.hasPasscode
					//					)
					//				) : nil
					return .none
					
				case .menu:
					return .none
					
				case let .navigateMenu(value):
					//				state.destination = value ? .menu(
					//					.init(
					//						authenticationType: state.authenticationType,
					//						optionTimeForAskPasscode: state.optionTimeForAskPasscode,
					//						faceIdEnabled: state.faceIdEnabled
					//					)
					//				) : nil
					return .none
					
				case .microphone:
					return .none
					
				case let .navigateMicrophone(value):
					//				state.destination = value ? .microphone(
					//					.init(microphoneStatus: state.microphoneStatus)
					//				) : nil
					return .none
					
				case .camera:
					return .none
					
				case let .navigateCamera(value):
					//				state.destination = value ? .camera(
					//					.init(cameraStatus: state.cameraStatus)
					//				) : nil
					return .none
					
				case let .navigateAgreements(value):
					//				state.destination = value ? .agreements(.init()) : nil
					return .none
					
				case .agreements:
					return .none
					
				case .reviewStoreKit:
					return .run { _ in await self.storeKitClient.requestReview() }
					
				case let .navigateExport(value):
					//				state.destination = value ? .export(.init()) : nil
					return .none
					
				case .export:
					return .none
					
				case let .navigateAbout(value):
					//				state.destination = value ? .about(.init()) : nil
					return .none
					
				case .about:
					return .none
					
				default:
					return .none
			}
		}
		.forEach(\.path, action: \.path)
	}
}
