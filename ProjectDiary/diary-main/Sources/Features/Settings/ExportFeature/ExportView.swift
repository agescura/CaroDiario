//
//  ExportView.swift
//
//  Created by Albert Gil Escura on 19/9/21.
//

import ComposableArchitecture
import SwiftUI
import Views
import Localizables
import UIApplicationClient
import PDFKitClient
import PDFPreviewFeature
import CoreDataClient
import FileClient
import Models

public struct ExportState: Equatable {
    var presentPreview = false
    var pdfPreviewState: PDFPreviewState?
    
    var pdf = Data()
    
    public init() {}
}

public enum ExportAction: Equatable {
    case processPDF
    case generatePDF([[Entry]])
    case presentActivityView(Data)
    
    case previewPDF
    case generatePreview([[Entry]])
    case presentPreviewView(Data)
    
    case presentPDFPreview(Bool)
    case pdfPreviewAction(PDFPreviewAction)
}

public struct ExportEnvironment {
    public let fileClient: FileClient
    public let applicationClient: UIApplicationClient
    public let pdfKitClient: PDFKitClient
    public let date: () -> Date
    
    public init(
        fileClient: FileClient,
        applicationClient: UIApplicationClient,
        pdfKitClient: PDFKitClient,
        date: @escaping () -> Date
    ) {
        self.fileClient = fileClient
        self.applicationClient = applicationClient
        self.pdfKitClient = pdfKitClient
        self.date = date
    }
}

public let exportReducer: Reducer<
    ExportState,
    ExportAction,
    ExportEnvironment
> = .combine(
    pdfPreviewReducer
        .optional()
        .pullback(
            state: \.pdfPreviewState,
            action: /ExportAction.pdfPreviewAction,
            environment: { _ in PDFPreviewEnvironment() }
        ),
        .init { state, action, environment in
            switch action {
            case .processPDF:
                return .none
                
            case let .generatePDF(entries):
                return environment.pdfKitClient.generatePDF(entries, environment.date())
                    .map(ExportAction.presentActivityView)
                
            case let .presentActivityView(file):
                return environment.applicationClient.share(file, .pdf)
                    .fireAndForget()
                
            case .previewPDF:
                return .none
                
            case let .generatePreview(entries):
                return environment.pdfKitClient.generatePDF(entries, environment.date())
                    .map(ExportAction.presentPreviewView)
                
            case let .presentPreviewView(file):
                state.pdf = file
                return Effect(value: .presentPDFPreview(true))
                
            case let .presentPDFPreview(value):
                state.presentPreview = value
                state.pdfPreviewState = value ? .init(pdfData: state.pdf) : nil
                return .none
                
            case .pdfPreviewAction(.dismiss):
                return Effect(value: .presentPDFPreview(false))
                
            case .pdfPreviewAction:
                return .none
            }
        }
)

public struct ExportView: View {
    let store: Store<ExportState, ExportAction>
    
    public init(
        store: Store<ExportState, ExportAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            Form {
                Section() {
                    HStack(spacing: 16) {
                        IconImageView(
                            systemName: "doc.text.magnifyingglass",
                            foregroundColor: .berryRed
                        )
                        
                        Text("PDF.Preview".localized)
                            .foregroundColor(.chambray)
                            .adaptiveFont(.latoRegular, size: 12)
                        Spacer()
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { viewStore.send(.previewPDF) }
                }
                
                Section() {
                    HStack(spacing: 16) {
                        IconImageView(
                            systemName: "square.and.arrow.up",
                            foregroundColor: .green
                        )
                        
                        Text("PDF.Share".localized)
                            .foregroundColor(.chambray)
                            .adaptiveFont(.latoRegular, size: 12)
                        Spacer()
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewStore.send(.processPDF)
                    }
                }
            }
            .fullScreenCover(
                isPresented: viewStore.binding(
                    get: \.presentPreview,
                    send: ExportAction.presentPDFPreview
                )
            ) {
                IfLetStore(
                    store.scope(
                        state: \.pdfPreviewState,
                        action: ExportAction.pdfPreviewAction
                    ),
                    then: PDFPreviewView.init(store:)
                )
            }
        }
        .navigationBarTitle("Settings.ExportPDF".localized)
    }
}
