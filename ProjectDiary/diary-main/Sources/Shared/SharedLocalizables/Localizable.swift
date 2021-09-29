//
//  Localizable.swift
//  AddEntryFeature
//
//  Created by Albert Gil Escura on 27/6/21.
//

import Foundation

extension String {
    public var localized: String {
        return NSLocalizedString(
            self,
            bundle: .module,
            comment: ""
        )
    }
    
    public func localized(with arguments: [CVarArg]) -> String {
        return String(
            format: localized,
            locale: nil,
            arguments: arguments
        )
    }
}
