import Foundation
import UIKit
import Dependencies

extension FileClient: DependencyKey {
  public static var liveValue: FileClient { .live }
}

extension FileClient {
    public static var live: Self {
        let fileManager = FileManager.default
        
        return Self(
            path: { id in
                guard let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.albertgil.carodiario") else {
                    fatalError()
                }
                return url.appendingPathComponent(id.uuidString)
            },
            removeAttachments: { paths in
					for path in paths {
						 try? fileManager.removeItem(at: path)
					}
            },
            addImage: { image, entryImage in
					try? image
						 .resized()
						 .pngData()!
						 .write(to: entryImage.url, options: .atomic)
					
					try? image
						 .resized(for: CGSize(width: 200, height: 200))
						 .pngData()!
						 .write(to: entryImage.thumbnail, options: .atomic)
					
					return entryImage
            },
            addVideo: { source, thumbnail, entryVideo in
					try? fileManager.copyItem(at: source, to: entryVideo.url)
					
					try? thumbnail
						 .resized(for: CGSize(width: 200, height: 200))
						 .pngData()!
						 .write(to: entryVideo.thumbnail, options: .atomic)
					
					return entryVideo
            },
            
            addAudio: { source, entryAudio in
					try? fileManager.copyItem(at: source, to: entryAudio.url)
					
					return entryAudio
            }
        )
    }
}

extension UIImage {
    private func rotateImage() -> UIImage {
        if (imageOrientation == UIImage.Orientation.up) {
            return self
        }
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(origin: .zero, size: size))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return copy!
    }
    
    func resized(for size: CGSize? = nil) -> UIImage {
        guard let size = size else {
            return rotateImage()
        }
        
        return UIGraphicsImageRenderer(size: size)
            .image { _ in
                rotateImage()
                    .draw(in: CGRect(origin: .zero, size: size))
            }
    }
}
