//
//  Interface.swift
//  
//
//  Created by Albert Gil Escura on 6/8/21.
//

import Foundation
import ComposableArchitecture
import Models

public struct AVCaptureDeviceClient {
    public var authorizationStatus: () -> Effect<AuthorizedVideoStatus, Never>
    public var requestAccess: () -> Effect<Bool, Never>
    
    public init(
        authorizationStatus: @escaping () -> Effect<AuthorizedVideoStatus, Never>,
        requestAccess: @escaping () -> Effect<Bool, Never>
    ) {
        self.authorizationStatus = authorizationStatus
        self.requestAccess = requestAccess
    }
}
