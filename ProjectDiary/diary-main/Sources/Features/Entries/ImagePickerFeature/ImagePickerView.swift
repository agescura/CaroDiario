import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers

public enum PickerSourceType: Int, Equatable {
    case photoAlbum
    case camera
}

extension PickerSourceType {
    var sourceType: UIImagePickerController.SourceType {
        switch self {
        case .photoAlbum:
            return .photoLibrary
        case .camera:
            return .camera
        }
    }
}

public enum PickerResponseType: Equatable {
    case image(UIImage)
    case video(URL)
}

public struct ImagePicker: UIViewControllerRepresentable {
    public var onImport: (PickerResponseType) -> Void
    @Environment(\.presentationMode) private var presentationMode
    
    public var type: PickerSourceType
    
    public init(
        type: PickerSourceType,
        onImport: @escaping (PickerResponseType) -> Void
    ) {
        self.type = type
        self.onImport = onImport
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = type.sourceType
        controller.allowsEditing = false
        controller.mediaTypes = [
            UTType.image.identifier as String,
            UTType.movie.identifier as String
        ]
        controller.delegate = context.coordinator
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

extension ImagePicker {
    public final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        init(_ picker: ImagePicker) {
            self.picker = picker
            super.init()
        }
        
        public func imagePickerController(
            _ controller: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                picker.onImport(.image(image))
            }
            if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                picker.onImport(.video(videoUrl))
            }
            picker.presentationMode.wrappedValue.dismiss()
        }
        
        private let picker: ImagePicker
        
        public func imagePickerControllerDidCancel(_ : UIImagePickerController) {
            picker.presentationMode.wrappedValue.dismiss()
        }
    }
}
