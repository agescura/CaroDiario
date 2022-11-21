//
//  OnBoardingFeatureTests.swift
//  
//
//  Created by Albert Gil Escura on 11/7/21.
//

import XCTest
@testable import OnboardingFeature
import ComposableArchitecture
import SwiftUI
import UserDefaultsClient
import EntriesFeature

@MainActor
class OnBoardingFeatureTests: XCTestCase {
    
    private let id1 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    private let id2 = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    private let id3 = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
    private let date = Date.init(timeIntervalSince1970: 1629486993)

    lazy var fakeEntries: IdentifiedArrayOf<DayEntriesRowState> = [
        .init(dayEntry: .init(entry: [
            .init(id: id1, date: date, startDay: date, text: .init(id: id1, message: "Entries.FakeEntry.FirstMessage".localized, lastUpdated: date)),
            .init(id: id2, date: date, startDay: date, text: .init(id: id2, message: "Entries.FakeEntry.SecondMessage".localized, lastUpdated: date))
        ], style: .rectangle, layout: .horizontal), id: id3)
    ]
    
    func testOnBoardingNavigatingAppearanceAndHappyPath() async {
        var setOnBoardingShownCalled = false
        let store = TestStore(
            initialState: WelcomeOnBoardingState(),
            reducer: welcomeOnBoardingReducer,
            environment: WelcomeOnBoardingEnvironment(
                userDefaultsClient: UserDefaultsClient(
                    boolForKey: { _ in false },
                    setBool: { value, key in
                        if key == "hasShownOnboardingKey" {
                            setOnBoardingShownCalled = true
                            XCTAssertTrue(value)
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
        
        await store.send(.navigationPrivacyOnBoarding(true)) {
            $0.privacyOnBoardingState = .init(
                styleOnBoardingState: nil,
                navigateStyleOnBoarding: false
            )
            $0.navigatePrivacyOnBoarding = true
        }
        
        await store.send(.privacyOnBoardingAction(.navigationStyleOnBoarding(true))) {
            $0.privacyOnBoardingState?.navigateStyleOnBoarding = true
            $0.privacyOnBoardingState = .init(
                styleOnBoardingState: .init(
                    styleType: .rectangle, layoutType: .horizontal,
                    entries: self.fakeEntries
                ),
                navigateStyleOnBoarding: false
            )
            $0.navigatePrivacyOnBoarding = true
            $0.privacyOnBoardingState?.navigateStyleOnBoarding = true
        }
        
        await store.send(.privacyOnBoardingAction(.styleOnBoardingAction(.navigationLayoutOnBoarding(true)))) {
            $0.privacyOnBoardingState?.navigateStyleOnBoarding = true
            $0.privacyOnBoardingState = .init(
                styleOnBoardingState: .init(
                    styleType: .rectangle, layoutType: .horizontal,
                    entries: self.fakeEntries,
                    layoutOnBoardingState: .init(
                        styleType: .rectangle, layoutType: .horizontal,
                        entries: self.fakeEntries
                    ),
                    navigateLayoutOnBoarding: true
                ),
                navigateStyleOnBoarding: false
            )
            $0.navigatePrivacyOnBoarding = true
            $0.privacyOnBoardingState?.navigateStyleOnBoarding = true
        }
        
        await store.send(.privacyOnBoardingAction(.styleOnBoardingAction(.layoutOnBoardingAction(.navigateThemeOnBoarding(true))))) {
            $0.privacyOnBoardingState?.navigateStyleOnBoarding = true
            $0.privacyOnBoardingState = .init(
                styleOnBoardingState: .init(
                    styleType: .rectangle, layoutType: .horizontal,
                    entries: self.fakeEntries,
                    layoutOnBoardingState: .init(
                        styleType: .rectangle, layoutType: .horizontal,
                        entries: self.fakeEntries,
                        themeOnBoardingState: .init(
                            themeType: .system,
                            entries: self.fakeEntries
                        ),
                        navigateThemeOnBoarding: true
                    ),
                    navigateLayoutOnBoarding: true
                ),
                navigateStyleOnBoarding: false
            )
            $0.navigatePrivacyOnBoarding = true
            $0.privacyOnBoardingState?.navigateStyleOnBoarding = true
        }
        
        await store.send(.privacyOnBoardingAction(.styleOnBoardingAction(.layoutOnBoardingAction(.themeOnBoardingAction(.startButtonTapped)))))
    }
}























































































