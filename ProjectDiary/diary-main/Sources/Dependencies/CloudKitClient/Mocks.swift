//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 15/10/21.
//

import ComposableArchitecture

extension CloudKitClient {
    public static let noop = Self(
        isCloudAvailable: { .fireAndForget {} },
        cloudStatus: { .fireAndForget {} }
    )
}
