//
//  Mocks.swift
//  
//
//  Created by Albert Gil Escura on 26/8/21.
//

import ComposableArchitecture

extension AVAudioPlayerClient {
    
    public static var noop = Self(
        create: { _, _ in .fireAndForget {} },
        destroy: { _ in .fireAndForget {} },
        duration: { _ in .fireAndForget {} },
        play: { _ in .fireAndForget {} },
        pause: { _ in .fireAndForget {} },
        stop: { _ in .fireAndForget {} },
        isPlaying: { _ in .fireAndForget {} },
        currentTime: { _ in .fireAndForget {} },
        setCurrentTime: { _, _ in .fireAndForget {} }
    )
}
