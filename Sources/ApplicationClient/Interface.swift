import Dependencies
import DependenciesMacros
import UIKit

extension DependencyValues {
  public var applicationClient: ApplicationClient {
    get { self[ApplicationClient.self] }
    set { self[ApplicationClient.self] = newValue }
  }
}

@DependencyClient
public struct ApplicationClient: Sendable {
  public var open: @Sendable (URL, [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Void
}
