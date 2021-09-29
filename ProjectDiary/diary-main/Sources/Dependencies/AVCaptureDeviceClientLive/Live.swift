//
//  Live.swift
//  
//
//  Created by Albert Gil Escura on 6/8/21.
//

import Foundation
import AVFoundation
import AVCaptureDeviceClient
import ComposableArchitecture

extension AVCaptureDeviceClient {
    public static let live = Self(
        authorizationStatus: {
            if !deviceHasCamera {
                return Effect(value: .restricted)
            }
            switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
            case .notDetermined:
                return Effect(value: .notDetermined)
            case .authorized:
                return Effect(value: .authorized)
            case .restricted, .denied:
                fallthrough
            @unknown default:
                return Effect(value: .denied)
            }
        },
        requestAccess: {
            .future { promise in
                AVCaptureDevice.requestAccess(for: AVMediaType.video) {  granted in
                    promise(.success(granted))
                }
            }
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
