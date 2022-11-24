import Foundation
import ComposableArchitecture
import StoreKit
import Dependencies

extension StoreKitClient: DependencyKey {
  public static var liveValue: StoreKitClient { .live }
}

extension StoreKitClient {
    public static var live = Self(
        requestReview: {
            .fireAndForget {
                let windowScene = UIApplication.shared.connectedScenes
                    .filter { $0.activationState == .foregroundActive }
                    .compactMap { $0 as? UIWindowScene }
                    .first
                guard let windowScene = windowScene else { return }
                
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    )
}
