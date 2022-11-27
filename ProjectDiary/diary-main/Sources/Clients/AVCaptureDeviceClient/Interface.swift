import Foundation
import ComposableArchitecture
import Models
import Dependencies

extension DependencyValues {
  public var avCaptureDeviceClient: AVCaptureDeviceClient {
    get { self[AVCaptureDeviceClient.self] }
    set { self[AVCaptureDeviceClient.self] = newValue }
  }
}

public struct AVCaptureDeviceClient {
    public var authorizationStatus: @Sendable () async -> AuthorizedVideoStatus
    public var requestAccess: @Sendable () async -> Bool
    
    public init(
        authorizationStatus: @escaping @Sendable () async -> AuthorizedVideoStatus,
        requestAccess: @escaping @Sendable () async -> Bool
    ) {
        self.authorizationStatus = authorizationStatus
        self.requestAccess = requestAccess
    }
}
