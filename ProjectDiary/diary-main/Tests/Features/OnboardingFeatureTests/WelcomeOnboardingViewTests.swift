import XCTest
@testable import OnboardingFeature
import ComposableArchitecture
import SwiftUI
import UserDefaultsClient

class WelcomeOnboardingViewTests: XCTestCase {
    
//    func testWelcomeOnBoardingViewHappyPath() {
//        let store = TestStore(
//            initialState: WelcomeOnBoardingState(),
//            reducer: welcomeOnBoardingReducer,
//            environment: WelcomeOnBoardingEnvironment(
//                userDefaultsClient: .noop,
//                feedbackGeneratorClient: .noop,
//                mainQueue: .immediate,
//                backgroundQueue: .immediate,
//                date: Date.init,
//                uuid: UUID.init
//            )
//        )
//        
//        store.send(.navigationPrivacyOnBoarding(true)) {
//            $0.privacyOnBoardingState = .init(
//                styleOnBoardingState: nil,
//                navigateStyleOnBoarding: false
//            )
//            $0.navigatePrivacyOnBoarding = true
//        }
//    }
//    
//    func testWelcomeOnBoardingViewSkipAlertFlow() {
//        var setOnBoardingShownCalled = false
//        
//        let store = TestStore(
//            initialState: WelcomeOnBoardingState(),
//            reducer: welcomeOnBoardingReducer,
//            environment: WelcomeOnBoardingEnvironment(
//                userDefaultsClient: UserDefaultsClient(
//                    boolForKey: { _ in false },
//                    setBool: { value, key in
//                        if key == "hasShownOnboardingKey" && value == true {
//                            setOnBoardingShownCalled = true
//                        }
//                        return .run { _ in}
//                    },
//                    stringForKey: { _ in nil },
//                    setString: { _, _ in .fireAndForget {} },
//                    intForKey: { _ in nil  },
//                    setInt: { _, _  in .fireAndForget {} },
//                    dateForKey: { _ in nil },
//                    setDate: { _, _  in .fireAndForget {} },
//                    remove: { _ in .fireAndForget {} }
//                ),
//                feedbackGeneratorClient: .noop,
//                mainQueue: .immediate,
//                backgroundQueue: .immediate,
//                date: Date.init,
//                uuid: UUID.init
//            )
//        )
//        
//        store.send(.skipAlertButtonTapped) {
//            $0.skipAlert = .init(
//                title: .init("Go to diary"),
//                message: .init("This action cannot be undone."),
//                primaryButton: .cancel(.init("Cancel"), action: .send(.cancelSkipAlert)),
//                secondaryButton: .destructive(.init("Skip"), action: .send(.skipAlertAction))
//            )
//        }
//        
//        store.send(.cancelSkipAlert) {
//            $0.skipAlert = nil
//        }
//        
//        store.send(.skipAlertButtonTapped) {
//            $0.skipAlert = .init(
//                title: .init("Go to diary"),
//                message: .init("This action cannot be undone."),
//                primaryButton: .cancel(.init("Cancel"), action: .send(.cancelSkipAlert)),
//                secondaryButton: .destructive(.init("Skip"), action: .send(.skipAlertAction))
//            )
//        }
//        
//        store.send(.skipAlertAction) {
//            $0.skipAlert = nil
//            XCTAssertTrue(setOnBoardingShownCalled)
//        }
//    }
}
