//
//  Live.swift
//  
//
//  Created by Albert Gil Escura on 15/7/21.
//

import Foundation
import ComposableArchitecture
import LocalAuthenticationClient
import LocalAuthentication

extension LocalAuthenticationClient {
    
    public static var live: Self {
        let context = LAContext()
        var error: NSError?
        
        return Self(
            determineType: {
                var type = LocalAuthenticationClient.AuthenticationType.none
                guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                    return Effect(value: .none)
                }
                switch context.biometryType {
                case .touchID:
                    type = .touchId
                case .faceID:
                    type = .faceId
                default:
                    type = .none
                }
                return Effect(value: type)
            },
            evaluate: { reason in
                return .future { promise in
                    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                        promise(.success(success))
                    }
                }
            }
        )
    }
}
