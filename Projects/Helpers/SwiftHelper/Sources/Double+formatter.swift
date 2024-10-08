//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 5/9/21.
//

import Foundation

extension Double {
    public var formatter: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad

        guard let formatter = formatter.string(from: TimeInterval(self)) else { return "00:00" }
        return formatter
    }
}
