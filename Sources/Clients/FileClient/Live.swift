import Foundation
import UIKit
import Dependencies

extension FileClient: DependencyKey {
  public static var liveValue: FileClient {
    return FileClient(
      removeAttachments: { paths in
        let documentsDirectory = URL.documentsDirectory
        for path in paths {
          try? FileManager.default.removeItem(at: documentsDirectory.appendingPathComponent(path))
        }
      },
      addImage: { image in
        let fileManager = FileManager.default
        let directory = image.resourceDirectory
        if !fileManager.fileExists(atPath: directory.absoluteString) {
          try fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: nil
          )
        }
        try UIImage(data: image.data ?? Data())?
          .resized()
          .pngData()!
          .write(to: image.fileUrl, options: .atomic)
      },
      addVideo: { video in
        let fileManager = FileManager.default
        let directory = video.resourceDirectory
        if !fileManager.fileExists(atPath: directory.absoluteString) {
          try fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: nil
          )
        }
        guard let url = video.url else { fatalError() }
        try fileManager.copyItem(at: url, to: video.fileUrl)
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
