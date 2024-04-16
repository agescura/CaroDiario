import XCTest
@testable import SettingsFeature
import ComposableArchitecture
import SwiftUI
import UserDefaultsClient
import Styles
import PasscodeFeature

@MainActor
class SettingsFeatureTests: XCTestCase {
	
	func testInsertPasscode() async {
		let store = TestStore(
			initialState: SettingsFeature.State(),
			reducer: { SettingsFeature() }
		)
		
		await store.send(\.navigateToPasscode) {
			$0.path = StackState([
				.activate(ActivateFeature.State())
			])
		}
		await store.send(\.path[id: 0].activate.insertButtonTapped)
		await store.receive(\.path[id: 0].activate.delegate.navigateToInsert) {
			$0.path[id: 1] = .insert(InsertFeature.State())
		}
		await store.send(\.path[id: 1].insert.update, "1234") {
			$0.path[id: 1]?.insert?.code = ""
			$0.path[id: 1]?.insert?.firstCode = "1234"
			$0.path[id: 1]?.insert?.step = .secondCode
		}
		await store.send(\.path[id: 1].insert.update, "1234") {
			$0.path[id: 1]?.insert?.code = "1234"
			$0.userSettings.passcode = "1234"
		}
		await store.receive(\.path[id: 1].insert.delegate.navigateToMenu) {
			$0.path[id: 2] = .menu(MenuFeature.State())
		}
	}
}
//    func testSettingsHappyPath() {
//        let store = TestStore(
//            initialState: SettingsState(
//                showSplash: true,
//                styleType: .rectangle,
//                layoutType: .horizontal,
//                themeType: .system,
//                iconType: .light,
//                hasPasscode: false,
//                cameraStatus: .notDetermined,
//                optionTimeForAskPasscode: 0,
//                faceIdEnabled: false,
//                language: .spanish,
//                microphoneStatus: .notDetermined
//            ),
//            reducer: settingsReducer,
//            environment: SettingsEnvironment(
//                fileClient: .noop,
//                localAuthenticationClient: .noop,
//                applicationClient: .init(
//                    alternateIconName: nil,
//                    setAlternateIconName: { _ in () },
//                    supportsAlternateIcons: { true },
//                    openSettings: { .fireAndForget {} },
//                    open: { _, _  in .fireAndForget {} },
//                    canOpen: { _ in true },
//                    share: { _, _  in .fireAndForget {} },
//                    showTabView: { _ in .fireAndForget {} }
//                ),
//                avCaptureDeviceClient: .noop,
//                feedbackGeneratorClient: .noop,
//                avAudioSessionClient: .noop,
//                storeKitClient: .noop,
//                pdfKitClient: .noop,
//                mainQueue: .immediate,
//                date: Date.init
//            )
//        )
//        
//        store.send(.toggleShowSplash(isOn: false)) {
//            $0.showSplash = false
//        }
//        
//        store.send(.navigateAppearance(true)) {
//            $0.route = .appearance(
//                .init(
//                    styleType: .rectangle,
//                    layoutType: .horizontal,
//                    themeType: .system,
//                    iconAppType: .light
//                )
//            )
//        }
//        
//        store.send(.navigateAppearance(false)) {
//            $0.appearanceState = nil
//            $0.route = nil
//        }
//    }
//}
