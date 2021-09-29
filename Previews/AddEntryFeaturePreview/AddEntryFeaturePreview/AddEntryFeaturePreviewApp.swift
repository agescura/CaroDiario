//
//  AddEntryFeaturePreviewApp.swift
//  AddEntryFeaturePreview
//
//  Created by Albert Gil Escura on 4/8/21.
//

import SwiftUI
import ComposableArchitecture
import AddEntryFeature
import SharedStyles
import CoreDataClientLive
import FileClientLive
import AVCaptureDeviceClientLive
import UIApplicationClientLive
import AVAudioRecorderClientLive
import AVAudioSessionClientLive
import AVAudioPlayerClientLive

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
                        coreDataClient: .live,
                        fileClient: .live,
                        avCaptureDeviceClient: .live,
                        applicationClient: .live,
                        avAudioSessionClient: .live,
                        avAudioPlayerClient: .live,
                        avAudioRecorderClient: .live,
                        mainQueue: .main,
                        backgroundQueue: DispatchQueue(label: "background-queue").eraseToAnyScheduler(),
                        mainRunLoop: .main,
                        uuid: UUID.init
                    )
                )
            )
        }
    }
}
