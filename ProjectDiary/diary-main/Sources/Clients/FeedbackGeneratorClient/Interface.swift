//
//  Interface.swift
//  
//
//  Created by Albert Gil Escura on 8/8/21.
//

import ComposableArchitecture

public struct FeedbackGeneratorClient {
    public var prepare: () async -> Void
    public var selectionChanged: () async -> Void
    
    public init(
        prepare: @escaping () async -> Void,
        selectionChanged: @escaping () async -> Void
    ) {
        self.prepare = prepare
        self.selectionChanged = selectionChanged
    }
}
