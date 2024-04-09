@testable import AppearanceFeature
import ComposableArchitecture
import Models
import TestUtils
import XCTest

@MainActor
class IconAppViewTests: XCTestCase {
	func testIconAppHappyPath() async {
		let store = TestStore(
			initialState: IconAppFeature.State(),
			reducer: { IconAppFeature() }
		) {
			$0.feedbackGeneratorClient.selectionChanged = {}
			$0.applicationClient.setAlternateIconName = { _ in }
		}
		
		await store.send(.iconAppChanged(.dark)) {
			$0.userSettings.appearance.iconAppType = .dark
		}
		
		await store.send(.iconAppChanged(.light)) {
			$0.userSettings.appearance.iconAppType = .light
		}
	}
	
	func testSnapshot() {
		assertSnapshot(
			IconAppView(
				store: Store(
					initialState: IconAppFeature.State(),
					reducer: { }
				)
			)
		)
		
		@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
		userSettings.appearance.iconAppType = .dark
		
		assertSnapshot(
			IconAppView(
				store: Store(
					initialState: IconAppFeature.State(),
					reducer: { }
				)
			)
		)
	}
}

import SwiftUI
import SnapshotTesting
