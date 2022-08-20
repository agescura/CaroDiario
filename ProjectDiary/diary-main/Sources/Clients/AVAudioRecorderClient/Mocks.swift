//
//  Mocks.swift
//  
//
//  Created by Albert Gil Escura on 26/8/21.
//

import ComposableArchitecture

extension AVAudioRecorderClient {
    public static var noop = Self(
        create: { _ in .fireAndForget {} },
        destroy: { _ in .fireAndForget {} },
        record: { _, _ in .fireAndForget {} },
        stop: { _ in .fireAndForget {} }
    )
}
