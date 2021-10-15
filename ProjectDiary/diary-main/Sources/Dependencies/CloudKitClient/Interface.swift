//
//  Interface.swift
//
//  Created by Albert Gil Escura on 15/10/21.
//

import ComposableArchitecture

public struct CloudKitClient {
    public var isCloudAvailable: () -> Effect<Bool, Never>
    public var cloudStatus: () -> Effect<CloudKitClient.CloudStatus, Never>
    
    public init(
        isCloudAvailable: @escaping () -> Effect<Bool, Never>,
        cloudStatus: @escaping () -> Effect<CloudKitClient.CloudStatus, Never>
    ) {
        self.isCloudAvailable = isCloudAvailable
        self.cloudStatus = cloudStatus
    }
    
    public enum CloudStatus {
        case available
        case noAccount
        case restricted
        case couldNotDetermine
    }
}
