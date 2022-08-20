//
//  ProjectDiaryApp.swift
//  ProjectDiary
//
//  Created by Albert Gil Escura on 24/6/21.
//

import SwiftUI
import ComposableArchitecture
import RootFeature

@main
struct ProjectDiaryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {            
            RootView(store: appDelegate.store)
                .onOpenURL(perform: appDelegate.process(url:))
                .onChange(
                    of: self.scenePhase,
                    perform: appDelegate.update(state:)
                )
        }
    }
}
