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
                .onOpenURL { url in
                    appDelegate.process(url: url)
                }
                .onChange(of: scenePhase) { newPhase in
                    appDelegate.update(state: newPhase)
                }
        }
    }
}
