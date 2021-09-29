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
        self.url = url
    }
    
    public var body: some View {
        KFImage(url)
            .resizable()
            .placeholder {
                ProgressView()
            }
            .cancelOnDisappear(true)
            .fade(duration: 0.3)
            .aspectRatio(1, contentMode: .fit)
    }
}
