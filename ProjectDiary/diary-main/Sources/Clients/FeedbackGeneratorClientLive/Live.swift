//
//  Live.swift
//  
//
//  Created by Albert Gil Escura on 8/8/21.
//

import UIKit
import FeedbackGeneratorClient


extension FeedbackGeneratorClient {
    public static var live: Self {
        let generator = UISelectionFeedbackGenerator()
        return Self(
            prepare: { generator.prepare() },
            selectionChanged: { generator.selectionChanged() }
        )
    }
}
