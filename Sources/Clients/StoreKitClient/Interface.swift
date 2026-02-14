import Foundation
import Dependencies
import DependenciesMacros

extension DependencyValues {
  public var storeKitClient: StoreKitClient {
    get { self[StoreKitClient.self] }
    set { self[StoreKitClient.self] = newValue }
  }
}

@DependencyClient
public struct StoreKitClient: Sendable {
    public var requestReview: @Sendable () async throws -> Void
}
