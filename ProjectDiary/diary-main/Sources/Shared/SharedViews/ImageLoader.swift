//
//  ImageLoader.swift 
//
//  Created by Albert Gil Escura on 13/9/21.
//

import SwiftUI

class ImageLoader: ObservableObject {
    @Published var downloadedImage: UIImage?
    
    func load(url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.downloadedImage = UIImage(data: data)
            }
            
        }
        .resume()
    }
}
