//
//  StyleOnboardingViewTests.swift
//  
//
//  Created by Albert Gil Escura on 21/8/21.
//

import XCTest
@testable import OnBoardingFeature
import ComposableArchitecture
import SwiftUI
import EntriesFeature
import UserDefaultsClient

class StyleOnboardingViewTests: XCTestCase {
    
    private let id1 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    private let id2 = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    private let id3 = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
    private let date = Date.init(timeIntervalSince1970: 1629486993)

    lazy var fakeEntries: IdentifiedArrayOf<DayEntriesRowState> = [
        .init(dayEntry: .init(entry: [
            .init(id: id1, date: date, startDay: date, text: .init(id: id1, message: "Entries.FakeEntry.FirstMessage".localized, lastUpdated: date)),
            .init(id: id2, date: date, startDay: date, text: .init(id: id2, message: "Entries.FakeEntry.SecondMessage".localized, lastUpdated: date))
        ], style: .rounded, layout: .horizontal), id: id3)
    ]
    
    func testStyleOnBoardingViewHappyPath() {
        let store = TestStore(
            initialState: StyleOnBoardingState(styleType: .rectangle, layoutType: .horizontal, entries: []),
            reducer: styleOnBoardingReducer,
            environment: StyleOnBoardingEnvironment(
                userDefaultsClient: .noop,
                feedbackGeneratorClient: .noop,
                mainQueue: .immediate,
                backgroundQueue: .immediate,
                mainRunLoop: .immediate,
                uuid: UUID.init,
                setUserInterfaceStyle: { _ in .none }
            )
        )
        
        store.send(.styleChanged(.rounded)) {
            $0.styleType = .rounded
            $0.entries = self.fakeEntries
        }
        
        store.send(.navigationLayoutOnBoarding(true)) {
            $0.layoutOnBoardingState = .init(
                styleType: .rounded, layoutType: .horizontal,
                entries: self.fakeEntries,
                skipAlert: nil,
                themeOnBoardingState: nil,
                navigateThemeOnBoarding: false
            )
            $0.navigateLayoutOnBoarding = true
        }
    }
    
    func testStyleOnBoardingViewSkipAlertFlow() {
        var setOnBoardingShownCalled = false
        
        let store = TestStore(
            initialState: StyleOnBoardingState(styleType: .rectangle, layoutType: .horizontal, entries: []),
            reducer: styleOnBoardingReducer,
            environment: StyleOnBoardingEnvironment(
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
                mainRunLoop: .immediate,
                uuid: UUID.init,
                setUserInterfaceStyle: { _ in .none }
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
