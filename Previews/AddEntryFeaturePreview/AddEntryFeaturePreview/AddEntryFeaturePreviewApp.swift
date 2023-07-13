//
//  AddEntryFeaturePreviewApp.swift
//  AddEntryFeaturePreview
//
//  Created by Albert Gil Escura on 4/8/21.
//

import SwiftUI
import ComposableArchitecture
import AddEntryFeature
import Styles
import CoreDataClientLive
import FileClientLive
import AVCaptureDeviceClientLive
import UIApplicationClientLive
import AVAudioRecorderClientLive
import AVAudioSessionClientLive
import AVAudioPlayerClientLive
import AVAssetClientLive

@main
struct AddEntryFeaturePreviewApp: App {
    
    init() {
        registerFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            AddEntryView(
                store: .init(
                    initialState: .init(entry: .init(id: .init(), date: .init(), startDay: .init(), text: .init(id: .init(), message: "", lastUpdated: .init()))),
                    reducer: addEntryReducer,
                    environment: .init(
                        fileClient: .live,
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
