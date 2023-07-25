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
            if !deviceHasCamera {
                return .restricted
            }
            switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
            case .notDetermined:
                return .notDetermined
            case .authorized:
                return .authorized
            case .restricted, .denied:
                fallthrough
            @unknown default:
                return .denied
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
