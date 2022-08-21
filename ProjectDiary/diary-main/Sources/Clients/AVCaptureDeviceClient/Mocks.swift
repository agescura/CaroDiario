//
//  Mocks.swift
//  
//
//  Created by Albert Gil Escura on 6/8/21.
//

import Foundation

extension AVCaptureDeviceClient {
    public static let noop = Self(
        authorizationStatus: { .fireAndForget {} },
        requestAccess: { false }
    )
}
