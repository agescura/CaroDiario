//
//  AudioPickerView.swift
//
//  Created by Albert Gil Escura on 24/8/21.
//

import SwiftUI
import MediaPlayer

public enum MediaPickerSourceType: Int, Equatable {
    case audio
}

public enum MediaPickerResponseType: Equatable {
    case audio(URL)
}

public struct AudioPicker: UIViewControllerRepresentable {
    public var onImport: (MediaPickerResponseType) -> Void
    @Environment(\.presentationMode) private var presentationMode
    
    public init(
        onImport: @escaping (MediaPickerResponseType) -> Void
    ) {
        self.onImport = onImport
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let supportedTypes: [UTType] = [UTType.audio]
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        controller.allowsMultipleSelection = false
        controller.delegate = context.coordinator
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}

extension AudioPicker {
    public final class Coordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
        private let picker: AudioPicker
        
        init(_ picker: AudioPicker) {
            self.picker = picker
            super.init()
        }
        
        public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {}
        
        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                picker.onImport(.audio(url))
            }
        }
    }
}
