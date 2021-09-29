//
//  Live.swift  
//
//  Created by Albert Gil Escura on 18/9/21.
//

import Foundation
import ComposableArchitecture
import StoreKitClient
import StoreKit

extension StoreKitClient {
    
    public static var live = Self(
        requestReview: {
            .fireAndForget {
                guard let windowScene = UIApplication.shared.windows.first?.windowScene else { return }
                
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    )
}
