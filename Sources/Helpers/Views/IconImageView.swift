//
//  IconImageView.swift  
//
//  Created by Albert Gil Escura on 10/9/21.
//

import SwiftUI
import SwiftUIHelper

public struct IconImageView: View {
    let systemName: String
    let foregroundColor: Color
    let size: CGFloat
    
    public init(
        systemName: String,
        foregroundColor: Color,
        size: CGFloat = 24
    ) {
        self.systemName = systemName
        self.foregroundColor = foregroundColor
        self.size = size
    }
    
    public init(
        _ systemImage: SystemImage,
        foregroundColor: Color,
        size: CGFloat = 24
    ) {
        self.systemName = systemImage.rawValue
        self.foregroundColor = foregroundColor
        self.size = size
    }
    
    public var body: some View {
        Image(systemName: self.systemName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(
                width: self.size,
                height: self.size
            )
            .foregroundColor(self.foregroundColor)
    }
}
