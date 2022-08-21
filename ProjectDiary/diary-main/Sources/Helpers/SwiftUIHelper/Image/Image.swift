//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 21/8/22.
//

import Foundation
import SwiftUI

extension Image {
    public init(
        _ name: SystemImage
    ) {
        self.init(systemName: name.rawValue)
    }
}
