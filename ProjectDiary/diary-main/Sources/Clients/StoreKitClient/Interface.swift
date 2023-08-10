import Foundation
import Dependencies

extension DependencyValues {
  public var storeKitClient: StoreKitClient {
    get { self[StoreKitClient.self] }
    set { self[StoreKitClient.self] = newValue }
  }
}

public struct StoreKitClient {
    public var requestReview: () -> Void
    
    public init(
        requestReview: @escaping () -> Void
    ) {
        self.requestReview = requestReview
    }
}
