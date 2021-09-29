//
//  Interface.swift  
//
//  Created by Albert Gil Escura on 15/7/21.
//

import Foundation
import ComposableArchitecture

public struct LocalAuthenticationClient {
    public var determineType: () -> Effect<AuthenticationType, Never>
    public var evaluate: (String) -> Effect<Bool, Never>
    
    public init(
        determineType: @escaping () -> Effect<LocalAuthenticationClient.AuthenticationType, Never>,
        evaluate: @escaping (String) -> Effect<Bool, Never>
    ) {
        self.determineType = determineType
        self.evaluate = evaluate
    }
    
    public enum AuthenticationType {
        case faceId
        case touchId
        case none
        
        public var rawValue: String {
            switch self {
            case .faceId:
                return "Face ID"
            case .touchId:
                return "Touch ID"
            case .none:
                return ""
            }
        }
    }
}
