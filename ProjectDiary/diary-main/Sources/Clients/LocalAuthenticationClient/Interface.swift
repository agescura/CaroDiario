import Foundation
import ComposableArchitecture
import Models
import Dependencies

extension DependencyValues {
  public var localAuthenticationClient: LocalAuthenticationClient {
    get { self[LocalAuthenticationClient.self] }
    set { self[LocalAuthenticationClient.self] = newValue }
  }
}

public struct LocalAuthenticationClient {
    public var determineType: @Sendable () async -> LocalAuthenticationType
    public var evaluate: @Sendable (String) async -> Bool
    
    public init(
        determineType: @escaping @Sendable () async -> LocalAuthenticationType,
        evaluate: @escaping @Sendable (String) async -> Bool
    ) {
        self.determineType = determineType
        self.evaluate = evaluate
    }
}
