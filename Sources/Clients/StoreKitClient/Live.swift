import Foundation
import StoreKit
import Dependencies

extension StoreKitClient: DependencyKey {
  public static var liveValue: StoreKitClient { .live }
}

extension StoreKitClient {
  public static var live: Self = {
    let windowScene = UIApplication.shared.connectedScenes
      .filter { $0.activationState == .foregroundActive }
      .compactMap { $0 as? UIWindowScene }
      .first
    
    return Self(
      requestReview: {
        guard let windowScene = windowScene else { return }
        await SKStoreReviewController.requestReview(in: windowScene)
      }
    )
  }()
}
