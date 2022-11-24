import Foundation
import ComposableArchitecture
import Dependencies

extension DependencyValues {
  public var storeKitClient: StoreKitClient {
    get { self[StoreKitClient.self] }
    set { self[StoreKitClient.self] = newValue }
  }
}

public struct StoreKitClient {
    public var requestReview: @Sendable () async -> Void
    
    public init(
        requestReview: @escaping @Sendable () async -> Void
    ) {
        self.requestReview = requestReview
    }
}
