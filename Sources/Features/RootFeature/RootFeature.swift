import AppFeature
import ComposableArchitecture
import Foundation
import HomeFeature
import Models
import OnboardingFeature
import SplashFeature
import TCAHelpers

public struct RootFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		public var appDelegate: AppDelegateState
		public var feature: AppFeature.State
		public var userSettings: UserSettings = .defaultValue
		
		public var isFirstStarted = true
		public var isBiometricAlertPresent = false
		
		public enum Status {
			case active
			case inactive
			case background
			case unknown
		}
		
		public init(
			appDelegate: AppDelegateState,
			feature: AppFeature.State
		) {
			self.appDelegate = appDelegate
			self.feature = feature
		}
	}
	
	public enum Action: Equatable {
		case appDelegate(AppDelegateAction)
		case biometricAlertPresent(Bool)
		case feature(AppFeature.Action)
		case onBoardingFinished
		case process(URL)
		case shortcuts
		case splashFinished
		case state(State.Status)
//		case startFirstScreen
//		case requestCameraStatus
//		case startHome(cameraStatus: AuthorizedVideoStatus)
	}
	
	@Dependency(\.applicationClient) private var applicationClient
	@Dependency(\.avAudioSessionClient) private var avAudioSessionClient
	@Dependency(\.avCaptureDeviceClient) private var avCaptureDeviceClient
	@Dependency(\.coreDataClient) private var coreDataClient
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.mainRunLoop.now.date) private var now
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	@Dependency(\.uuid) private var uuid
	
	private struct CoreDataId: Hashable {}
	
	public var body: some ReducerProtocolOf<Self> {
		Scope(state: \.appDelegate, action: /Action.appDelegate) {
			EmptyReducer()
		}
		Scope(state: \.feature, action: /Action.feature) {
			AppFeature()
		}
		Reduce { state, action in
			switch action {
				case .appDelegate(.didFinishLaunching):
					state.userSettings = self.userDefaultsClient.userSettings
					
					guard !state.userSettings.showSplash
					else { return .none }
					
					return .send(.splashFinished)
					
				case let .biometricAlertPresent(value):
					state.isBiometricAlertPresent = value
					return .none

				case let .feature(feature):
					switch feature {
						case .welcome(.delegate(.skip)),
								.welcome(.privacy(.presented(.delegate(.skip)))),
								.welcome(.privacy(.presented(.style(.presented(.delegate(.skip)))))),
								.welcome(.privacy(.presented(.style(.presented(.layout(.presented(.delegate(.skip)))))))):
							return .send(.onBoardingFinished)
							
						case .welcome(.privacy(.presented(.style(.presented(.layout(.presented(.theme(.presented(.finishButtonTapped))))))))):
							return .send(.onBoardingFinished)
							
						case .splash(.delegate(.finished)):
							return .send(.splashFinished)
							
						case .splash, .welcome, .home, .lockScreen:
							return .none
					}
				
				case .onBoardingFinished:
					state.userSettings.hasShownOnboarding = true
					state.feature = .home(
						HomeFeature.State(
							tabBars: [.entries, .search, .settings],
							userSettings: state.userSettings
						)
					)
					return .none
					
				case .process:
					return .none
					
				case .shortcuts:
					return .none
					
				case .splashFinished:
					guard self.userDefaultsClient.userSettings.hasShownOnboarding else {
						state.feature = .welcome(WelcomeFeature.State())
						return .none
					}
					return .send(.onBoardingFinished)
					
				case .state:
					return .none
					
	//				if let code = self.userDefaultsClient.passcodeCode {
	//					state.feature = .lockScreen(.init(code: code))
	//					return .none
	//				}
	//				state.feature = .home(
	//					.init(
	//						tabBars: [.entries, .search, .settings],
	//						sharedState: .init(
	//							showSplash: !self.userDefaultsClient.hideSplashScreen,
	//							styleType: self.userDefaultsClient.styleType,
	//							layoutType: self.userDefaultsClient.layoutType,
	//							themeType: self.userDefaultsClient.themeType,
	//							iconAppType: self.applicationClient.alternateIconName != nil ? .dark : .light,
	//							language: Localizable(rawValue: self.userDefaultsClient.language) ?? .spanish,
	//							hasPasscode: (self.userDefaultsClient.passcodeCode ?? "").count > 0,
	//							cameraStatus: .notDetermined, //status,
	//							microphoneStatus: self.avAudioSessionClient.recordPermission(),
	//							optionTimeForAskPasscode: self.userDefaultsClient.optionTimeForAskPasscode,
	//							faceIdEnabled: self.userDefaultsClient.isFaceIDActivate
	//						)
	//					)
	//				)
	//				return .none
					
	//				if self.userDefaultsClient.hasShownFirstLaunchOnboarding {
	//					if let code = self.userDefaultsClient.passcodeCode {
	//						state.feature = .lockScreen(.init(code: code))
	//						return .none
	//					} else {
	//						return .run { send in
	//							await send(.startHome(cameraStatus: self.avCaptureDeviceClient.authorizationStatus()))
	//						}
	//					}
	//				}
	//
	//				state.feature = .onBoarding(.init())
	//				return .none
					
	//			case .feature(.onBoarding(.privacy(.presented(.style(.layout(.theme(.startButtonTapped))))))):
	//				return EffectTask(value: .requestCameraStatus)
	//					.delay(for: 0.001, scheduler: self.mainQueue)
	//					.eraseToEffect()
	//
	//			case .feature(.lockScreen(.matchedCode)):
	//				return EffectTask(value: .requestCameraStatus)
					
					//    case .featureAction(.home(.settings(.menu(.toggleFaceId(true))))),
					//        .featureAction(.home(.settings(.activate(.insert(.menu(.toggleFaceId(isOn: true))))))),
					//        .featureAction(.lockScreen(.checkFaceId)):
					//      return EffectTask(value: .biometricAlertPresent(true))
					//
					//    case .featureAction(.home(.settings(.menu(.faceId(response:))))),
					//        .featureAction(.home(.settings(.activate(.insert(.menu(.faceId(response:))))))),
					//        .featureAction(.lockScreen(.faceIdResponse)):
					//      return EffectTask(value: .biometricAlertPresent(false))
					//        .delay(for: 10, scheduler: self.mainQueue)
					//        .eraseToEffect()
					
					//			case .requestCameraStatus:
					//				return .run { send in
					//					await send(.startHome(cameraStatus: self.avCaptureDeviceClient.authorizationStatus()))
					//				}
					
	//			case .startFirstScreen:
	//				if self.userDefaultsClient.hideSplashScreen {
	//					if let code = self.userDefaultsClient.passcodeCode {
	//						state.feature = .lockScreen(.init(code: code))
	//						return .none
	//					} else {
	//						return .run { send in
	//							await send(.startHome(cameraStatus: self.avCaptureDeviceClient.authorizationStatus()))
	//						}
	//					}
	//				}
	//
	//				return EffectTask(value: .feature(.splash(.start)))
					
	//			case let .startHome(cameraStatus: status):
	//				state.isFirstStarted = false
	//				state.feature = .home(
	//					.init(
	//						tabBars: [.entries, .search, .settings],
	//						sharedState: .init(
	//							showSplash: !self.userDefaultsClient.hideSplashScreen,
	//							styleType: self.userDefaultsClient.styleType,
	//							layoutType: self.userDefaultsClient.layoutType,
	//							themeType: self.userDefaultsClient.themeType,
	//							iconAppType: self.applicationClient.alternateIconName != nil ? .dark : .light,
	//							language: Localizable(rawValue: self.userDefaultsClient.language) ?? .spanish,
	//							hasPasscode: (self.userDefaultsClient.passcodeCode ?? "").count > 0,
	//							cameraStatus: status,
	//							microphoneStatus: self.avAudioSessionClient.recordPermission(),
	//							optionTimeForAskPasscode: self.userDefaultsClient.optionTimeForAskPasscode,
	//							faceIdEnabled: self.userDefaultsClient.isFaceIDActivate
	//						)
	//					)
	//				)
	//				return EffectTask(value: .feature(.home(.starting)))
					
//				case .state(.active):
//					if state.isFirstStarted {
//						return .none
//					}
//					if state.isBiometricAlertPresent {
//						return .none
//					}
	//				if self.userDefaultsClient.userSettings.optionTimeForAskPasscode > self.now {
	//					return .none
	//				}
	//				if let code = self.userDefaultsClient.passcodeCode {
	//					state.feature = .lockScreen(.init(code: code))
	//					return .none
	//				}
//					return .none
					
//				case .state(.background):
//					return .none
	//				if let timeForAskPasscode = Calendar.current.date(
	//					byAdding: .minute,
	//					value: self.userDefaultsClient.userSettings.optionTimeForAskPasscode,
	//					to: self.now
	//				) {
	//					return .fireAndForget { await self.userDefaultsClient.setTimeForAskPasscode(timeForAskPasscode) }
	//				}
	//				return .fireAndForget { await self.userDefaultsClient.removeOptionTimeForAskPasscode() }
			}
		}
		.onChange(of: \.userSettings) { userSettings, _, _ in
			.run { _ in
				await self.userDefaultsClient.set(userSettings)
			}
		}
	}
	
//	private func coreData(
//		state: inout State,
//		action: Action
//	) -> EffectTask<Action> {
//		if case .home = state.feature {
//			switch action {
//				case .feature(.home(.entries(.onAppear))):
//					return self.coreDataClient.create(CoreDataId())
//						.receive(on: self.mainQueue)
//						.eraseToEffect()
//						.map({ Action.feature(.home(.entries(.coreDataClientAction($0)))) })
//				case let .feature(.home(.entries(.remove(entry)))):
//					return self.coreDataClient.removeEntry(entry.id)
//						.fireAndForget()
//
//					//      case .featureAction(.home(.settings(.export(.processPDF)))):
//					//        return self.coreDataClient.fetchAll()
//					//          .map({ Action.featureAction(.home(.settings(.export(.generatePDF($0))))) })
//					//
//					//      case .featureAction(.home(.settings(.export(.previewPDF)))):
//					//        return self.coreDataClient.fetchAll()
//					//          .map({ Action.featureAction(.home(.settings(.export(.generatePreview($0))))) })
//
//				case let .feature(.home(.search(.searching(newText: newText)))):
//					return self.coreDataClient.searchEntries(newText)
//						.map({ Action.feature(.home(.search(.searchResponse($0)))) })
//
//				case .feature(.home(.search(.navigateImageSearch))):
//					return self.coreDataClient.searchImageEntries()
//						.map({ Action.feature(.home(.search(.navigateSearch(.images, $0)))) })
//
//				case .feature(.home(.search(.navigateVideoSearch))):
//					return self.coreDataClient.searchVideoEntries()
//						.map({ Action.feature(.home(.search(.navigateSearch(.videos, $0)))) })
//
//				case .feature(.home(.search(.navigateAudioSearch))):
//					return self.coreDataClient.searchAudioEntries()
//						.map({ Action.feature(.home(.search(.navigateSearch(.audios, $0)))) })
//
//				case let .feature(.home(.search(.remove(entry)))):
//					return self.coreDataClient.removeEntry(entry.id)
//						.fireAndForget()
//
//				case let .feature(.home(.search(.entryDetailAction(.remove(entry))))):
//					return self.coreDataClient.removeEntry(entry.id)
//						.fireAndForget()
//
//				default:
//					break
//			}
//		}
//
//		//    if case let .home(homeState) = state.featureState,
//		//       let entryDetailState = homeState.entries.entryDetailState {
//		//      switch action {
//		//      case .featureAction(.home(.entries(.entryDetailAction(.onAppear)))):
//		//        return self.coreDataClient.fetchEntry(entryDetailState.entry)
//		//          .map({ Action.featureAction(.home(.entries(.entryDetailAction(.entryResponse($0))))) })
//		//
//		//      case let .featureAction(.home(.entries(.entryDetailAction(.removeAttachmentResponse(id))))):
//		//        return self.coreDataClient.removeAttachmentEntry(id).fireAndForget()
//		//
//		//      default:
//		//        break
//		//      }
//		//    }
//		//
//		if case let .home(homeState) = state.feature,
//			let addEntryState = homeState.entries.addEntryState {
//			switch action {
//				case .feature(.home(.entries(.addEntryAction(.createDraftEntry)))):
//					return self.coreDataClient.createDraft(addEntryState.entry)
//						.fireAndForget()
//
//				case .feature(.home(.entries(.addEntryAction(.addButtonTapped)))):
//					let entryText = EntryText(
//						id: self.uuid(),
//						message: addEntryState.text,
//						lastUpdated: self.now
//					)
//					return .merge(
//						self.coreDataClient.updateMessage(entryText, addEntryState.entry)
//							.fireAndForget(),
//						self.coreDataClient.publishEntry(addEntryState.entry)
//							.fireAndForget()
//					)
//				case let .feature(.home(.entries(.addEntryAction(.loadImageResponse(entryImage))))):
//					return self.coreDataClient.addAttachmentEntry(entryImage, addEntryState.entry.id)
//						.fireAndForget()
//
//				case let .feature(.home(.entries(.addEntryAction(.loadVideoResponse(entryVideo))))):
//					return self.coreDataClient.addAttachmentEntry(entryVideo, addEntryState.entry.id)
//						.fireAndForget()
//
//				case let .feature(.home(.entries(.addEntryAction(.loadAudioResponse(entryAudio))))):
//					return self.coreDataClient.addAttachmentEntry(entryAudio, addEntryState.entry.id)
//						.fireAndForget()
//
//				case let .feature(.home(.entries(.addEntryAction(.removeAttachmentResponse(id))))):
//					return self.coreDataClient.removeAttachmentEntry(id)
//						.fireAndForget()
//
//				case .feature(.home(.entries(.addEntryAction(.removeDraftEntryDismissAlert)))):
//					return self.coreDataClient.removeEntry(addEntryState.entry.id)
//						.fireAndForget()
//
//				default:
//					break
//			}
//		}
//		return .none
//	}
}
