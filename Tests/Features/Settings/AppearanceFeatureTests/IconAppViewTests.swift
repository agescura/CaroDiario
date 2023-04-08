//
//  IconAppViewTests.swift
//  
//
//  Created by Albert Gil Escura on 22/8/21.
//

import XCTest
@testable import AppearanceFeature
import ComposableArchitecture

@MainActor
class IconAppViewTests: XCTestCase {
  
  func testIconAppHappyPath() async {
    var selectionChangedCalled = false
    
    let store = TestStore(
      initialState: .init(iconAppType: .light),
      reducer: IconApp()
    )
    store.dependencies.feedbackGeneratorClient.selectionChanged = {
      selectionChangedCalled = true
    }
    store.dependencies.applicationClient.setAlternateIconName = { _ in }
    
    await store.send(.iconAppChanged(.dark)) {
      $0.iconAppType = .dark
      XCTAssertTrue(selectionChangedCalled)
      selectionChangedCalled = false
    }
    
    await store.send(.iconAppChanged(.light)) {
      $0.iconAppType = .light
      XCTAssertTrue(selectionChangedCalled)
    }
  }
    
    func testSnapshot() {
        let store = Store(
            initialState: .init(iconAppType: .light),
            reducer: IconApp()
        )
        let view = IconAppView(store: store)
        
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        
        let viewStore = ViewStore(
            store.scope(state: { _ in () }),
            removeDuplicates: ==
        )
        
        assertSnapshot(matching: vc, as: .image)
        
        viewStore.send(.iconAppChanged(.dark))
        assertSnapshot(matching: vc, as: .image)
        
        viewStore.send(.iconAppChanged(.light))
        assertSnapshot(matching: vc, as: .image)
    }
}

import SwiftUI
import SnapshotTesting
