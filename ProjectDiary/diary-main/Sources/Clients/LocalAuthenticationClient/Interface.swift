//
//  Interface.swift  
//
//  Created by Albert Gil Escura on 15/7/21.
//

import Foundation
import ComposableArchitecture
import Models

public struct LocalAuthenticationClient {
    public var determineType: () -> Effect<LocalAuthenticationType, Never>
    public var evaluate: (String) -> Effect<Bool, Never>
    
    public init(
        determineType: @escaping () -> Effect<LocalAuthenticationType, Never>,
        evaluate: @escaping (String) -> Effect<Bool, Never>
    ) {
        self.determineType = determineType
        self.evaluate = evaluate
    }
}
