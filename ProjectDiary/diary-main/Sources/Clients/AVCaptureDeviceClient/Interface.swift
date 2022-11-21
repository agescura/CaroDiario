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
    public var authorizationStatus: () -> Effect<AuthorizedVideoStatus, Never>
    public var requestAccess: () async -> Bool
    
    public init(
        authorizationStatus: @escaping () -> Effect<AuthorizedVideoStatus, Never>,
        requestAccess: @escaping () async -> Bool
    ) {
        self.authorizationStatus = authorizationStatus
        self.requestAccess = requestAccess
    }
}
