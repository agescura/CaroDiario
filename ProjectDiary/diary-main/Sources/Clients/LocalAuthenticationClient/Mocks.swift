//
//  Mocks.swift
//  
//
//  Created by Albert Gil Escura on 15/7/21.
//

import Foundation
import ComposableArchitecture

extension LocalAuthenticationClient {
    
    public static let noop = Self(
        determineType: { Effect(value: .none) },
        evaluate: { _ in .fireAndForget {} }
    )
    
    public static let faceIdSuccess = Self(
        determineType: {
            Effect(value: .faceId)
        },
        evaluate: { _ in
            Effect(value: true)
        }
    )
    
    public static let faceIdFailed = Self(
        determineType: {
            Effect(value: .faceId)
        },
        evaluate: { _ in
            Effect(value: true)
        }
    )
    
    public static let touchIdSuccess = Self(
        determineType: {
            Effect(value: .touchId)
        },
        evaluate: { _ in
            Effect(value: false)
        }
    )
}
