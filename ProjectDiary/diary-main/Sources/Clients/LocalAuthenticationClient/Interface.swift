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
    public var determineType: () -> Effect<LocalAuthenticationType, Never>
    public var evaluate: (String) -> Effect<Bool, Never>
    
    public init(
        determineType: @escaping () -> Effect<LocalAuthenticationType, Never>,
        evaluate: @escaping (String) -> Effect<Bool, Never>
    ) {
        self.determineType = determineType
        self.evaluate = evaluate
    }
}
