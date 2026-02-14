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
  public var openSettings: @Sendable () async -> Void
  public var setAlternateIconName: @Sendable (String?) async throws -> Void
  public var setUserInterfaceStyle: @Sendable (UIUserInterfaceStyle) async -> Void
  public var share: @MainActor @Sendable (Any, PopoverPosition) throws -> Void
  
  public enum PopoverPosition: Sendable {
      case text
      case attachment
      case pdf
    }
}
