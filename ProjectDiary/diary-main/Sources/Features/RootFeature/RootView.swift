import SwiftUI
import ComposableArchitecture
import UserDefaultsClient
import CoreDataClient
import FileClient
import AppFeature
import LocalAuthenticationClient
import HomeFeature
import Styles
import UIApplicationClient
import AVCaptureDeviceClient
import FeedbackGeneratorClient
import AVAudioSessionClient
import AVAudioPlayerClient
import AVAudioRecorderClient
import StoreKitClient
import PDFKitClient
import AVAssetClient
import Models
import PasscodeFeature

public struct Root: Reducer {
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
		case state(Root.State.State)
		case shortcuts
		
		case biometricAlertPresent(Bool)
	}
	
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	@Dependency(\.applicationClient) private var applicationClient
	@Dependency(\.avCaptureDeviceClient) private var avCaptureDeviceClient
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.mainRunLoop.now.date) private var now
	@Dependency(\.avAudioSessionClient) private var avAudioSessionClient
	@Dependency(\.coreDataClient) private var coreDataClient
	@Dependency(\.uuid) private var uuid
	private struct CoreDataId: Hashable {}
	
	public var body: some ReducerOf<Self> {
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
	) -> Effect<Action> {
		switch action {
				
			case .appDelegate(.didFinishLaunching):
				return .send(.setUserInterfaceStyle)
				
			case .setUserInterfaceStyle:
				return .run { send in
					await self.applicationClient.setUserInterfaceStyle(self.userDefaultsClient.themeType.userInterfaceStyle)
					await send(.startFirstScreen)
				}
				
			case .featureAction(.splash(.finishAnimation)):
				if self.userDefaultsClient.hasShownFirstLaunchOnboarding {
					if let code = self.userDefaultsClient.passcodeCode {
						state.featureState = .lockScreen(.init(code: code))
						return .none
					} else {
						return .run { send in
							await send(.startHome(cameraStatus: self.avCaptureDeviceClient.authorizationStatus()))
						}
					}
				}
				
				state.featureState = .onBoarding(.init())
				return .none
				
			case .featureAction(.onBoarding(.delegate(.goToHome))),
					.featureAction(.onBoarding(.privacy(.delegate(.goToHome)))),
					.featureAction(.onBoarding(.privacy(.style(.delegate(.goToHome))))),
					.featureAction(.onBoarding(.privacy(.style(.layout(.delegate(.goToHome)))))):
				return .send(Root.Action.requestCameraStatus)
				
			case .featureAction(.onBoarding(.privacy(.style(.layout(.theme(.startButtonTapped)))))):
				return .run { send in
					try await self.mainQueue.sleep(for: 0.001)
					await send(.requestCameraStatus)
				}
				
			case .featureAction(.lockScreen(.matchedCode)):
				return .send(.requestCameraStatus)
				
			case .featureAction(.home(.settings(.menu(.toggleFaceId(true))))),
					.featureAction(.home(.settings(.activate(.insert(.menu(.toggleFaceId(isOn: true))))))),
					.featureAction(.lockScreen(.checkFaceId)):
				return .send(.biometricAlertPresent(true))
				
			case .featureAction(.home(.settings(.menu(.faceId(response:))))),
					.featureAction(.home(.settings(.activate(.insert(.menu(.faceId(response:))))))),
					.featureAction(.lockScreen(.faceIdResponse)):
				return .run { send in
					try await self.mainQueue.sleep(for: 10)
					await send(.biometricAlertPresent(false))
				}
				
			case .featureAction:
				return .none
				
			case .startFirstScreen:
				if self.userDefaultsClient.hideSplashScreen {
					if let code = self.userDefaultsClient.passcodeCode {
						state.featureState = .lockScreen(.init(code: code))
						return .none
					} else {
						return .run { send in
							await send(.startHome(cameraStatus: self.avCaptureDeviceClient.authorizationStatus()))
						}
					}
				}
				
				return .send(.featureAction(.splash(.startAnimation)))
				
			case .requestCameraStatus:
				return .run { send in
					await send(.startHome(cameraStatus: self.avCaptureDeviceClient.authorizationStatus()))
				}
				
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
						)
					)
				)
				return .send(.featureAction(.home(.starting)))
				
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
					return .run { _ in await self.userDefaultsClient.setTimeForAskPasscode(timeForAskPasscode) }
				}
				return .run { _ in await self.userDefaultsClient.removeOptionTimeForAskPasscode() }
				
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
	) -> Effect<Action> {
		if case .home = state.featureState {
			switch action {
				case .featureAction(.home(.entries(.onAppear))):
					return .run { send in
						for await entries in await self.coreDataClient.subscriber() {
							await send(.featureAction(.home(.entries(.coreDataClientAction(.entries(entries))))))
						}
					}
				case let .featureAction(.home(.entries(.remove(entry)))):
					return .run { _ in await self.coreDataClient.removeEntry(entry.id) }
					
				case .featureAction(.home(.settings(.export(.processPDF)))):
					return .run { send in
						await send(
							.featureAction(.home(.settings(.export(.generatePDF(self.coreDataClient.fetchAll())))))
						)
					}
					
				case .featureAction(.home(.settings(.export(.previewPDF)))):
					return .run { send in
						await send(
							.featureAction(.home(.settings(.export(.generatePreview(self.coreDataClient.fetchAll())))))
						)
					}
					
				case let .featureAction(.home(.search(.searching(newText: newText)))):
					return .run { send in
						await send(
							.featureAction(.home(.search(.searchResponse(self.coreDataClient.searchEntries(newText)))))
						)
					}
					
				case .featureAction(.home(.search(.navigateImageSearch))):
					return .run { send in
						await send(.featureAction(.home(.search(.navigateSearch(.images, self.coreDataClient.searchImageEntries())))))
					}
					
				case .featureAction(.home(.search(.navigateVideoSearch))):
					return .run { send in
						await send(.featureAction(.home(.search(.navigateSearch(.videos, self.coreDataClient.searchVideoEntries())))))
					}
					
				case .featureAction(.home(.search(.navigateAudioSearch))):
					return .run { send in
						await send(.featureAction(.home(.search(.navigateSearch(.audios, self.coreDataClient.searchAudioEntries())))))
					}
					
				case let .featureAction(.home(.search(.remove(entry)))):
					return .run { _ in await self.coreDataClient.removeEntry(entry.id) }
					
				case let .featureAction(.home(.search(.entryDetailAction(.alert(.presented(.remove(entry))))))):
					return .run { _ in await self.coreDataClient.removeEntry(entry.id) }
					
				default:
					break
			}
		}
		
		//		if case let .home(homeState) = state.featureState,
		//			 let entryDetailState = homeState.entries.entryDetailState {
		//			switch action {
		//				case .featureAction(.home(.entries(.entryDetailAction(.onAppear)))):
		//					return .run { send in
		//						await send(
		//							.featureAction(
		//								.home(
		//									.entries(
		//										.detail(
		//											.entryResponse(
		//												self.coreDataClient.fetchEntry(entryDetailState.entry)
		//											)
		//										)
		//									)
		//								)
		//							)
		//						)
		//					}
		//				case let .featureAction(.home(.entries(.entryDetailAction(.removeAttachmentResponse(id))))):
		//					return .run { _ in await self.coreDataClient.removeAttachmentEntry(id) }
		//
		//				default:
		//					break
		//			}
		//		}
		
		if case let .home(homeState) = state.featureState,
			 let addEntryState = homeState.entries.addEntryState {
			switch action {
				case .featureAction(.home(.entries(.addEntryAction(.createDraftEntry)))):
					return .run { _ in
						await self.coreDataClient.createDraft(addEntryState.entry)
					}
					
				case .featureAction(.home(.entries(.addEntryAction(.addButtonTapped)))):
					let entryText = EntryText(
						id: self.uuid(),
						message: addEntryState.entry.text.message,
						lastUpdated: self.now
					)
					return .run { _ in
						await self.coreDataClient.updateMessage(entryText, addEntryState.entry)
						await self.coreDataClient.publishEntry(addEntryState.entry)
					}
					
				case let .featureAction(.home(.entries(.addEntryAction(.loadImageResponse(entryImage))))):
					return .run { _ in await self.coreDataClient.addAttachmentEntry(entryImage, addEntryState.entry.id) }
					
				case let .featureAction(.home(.entries(.addEntryAction(.loadVideoResponse(entryVideo))))):
					return .run { _ in await self.coreDataClient.addAttachmentEntry(entryVideo, addEntryState.entry.id) }
					
				case let .featureAction(.home(.entries(.addEntryAction(.loadAudioResponse(entryAudio))))):
					return .run { _ in await self.coreDataClient.addAttachmentEntry(entryAudio, addEntryState.entry.id) }
					
				case let .featureAction(.home(.entries(.addEntryAction(.removeAttachmentResponse(id))))):
					return .run { _ in await self.coreDataClient.removeAttachmentEntry(id) }
					
				case .featureAction(.home(.entries(.addEntryAction(.removeDraftEntryDismissAlert)))):
					return .run { _ in await self.coreDataClient.removeEntry(addEntryState.entry.id) }
					
				default:
					break
			}
		}
		return .none
	}
	
	private func userDefaults(
		state: inout State,
		action: Action
	) -> Effect<Action> {
		switch action {
			case let .featureAction(.home(.settings(.appearance(.layout(.layoutChanged(layout)))))):
				return .run { _ in await self.userDefaultsClient.set(layoutType: layout) }
			case let .featureAction(.home(.settings(.appearance(.style(.styleChanged(style)))))):
				return .run { _ in await self.userDefaultsClient.set(styleType: style) }
			case let .featureAction(.home(.settings(.appearance(.theme(.themeChanged(theme)))))):
				return .run { _ in await self.userDefaultsClient.set(themeType: theme) }
			case let .featureAction(.home(.settings(.toggleShowSplash(isOn: isOn)))):
				return .run { _ in await self.userDefaultsClient.setHideSplashScreen(!isOn) }
			case .featureAction(.home(.settings(.activate(.insert(.menu(.dialog(.presented(.turnOff)))))))),
					.featureAction(.home(.settings(.menu(.dialog(.presented(.turnOff)))))):
				return .run { _ in await self.userDefaultsClient.removePasscode() }
			case let .featureAction(.home(.settings(.activate(.insert(.update(code: code)))))):
				return .run { _ in await self.userDefaultsClient.setPasscode(code) }
			case let .featureAction(.home(.settings(.menu(.faceId(response: faceId))))),
				let .featureAction(.home(.settings(.activate(.insert(.menu(.faceId(response: faceId))))))):
				return .run { _ in await self.userDefaultsClient.setFaceIDActivate(faceId) }
			case let .featureAction(.home(.settings(.menu(.optionTimeForAskPasscode(changed: newOption))))),
				let .featureAction(.home(.settings(.activate(.insert(.menu(.optionTimeForAskPasscode(changed: newOption))))))):
				return .run { _ in await self.userDefaultsClient.setOptionTimeForAskPasscode(newOption.value) }
			case .featureAction(.home(.settings(.activate(.insert(.navigateMenu(true)))))):
				return .run { _ in await self.userDefaultsClient.setOptionTimeForAskPasscode(TimeForAskPasscode.never.value) }
			case let .featureAction(.home(.settings(.language(.updateLanguageTapped(language))))):
				return .run { _ in await self.userDefaultsClient.setLanguage(language.rawValue) }
			case let .featureAction(.onBoarding(.privacy(.style(.styleChanged(styleChanged))))):
				return .run { _ in await self.userDefaultsClient.set(styleType: styleChanged) }
			case let .featureAction(.onBoarding(.privacy(.style(.layout(.layoutChanged(layoutChanged)))))):
				return .run { _ in await self.userDefaultsClient.set(layoutType: layoutChanged) }
			case let .featureAction(.onBoarding(.privacy(.style(.layout(.theme(.themeChanged(themeChanged))))))):
				return .run { _ in await self.userDefaultsClient.set(themeType: themeChanged) }
			default:
				break
		}
		return .none
	}
}

public struct RootView: View {
	let store: StoreOf<Root>
	
	public init(
		store: StoreOf<Root>
	) {
		self.store = store
	}
	
	public var body: some View {
		AppView(
			store: self.store.scope(
				state: \.featureState,
				action: Root.Action.featureAction
			)
		)
	}
}
