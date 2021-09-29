//
//  Mocks.swift
//  
//
//  Created by Albert Gil Escura on 8/8/21.
//

import Foundation

extension FeedbackGeneratorClient {
    public static let noop = Self(
        prepare: { .none },
        selectionChanged: { .none }
    )
}
