//
//  PDFPreviewView.swift 
//
//  Created by Albert Gil Escura on 19/9/21.
//

import ComposableArchitecture
import SwiftUI
import Views
import Localizables
import UIApplicationClient
import PDFKitClient

public struct PDFPreviewState: Equatable {
    let pdfData: Data
    
    public init(
        pdfData: Data
    ) {
        self.pdfData = pdfData
    }
}

public enum PDFPreviewAction: Equatable {
    case dismiss
}

public struct PDFPreviewEnvironment {
    public init(
    ) {
    }
}

public let pdfPreviewReducer = Reducer<PDFPreviewState, PDFPreviewAction, PDFPreviewEnvironment> { state, action, environment in
    switch action {
    case .dismiss:
        return .none
    }
}

public struct PDFPreviewView: View {
    let store: Store<PDFPreviewState, PDFPreviewAction>
    
    public init(
        store: Store<PDFPreviewState, PDFPreviewAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                HStack(spacing: 16) {
                    Spacer()
                    
                    Button(action: {
                        viewStore.send(.dismiss)
                    }, label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.chambray)
                    })
                }
                .padding()
                
                PDFViewRepresentable(data: viewStore.pdfData)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}
