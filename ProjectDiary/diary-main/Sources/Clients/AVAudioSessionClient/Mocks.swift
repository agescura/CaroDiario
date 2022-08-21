//
//  Mocks.swift
//  
//
//  Created by Albert Gil Escura on 26/8/21.
//

import Foundation

extension AVAudioSessionClient {
    public static var noop = Self(
        recordPermission: { .notDetermined },
        requestRecordPermission: { false }
    )
}
