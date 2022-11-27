import Foundation
import AVFoundation
import ComposableArchitecture
import Dependencies

extension AVCaptureDeviceClient: DependencyKey {
  public static var liveValue: AVCaptureDeviceClient { .live }
}

extension AVCaptureDeviceClient {
  public static let live = Self(
    authorizationStatus: {
      await withCheckedContinuation { continuation in
        if !deviceHasCamera {
          return continuation.resume(with: .success(.restricted))
        }
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .notDetermined:
          return continuation.resume(with: .success(.notDetermined))
        case .authorized:
          return continuation.resume(with: .success(.authorized))
        case .restricted, .denied:
          fallthrough
        @unknown default:
          return continuation.resume(with: .success(.denied))
        }
      }
    },
    requestAccess: {
      await AVCaptureDevice.requestAccess(for: AVMediaType.video)
    }
  )
  
  private static var deviceHasCamera: Bool {
    AVCaptureDevice.DiscoverySession(
      deviceTypes: [.builtInWideAngleCamera],
      mediaType: .video,
      position: .unspecified
    ).devices.count > 0
  }
}
