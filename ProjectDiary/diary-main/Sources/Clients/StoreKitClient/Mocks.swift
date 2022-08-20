//
//  Mocks.swift  
//
//  Created by Albert Gil Escura on 18/9/21.
//

import Foundation
import ComposableArchitecture

extension StoreKitClient {
  public static let noop = Self(
    requestReview: { .none }
  )
}
