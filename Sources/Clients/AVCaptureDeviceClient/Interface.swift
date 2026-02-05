import Foundation
import Models
import Dependencies
import DependenciesMacros

extension DependencyValues {
  public var avCaptureDeviceClient: AVCaptureDeviceClient {
    get { self[AVCaptureDeviceClient.self] }
    set { self[AVCaptureDeviceClient.self] = newValue }
  }
}

@DependencyClient
public struct AVCaptureDeviceClient: Sendable {
    public var authorizationStatus: @Sendable () async throws -> AuthorizedVideoStatus
    public var requestAccess: @Sendable () async throws -> Bool
}
