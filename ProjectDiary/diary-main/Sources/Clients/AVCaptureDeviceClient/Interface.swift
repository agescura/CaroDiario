import Foundation
import Models
import Dependencies

extension DependencyValues {
  public var avCaptureDeviceClient: AVCaptureDeviceClient {
    get { self[AVCaptureDeviceClient.self] }
    set { self[AVCaptureDeviceClient.self] = newValue }
  }
}

public struct AVCaptureDeviceClient {
    public var authorizationStatus: () async -> AuthorizedVideoStatus
    public var requestAccess: () async -> Bool
    
    public init(
        authorizationStatus: @escaping () async -> AuthorizedVideoStatus,
        requestAccess: @escaping () async -> Bool
    ) {
        self.authorizationStatus = authorizationStatus
        self.requestAccess = requestAccess
    }
}
