//
//  Live.swift
//  
//
//  Created by Albert Gil Escura on 15/7/21.
//

import Foundation
import ComposableArchitecture
import LocalAuthentication
import Models
import Dependencies

extension LocalAuthenticationClient: DependencyKey {
  public static var liveValue: LocalAuthenticationClient { .live }
}

extension LocalAuthenticationClient {
    
    public static var live: Self {
        var context = LAContext()
        var error: NSError?
        
        return Self(
            determineType: {
                var type = LocalAuthenticationType.none
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
                    context = LAContext()
                    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                        promise(.success(success))
                    }
                }
            }
        )
    }
}
