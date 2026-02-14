import Foundation
import Models
import Dependencies
import DependenciesMacros

extension DependencyValues {
  public var localAuthenticationClient: LocalAuthenticationClient {
    get { self[LocalAuthenticationClient.self] }
    set { self[LocalAuthenticationClient.self] = newValue }
  }
}

@DependencyClient
public struct LocalAuthenticationClient: Sendable {
    public var determineType: @Sendable () async throws -> LocalAuthenticationType
    public var evaluate: @Sendable (String) async throws -> Bool
}
