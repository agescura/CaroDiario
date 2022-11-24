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
    public var requestReview: () -> Effect<Never, Never>
    
    public init(
        requestReview: @escaping () -> Effect<Never, Never>
    ) {
        self.requestReview = requestReview
    }
}
