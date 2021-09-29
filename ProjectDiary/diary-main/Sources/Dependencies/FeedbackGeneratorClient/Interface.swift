//
//  Interface.swift
//  
//
//  Created by Albert Gil Escura on 8/8/21.
//

import ComposableArchitecture

public struct FeedbackGeneratorClient {
    public var prepare: () -> Effect<Never, Never>
    public var selectionChanged: () -> Effect<Never, Never>
    
    public init(
        prepare: @escaping () -> Effect<Never, Never>,
        selectionChanged: @escaping () -> Effect<Never, Never>
    ) {
        self.prepare = prepare
        self.selectionChanged = selectionChanged
    }
}
