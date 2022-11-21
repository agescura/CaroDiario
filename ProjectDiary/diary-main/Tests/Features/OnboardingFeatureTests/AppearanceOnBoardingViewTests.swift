//
//  AppearanceOnBoardingViewTests.swift
//  
//
//  Created by Albert Gil Escura on 21/8/21.
//

import XCTest
@testable import OnboardingFeature
import ComposableArchitecture
import SwiftUI
import EntriesFeature
import UserDefaultsClient

@MainActor
class AppearanceOnboardingViewTests: XCTestCase {
    
    private let id1 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    private let id2 = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    private let id3 = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
    private let date = Date.init(timeIntervalSince1970: 1629486993)

    lazy var fakeEntries: IdentifiedArrayOf<DayEntriesRowState> = [
        .init(dayEntry: .init(entry: [
            .init(id: id1, date: date, startDay: date, text: .init(id: id1, message: "Entries.FakeEntry.FirstMessage".localized, lastUpdated: date)),
            .init(id: id2, date: date, startDay: date, text: .init(id: id2, message: "Entries.FakeEntry.SecondMessage".localized, lastUpdated: date))
        ], style: .rectangle, layout: .vertical), id: id3)
    ]
    
    lazy var fakeEntriesHorizontal: IdentifiedArrayOf<DayEntriesRowState> = [
        .init(dayEntry: .init(entry: [
            .init(id: id1, date: date, startDay: date, text: .init(id: id1, message: "Entries.FakeEntry.FirstMessage".localized, lastUpdated: date)),
            .init(id: id2, date: date, startDay: date, text: .init(id: id2, message: "Entries.FakeEntry.SecondMessage".localized, lastUpdated: date))
        ], style: .rectangle, layout: .horizontal), id: id3)
    ]
    
    func testAppearanceOnBoardingViewHappyPath() async {
        let store = TestStore(
            initialState: LayoutOnBoardingState(styleType: .rectangle, layoutType: .horizontal, entries: []),
            reducer: layoutOnBoardingReducer,
            environment: LayoutOnBoardingEnvironment(
                userDefaultsClient: .noop,
                feedbackGeneratorClient: .noop,
                mainQueue: .immediate,
                backgroundQueue: .immediate,
                date: Date.init,
                uuid: UUID.init
            )
        )
        
        await store.send(.layoutChanged(.vertical)) {
            $0.layoutType = .vertical
            $0.entries = self.fakeEntries
        }
        
        await store.send(.navigateThemeOnBoarding(true)) {
            $0.themeOnBoardingState = .init(
                themeType: .system,
                entries: self.fakeEntriesHorizontal
            )
            $0.navigateThemeOnBoarding = true
        }
    }
    
    func testAppearanceOnBoardingViewSkipAlertFlow() {
        var setOnBoardingShownCalled = false
        
        let store = TestStore(
            initialState: LayoutOnBoardingState(styleType: .rectangle, layoutType: .horizontal, entries: []),
            reducer: layoutOnBoardingReducer,
            environment: LayoutOnBoardingEnvironment(
                userDefaultsClient: UserDefaultsClient(
                    boolForKey: { _ in false },
                    setBool: { value, key in
                        if key == "hasShownOnboardingKey" && value == true {
                            setOnBoardingShownCalled = true
                        }
                        return .fireAndForget {}
                    },
                    stringForKey: { _ in nil },
                    setString: { _, _ in .fireAndForget {} },
                    intForKey: { _ in nil  },
                    setInt: { _, _  in .fireAndForget {} },
                    dateForKey: { _ in nil },
                    setDate: { _, _  in .fireAndForget {} },
                    remove: { _ in .fireAndForget {} }
                ),
                feedbackGeneratorClient: .noop,
                mainQueue: .immediate,
                backgroundQueue: .immediate,
                date: Date.init,
                uuid: UUID.init
            )
        )
        
        store.send(.skipAlertButtonTapped) {
            $0.skipAlert = .init(
                title: .init("Go to diary"),
                message: .init("This action cannot be undone."),
                primaryButton: .cancel(.init("Cancel"), action: .send(.cancelSkipAlert)),
                secondaryButton: .destructive(.init("Skip"), action: .send(.skipAlertAction))
            )
        }
        
        store.send(.cancelSkipAlert) {
            $0.skipAlert = nil
        }
        
        store.send(.skipAlertButtonTapped) {
            $0.skipAlert = .init(
                title: .init("Go to diary"),
                message: .init("This action cannot be undone."),
                primaryButton: .cancel(.init("Cancel"), action: .send(.cancelSkipAlert)),
                secondaryButton: .destructive(.init("Skip"), action: .send(.skipAlertAction))
            )
        }
        
        store.send(.skipAlertAction) {
            $0.skipAlert = nil
            XCTAssertTrue(setOnBoardingShownCalled)
        }
    }
}
