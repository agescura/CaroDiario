//
//  ImageView.swift 
//
//  Created by Albert Gil Escura on 20/7/21.
//

import SwiftUI
import Kingfisher

public struct ImageView: View {
    private let url: URL
    
    public init(
        url: URL
    ) {
        print(url)
        self.url = url
    }
    
    public var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(1, contentMode: .fit)
        } placeholder: {
            ProgressView()
        }
    }
}
