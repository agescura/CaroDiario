import AppFeature
import ComposableArchitecture
import CoreDataClient
import Models
import PasscodeFeature
import SettingsFeature
import SwiftUI
import UIApplicationClient

public struct RootFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		public var appDelegate: AppDelegateState
		public var featureState: AppReducer.State
		
		public var isFirstStarted = true
		public var isBiometricAlertPresent = false
		
		public enum State {
			case active
			case inactive
			case background
			case unknown
		}
		
		public init(
			appDelegate: AppDelegateState,
			featureState: AppReducer.State
		) {
			self.appDelegate = appDelegate
			self.featureState = featureState
		}
	}
	
	public enum Action: Equatable {
		case appDelegate(AppDelegateAction)
		case featureAction(AppReducer.Action)
		
		case setUserInterfaceStyle
		case startFirstScreen
		
		case requestCameraStatus
		case startHome(cameraStatus: AuthorizedVideoStatus)
		
		case process(URL)
		case state(RootFeature.State.State)
		case shortcuts
		
		case biometricAlertPresent(Bool)
	}
	
	@Dependency(\.applicationClient) private var applicationClient
	@Dependency(\.avAudioSessionClient) private var avAudioSessionClient
	@Dependency(\.avCaptureDeviceClient) private var avCaptureDeviceClient
	@Dependency(\.coreDataClient) private var coreDataClient
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.mainRunLoop.now.date) private var now
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	@Dependency(\.uuid) private var uuid
	private enum CancelID {
		case coreData
	}
	
	public var body: some ReducerProtocolOf<Self> {
		Scope(state: \.appDelegate, action: /Action.appDelegate) {
			EmptyReducer()
		}
		Scope(state: \.featureState, action: /Action.featureAction) {
			AppReducer()
		}
		Reduce(self.core)
		Reduce(self.coreData)
		Reduce(self.userDefaults)
	}
	
	private func core(
		state: inout State,
		action: Action
	) -> EffectTask<Action> {
		switch action {
			case .appDelegate(.didFinishLaunching):
				return EffectTask(value: .setUserInterfaceStyle)
				
			case .setUserInterfaceStyle:
				return .task { @MainActor in
					await self.applicationClient.setUserInterfaceStyle(self.userDefaultsClient.themeType.userInterfaceStyle)
					return .startFirstScreen
				}
				
			case .featureAction(.splash(.delegate(.finishAnimation))):
				if self.userDefaultsClient.hasShownFirstLaunchOnboarding {
					if let code = self.userDefaultsClient.passcodeCode {
						state.featureState = .lockScreen(.init(code: code))
						return .none
					} else {
						return self.avCaptureDeviceClient.authorizationStatus()
							.map(RootFeature.Action.startHome)
					}
				}
				
				state.featureState = .onBoarding(.init())
				return .none
				
			case .featureAction(.onBoarding(.delegate(.skip))),
					.featureAction(.onBoarding(.destination(.presented(.privacy(.delegate(.skip)))))),
					.featureAction(.onBoarding(.destination(.presented(.privacy(.destination(.presented(.style(.delegate(.skip))))))))),
					.featureAction(.onBoarding(.destination(.presented(.privacy(.destination(.presented(.style(.destination(.presented(.layout(.delegate(.skip)))))))))))):
				return EffectTask(value: RootFeature.Action.requestCameraStatus)
				
			case .featureAction(.onBoarding(.destination(.presented(.privacy(.destination(.presented(.style(.destination(.presented(.layout(.destination(.presented(.theme(.startButtonTapped)))))))))))))):
				return EffectTask(value: .requestCameraStatus)
					.delay(for: 0.001, scheduler: self.mainQueue)
					.eraseToEffect()
				
			case .featureAction(.lockScreen(.matchedCode)):
				return EffectTask(value: .requestCameraStatus)
				
			case .featureAction(.home(.settings(.destination(.presented(.menu(.toggleFaceId(true))))))),
					.featureAction(.home(.settings(.destination(.presented(.activate(.insert(.presented(.menu(.presented(.toggleFaceId(isOn: true))))))))))),
					.featureAction(.lockScreen(.checkFaceId)):
				return EffectTask(value: .biometricAlertPresent(true))
				
			case .featureAction(.home(.settings(.destination(.presented(.menu(.faceId(response:))))))),
					.featureAction(.home(.settings(.destination(.presented(.activate(.insert(.presented(.menu(.presented(.faceId(response:))))))))))),
					.featureAction(.lockScreen(.faceIdResponse)):
				return EffectTask(value: .biometricAlertPresent(false))
					.delay(for: 10, scheduler: self.mainQueue)
					.eraseToEffect()
				
			case .featureAction:
				return .none
				
			case .startFirstScreen:
				if self.userDefaultsClient.hideSplashScreen {
					if let code = self.userDefaultsClient.passcodeCode {
						state.featureState = .lockScreen(.init(code: code))
						return .none
					} else {
						return self.avCaptureDeviceClient.authorizationStatus()
							.map(RootFeature.Action.startHome)
					}
				}
				
				return EffectTask(value: .featureAction(.splash(.startAnimation)))
				
			case .requestCameraStatus:
				return self.avCaptureDeviceClient.authorizationStatus()
					.map(RootFeature.Action.startHome)
				
			case let .startHome(cameraStatus: status):
				state.isFirstStarted = false
				state.featureState = .home(
					.init(
						tabBars: [.entries, .search, .settings],
						sharedState: .init(
							showSplash: !self.userDefaultsClient.hideSplashScreen,
							styleType: self.userDefaultsClient.styleType,
							layoutType: self.userDefaultsClient.layoutType,
							themeType: self.userDefaultsClient.themeType,
							iconAppType: self.applicationClient.alternateIconName != nil ? .dark : .light,
							language: Localizable(rawValue: self.userDefaultsClient.language) ?? .spanish,
							hasPasscode: (self.userDefaultsClient.passcodeCode ?? "").count > 0,
							cameraStatus: status,
							microphoneStatus: self.avAudioSessionClient.recordPermission(),
							optionTimeForAskPasscode: self.userDefaultsClient.optionTimeForAskPasscode,
							faceIdEnabled: self.userDefaultsClient.isFaceIDActivate
						),
						settings: SettingsFeature.State(
							cameraStatus: status,
							destination: nil,
							microphoneStatus: self.avAudioSessionClient.recordPermission(),
							userSettings: UserSettings(
								showSplash: !self.userDefaultsClient.hideSplashScreen,
								hasShownOnboarding: true,
								appearance: AppearanceSettings(
									styleType: self.userDefaultsClient.styleType,
									layoutType: self.userDefaultsClient.layoutType,
									themeType: self.userDefaultsClient.themeType,
									iconAppType: self.applicationClient.alternateIconName != nil ? .dark : .light
								),
								language: Localizable(rawValue: self.userDefaultsClient.language) ?? .spanish,
								passcode: self.userDefaultsClient.passcodeCode ?? "",
								optionTimeForAskPasscode: self.userDefaultsClient.optionTimeForAskPasscode,
								faceIdEnabled: self.userDefaultsClient.isFaceIDActivate
							)
						)
					)
				)
				return EffectTask(value: .featureAction(.home(.starting)))
				
			case .process:
				return .none
				
			case .state(.active):
				if state.isFirstStarted {
					return .none
				}
				if state.isBiometricAlertPresent {
					return .none
				}
				if let timeForAskPasscode = self.userDefaultsClient.timeForAskPasscode,
					timeForAskPasscode > self.now {
					return .none
				}
				if let code = self.userDefaultsClient.passcodeCode {
					state.featureState = .lockScreen(.init(code: code))
					return .none
				}
				return .none
				
			case .state(.background):
				if let timeForAskPasscode = Calendar.current.date(
					byAdding: .minute,
					value: self.userDefaultsClient.optionTimeForAskPasscode,
					to: self.now
				) {
					return self.userDefaultsClient.setTimeForAskPasscode(timeForAskPasscode)
						.fireAndForget()
				}
				return self.userDefaultsClient.removeOptionTimeForAskPasscode()
					.fireAndForget()
				
			case .state:
				return .none
				
			case .shortcuts:
				return .none
				
			case let .biometricAlertPresent(value):
				state.isBiometricAlertPresent = value
				return .none
		}
	}
	
	private func coreData(
		state: inout State,
		action: Action
	) -> EffectTask<Action> {
		if case .home = state.featureState {
			switch action {
				case .featureAction(.home(.entries(.onAppear))):
					return self.coreDataClient.create(CancelID.coreData)
						.receive(on: self.mainQueue)
						.eraseToEffect()
						.map({ Action.featureAction(.home(.entries(.coreDataClientAction($0)))) })
				case let .featureAction(.home(.entries(.remove(entry)))):
					return self.coreDataClient.removeEntry(entry.id)
						.fireAndForget()
					
				case .featureAction(.home(.settings(.destination(.presented(.export(.processPDF)))))):
					return self.coreDataClient.fetchAll()
						.map({ Action.featureAction(.home(.settings(.destination(.presented(.export(.generatePDF($0))))))) })
					
				case .featureAction(.home(.settings(.destination(.presented(.export(.previewPDFButtonTapped)))))):
					return self.coreDataClient.fetchAll()
						.map({ Action.featureAction(.home(.settings(.destination(.presented(.export(.generatePreview($0))))))) })
					
				case let .featureAction(.home(.search(.searching(newText: newText)))):
					return self.coreDataClient.searchEntries(newText)
						.map({ Action.featureAction(.home(.search(.searchResponse($0)))) })
					
				case .featureAction(.home(.search(.navigateImageSearch))):
					return self.coreDataClient.searchImageEntries()
						.map({ Action.featureAction(.home(.search(.navigateSearch(.images, $0)))) })
					
				case .featureAction(.home(.search(.navigateVideoSearch))):
					return self.coreDataClient.searchVideoEntries()
						.map({ Action.featureAction(.home(.search(.navigateSearch(.videos, $0)))) })
					
				case .featureAction(.home(.search(.navigateAudioSearch))):
					return self.coreDataClient.searchAudioEntries()
						.map({ Action.featureAction(.home(.search(.navigateSearch(.audios, $0)))) })
					
				case let .featureAction(.home(.search(.remove(entry)))):
					return self.coreDataClient.removeEntry(entry.id)
						.fireAndForget()
					
				case let .featureAction(.home(.search(.destination(.presented(.entryDetail(.remove(entry))))))):
					return self.coreDataClient.removeEntry(entry.id)
						.fireAndForget()
					
				default:
					break
			}
		}
		
		if case let .home(homeState) = state.featureState,
			let entryDetailState = homeState.entries.entryDetailState {
			switch action {
				case .featureAction(.home(.entries(.entryDetailAction(.onAppear)))):
					return self.coreDataClient.fetchEntry(entryDetailState.entry)
						.map({ Action.featureAction(.home(.entries(.entryDetailAction(.entryResponse($0))))) })
					
				case let .featureAction(.home(.entries(.entryDetailAction(.removeAttachmentResponse(id))))):
					return self.coreDataClient.removeAttachmentEntry(id).fireAndForget()
					
				default:
					break
			}
		}
		
		if case let .home(homeState) = state.featureState,
			let addEntryState = homeState.entries.addEntryState ?? homeState.entries.entryDetailState?.addEntryState {
			switch action {
				case .featureAction(.home(.entries(.addEntryAction(.createDraftEntry)))),
						.featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.createDraftEntry))))):
					return self.coreDataClient.createDraft(addEntryState.entry)
						.fireAndForget()
					
				case .featureAction(.home(.entries(.addEntryAction(.addButtonTapped)))),
						.featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.addButtonTapped))))):
					let entryText = EntryText(
						id: self.uuid(),
						message: addEntryState.text,
						lastUpdated: self.now
					)
					return .merge(
						self.coreDataClient.updateMessage(entryText, addEntryState.entry)
							.fireAndForget(),
						self.coreDataClient.publishEntry(addEntryState.entry)
							.fireAndForget()
					)
				case let .featureAction(.home(.entries(.addEntryAction(.loadImageResponse(entryImage))))),
					let .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.loadImageResponse(entryImage)))))):
					return self.coreDataClient.addAttachmentEntry(entryImage, addEntryState.entry.id)
						.fireAndForget()
					
				case let .featureAction(.home(.entries(.addEntryAction(.loadVideoResponse(entryVideo))))),
					let .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.loadVideoResponse(entryVideo)))))):
					return self.coreDataClient.addAttachmentEntry(entryVideo, addEntryState.entry.id)
						.fireAndForget()
					
				case let .featureAction(.home(.entries(.addEntryAction(.loadAudioResponse(entryAudio))))),
					let .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.loadAudioResponse(entryAudio)))))):
					return self.coreDataClient.addAttachmentEntry(entryAudio, addEntryState.entry.id)
						.fireAndForget()
					
				case let .featureAction(.home(.entries(.addEntryAction(.removeAttachmentResponse(id))))),
					let .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.removeAttachmentResponse(id)))))):
					return self.coreDataClient.removeAttachmentEntry(id)
						.fireAndForget()
					
				case .featureAction(.home(.entries(.addEntryAction(.removeDraftEntryDismissAlert)))),
						.featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.removeDraftEntryDismissAlert))))):
					return self.coreDataClient.removeEntry(addEntryState.entry.id)
						.fireAndForget()
					
				default:
					break
			}
		}
		return .none
	}
	
	private func userDefaults(
		state: inout State,
		action: Action
	) -> EffectTask<Action> {
		switch action {
			case let .featureAction(.home(.settings(.destination(.presented(.appearance(.destination(.presented(.layout(.layoutChanged(layout)))))))))):
				return self.userDefaultsClient.set(layoutType: layout)
					.fireAndForget()
			case let .featureAction(.home(.settings(.destination(.presented(.appearance(.destination(.presented(.style(.styleChanged(style)))))))))):
				return self.userDefaultsClient.set(styleType: style)
					.fireAndForget()
			case let .featureAction(.home(.settings(.destination(.presented(.appearance(.destination(.presented(.theme(.themeChanged(theme)))))))))):
				return self.userDefaultsClient.set(themeType: theme)
					.fireAndForget()
			case let .featureAction(.home(.settings(.toggleShowSplash(isOn: isOn)))):
				self.userDefaultsClient.setHideSplashScreen(!isOn)
				return .none
			case .featureAction(.home(.settings(.destination(.presented(.activate(.insert(.presented(.menu(.presented(.delegate(.turnOffPasscode))))))))))),
					.featureAction(.home(.settings(.destination(.presented(.menu(.delegate(.turnOffPasscode))))))):
				return self.userDefaultsClient.removePasscode()
					.fireAndForget()
			case let .featureAction(.home(.settings(.destination(.presented(.activate(.insert(.presented(.update(code: code))))))))):
				return self.userDefaultsClient.setPasscode(code)
					.fireAndForget()
			case let .featureAction(.home(.settings(.destination(.presented(.menu(.faceId(response: faceId))))))),
				let .featureAction(.home(.settings(.destination(.presented(.activate(.insert(.presented(.menu(.presented(.faceId(response: faceId))))))))))):
				self.userDefaultsClient.setFaceIDActivate(faceId)
				return .none
			case let .featureAction(.home(.settings(.destination(.presented(.menu(.optionTimeForAskPasscode(changed: newOption))))))),
				let .featureAction(.home(.settings(.destination(.presented(.activate(.insert(.presented(.menu(.presented(.optionTimeForAskPasscode(changed: newOption))))))))))):
				return self.userDefaultsClient.setOptionTimeForAskPasscode(newOption.value)
					.fireAndForget()
			case .featureAction(.home(.settings(.destination(.presented(.activate(.insert(.presented(.menuButtonTapped)))))))):
				return self.userDefaultsClient.setOptionTimeForAskPasscode(TimeForAskPasscode.never.value)
					.fireAndForget()
			case let .featureAction(.home(.settings(.destination(.presented(.language(.updateLanguageTapped(language))))))):
				return self.userDefaultsClient.setLanguage(language.rawValue)
					.fireAndForget()
			case let .featureAction(.onBoarding(.destination(.presented(.privacy(.destination(.presented(.style(.styleChanged(styleChanged))))))))):
				return self.userDefaultsClient.set(styleType: styleChanged)
					.fireAndForget()
			case let .featureAction(.onBoarding(.destination(.presented(.privacy(.destination(.presented(.style(.destination(.presented(.layout(.layoutChanged(layoutChanged)))))))))))):
				return self.userDefaultsClient.set(layoutType: layoutChanged)
					.fireAndForget()
			case let .featureAction(.onBoarding(.destination(.presented(.privacy(.destination(.presented(.style(.destination(.presented(.layout(.destination(.presented(
				.theme(.themeChanged(themeChanged))))))))))))))):
				return self.userDefaultsClient.set(themeType: themeChanged)
					.fireAndForget()
			default:
				break
		}
		return .none
	}
}

public struct RootView: View {
	private let store: StoreOf<RootFeature>
	
	public init(
		store: StoreOf<RootFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		AppView(
			store: self.store.scope(
				state: \.featureState,
				action: RootFeature.Action.featureAction
			)
		)
	}
}
