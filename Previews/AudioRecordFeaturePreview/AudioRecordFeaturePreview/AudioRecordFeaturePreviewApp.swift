//
//  AudioRecordFeaturePreviewApp.swift
//  AudioRecordFeaturePreview
//
//  Created by Albert Gil Escura on 27/8/21.
//

import SwiftUI
import ComposableArchitecture
import AVAudioPlayerClientLive
import AVAudioSessionClientLive
import AVAudioRecorderClientLive
import AudioRecordFeature
import UIApplicationClientLive
import FileClientLive

@main
struct AudioRecordFeaturePreviewApp: App {
    var body: some Scene {
        WindowGroup {
            AudioRecordView(
                store: .init(
                    initialState: .init(),
                    reducer: audioRecordReducer,
                    environment: .init(
                        fileClient: .live,
                        applicationClient: .live,
                        avAudioSessionClient: .live,
                        avAudioPlayerClient: .live,
                        avAudioRecorderClient: .live,
                        mainQueue: .main,
                        mainRunLoop: .main,
                        uuid: UUID.init
                    )
                )
            )
        }
    }
}
