//
//  FileClientLive.swift
//  FileClientLive
//
//  Created by Albert Gil Escura on 3/7/21.
//

import Foundation
import ComposableArchitecture
import UIKit
import FileClient

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
            removeAttachments: { paths, queue in
                .future { promise in
                    queue.schedule {
                        for path in paths {
                            try? fileManager.removeItem(at: path)
                        }
                        promise(.success(()))
                    }
                }
            },
            addImage: { image, entryImage, queue in
                .future { promise in
                    queue.schedule {
                        try? image
                            .resized()
                            .pngData()!
                            .write(to: entryImage.url, options: .atomic)
                        
                        try? image
                            .resized(for: CGSize(width: 200, height: 200))
                            .pngData()!
                            .write(to: entryImage.thumbnail, options: .atomic)
                        
                        promise(.success(entryImage))
                    }
                }
            },
            loadImage: { entryImage,  queue in
                    .future { promise in
                        queue.schedule {
                            URLSession.shared.dataTask(with: entryImage.url) { data, response, error in
                                guard let data = data, error == nil else {
                                    return
                                }
                                
                                DispatchQueue.main.async {
                                    promise(.success(data))
                                }
                            }
                            .resume()
                        }
                    }
            },
            addVideo: { source, entryVideo, queue in
                .future { promise in
                    queue.schedule {
                        try? fileManager.copyItem(at: source, to: entryVideo.url)
                        if let image = source.generateThumbnail() {
                            try? image
                                .resized(for: CGSize(width: 200, height: 200))
                                .pngData()!
                                .write(to: entryVideo.thumbnail, options: .atomic)
                        }
                        promise(.success(entryVideo))
                    }
                }
            },
            
            addAudio: { source, entryAudio, queue in
                .future { promise in
                    queue.schedule {
                        try? fileManager.copyItem(at: source, to: entryAudio.url)
                        promise(.success(entryAudio))
                    }
                }
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

import AVKit

extension URL {
    func generateThumbnail() -> UIImage? {
        do {
            let asset = AVURLAsset(url: self)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            let cgImage = try imageGenerator.copyCGImage(at: .zero,
                                                         actualTime: nil)

            return UIImage(cgImage: cgImage)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
