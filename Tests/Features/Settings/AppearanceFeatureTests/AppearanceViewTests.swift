@testable import AppearanceFeature
import ComposableArchitecture
import EntriesFeature
import Models
import XCTest

@MainActor
class AppearanceViewTests: XCTestCase {
	
	func testHappyPath() async {
		var selectionChanged = false
		var setAlternateIconName: String? = nil
		let store = TestStore(
			initialState: AppearanceFeature.State(
				appearanceSettings: .defaultValue
			),
			reducer: AppearanceFeature()
		) {
			$0.feedbackGeneratorClient.selectionChanged = {
				selectionChanged = true
			}
			$0.applicationClient.setAlternateIconName = { name in
				setAlternateIconName = name
			}
			$0.applicationClient.setUserInterfaceStyle = { style in
				XCTAssertEqual(style, .dark)
			}
		}
		
		await store.send(.styleButtonTapped) {
			$0.destination = .style(
				StyleFeature.State(
					styleType: .rectangle,
					layoutType: .horizontal,
					entries: fakeEntries(
						with: .rectangle,
						layout: .horizontal
					)
				)
			)
		}
		
		selectionChanged = false
		await store.send(.destination(.presented(.style(.styleChanged(.rounded))))) {
			$0.destination = .style(
				StyleFeature.State(
					styleType: .rounded,
					layoutType: .horizontal,
					entries: fakeEntries(
						with: .rounded,
						layout: .horizontal
					)
				)
			)
			XCTAssertTrue(selectionChanged)
		}
		
		await store.send(.destination(.dismiss)) {
			$0.destination = nil
			$0.appearanceSettings.styleType = .rounded
		}
		
		await store.send(.layoutButtonTapped) {
			$0.destination = .layout(
				LayoutFeature.State(
					layoutType: .horizontal,
					styleType: .rounded,
					entries: fakeEntries(
						with: .rounded,
						layout: .horizontal
					)
				)
			)
		}
		
		selectionChanged = false
		await store.send(.destination(.presented(.layout(.layoutChanged(.vertical))))) {
			$0.destination = .layout(
				LayoutFeature.State(
					layoutType: .vertical,
					styleType: .rounded,
					entries: fakeEntries(
						with: .rounded,
						layout: .vertical
					)
				)
			)
			XCTAssertTrue(selectionChanged)
		}
		
		await store.send(.destination(.dismiss)) {
			$0.destination = nil
			$0.appearanceSettings.layoutType = .vertical
		}
		
		await store.send(.iconAppButtonTapped) {
			$0.destination = .iconApp(
				IconAppFeature.State(iconAppType: .light)
			)
		}
		
		selectionChanged = false
		await store.send(.destination(.presented(.iconApp(.iconAppChanged(.dark))))) {
			$0.destination = .iconApp(
				IconAppFeature.State(iconAppType: .dark)
			)
			XCTAssertTrue(selectionChanged)
			XCTAssertEqual(setAlternateIconName, "AppIcon-2")
		}
		
		await store.send(.destination(.dismiss)) {
			$0.destination = nil
			$0.appearanceSettings.iconAppType = .dark
		}
		
		await store.send(.themeButtonTapped) {
			$0.destination = .theme(
				ThemeFeature.State(
					themeType: .system,
					entries: fakeEntries(
						with: .rounded,
						layout: .vertical
					)
				)
			)
		}
		
		await store.send(.destination(.presented(.theme(.themeChanged(.dark))))) {
			$0.destination = .theme(
				ThemeFeature.State(
					themeType: .dark,
					entries: fakeEntries(
						with: .rounded,
						layout: .vertical
					)
				)
			)
		}
		
		await store.send(.destination(.dismiss)) {
			$0.destination = nil
			$0.appearanceSettings.themeType = .dark
		}
	}
	
	func testSnapshot() async {
		SnapshotTesting.diffTool = "ksdiff"
		
		let store = Store(
			initialState: AppearanceFeature.State(
				appearanceSettings: .defaultValue
			),
			reducer: AppearanceFeature()
		 )
		let view = NavigationView {
			AppearanceView(store: store)
		}

		lazy var viewStore = ViewStore(
			store
		)

		let vc = UIHostingController(rootView: view)
		vc.view.frame = UIScreen.main.bounds
		assertSnapshot(matching: vc, as: .image)

		viewStore.send(.iconAppButtonTapped)

		assertSnapshot(matching: vc, as: .image)

		viewStore.send(.destination(.presented(.iconApp(.iconAppChanged(.dark)))))
		viewStore.send(.destination(.dismiss))
		assertSnapshot(matching: vc, as: .image)
	}
}

import SnapshotTesting
import SwiftUI
