//
//  EntriesFeaturePreviewApp.swift
//  EntriesFeaturePreview
//
//  Created by Albert Gil Escura on 9/8/21.
//

import SwiftUI
import ComposableArchitecture
import EntriesFeature
import CoreDataClientLive
import FileClientLive
import UserDefaultsClientLive
import AVCaptureDeviceClientLive
import UIApplicationClientLive
import AVAudioSessionClientLive
import AVAudioPlayerClientLive
import AVAudioRecorderClientLive
import AVAssetClientLive

@main
struct EntriesFeaturePreviewApp: App {
    var body: some Scene {
        WindowGroup {
            EntriesView(
                store: .init(
                    initialState: .init(entries: []),
                    reducer: entriesReducer,
                    environment: .init(
                        coreDataClient: .live,
                        fileClient: .live,
                        userDefaultsClient: .live(userDefaults:)(),
                        avCaptureDeviceClient: .live,
                        applicationClient: .live,
                        avAudioSessionClient: .live,
                        avAudioPlayerClient: .live,
                        avAudioRecorderClient: .live,
                        avAssetClient: .live,
                        mainQueue: .main,
                        backgroundQueue: DispatchQueue(label: "background-queue").eraseToAnyScheduler(),
                        date: Date.init,
                        uuid: UUID.init
                    )
                )
            )
        }
    }
}
