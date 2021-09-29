//
//  Interface.swift  
//
//  Created by Albert Gil Escura on 18/9/21.
//

import Foundation
import ComposableArchitecture

public struct StoreKitClient {
    public var requestReview: () -> Effect<Never, Never>
    
    public init(
        requestReview: @escaping () -> Effect<Never, Never>
    ) {
        self.requestReview = requestReview
    }
}
