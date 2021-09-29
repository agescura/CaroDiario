//
//  Mocks.swift
//  
//
//  Created by Albert Gil Escura on 5/9/21.
//

import ComposableArchitecture

extension AVAssetClient {
    static let noop = Self(
        commonMetadata: { _ in .fireAndForget {} }
    )
}
