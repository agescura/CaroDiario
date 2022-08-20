//
//  Localizable.swift
//  AddEntryFeature
//
//  Created by Albert Gil Escura on 27/6/21.
//

import Foundation

extension String {
    public var localized: String {
        let language = UserDefaults(suiteName: "group.albertgil.carodiario")!.string(forKey: "LanguageCodeKey") ?? "en"
        let path = Bundle.module.path(forResource: language, ofType: "lproj")!
        let bundle = Bundle(path: path)!
        
        return NSLocalizedString(
            self,
            bundle: bundle,
            comment: ""
        )
    }
    
    public func localized(with arguments: [CVarArg]) -> String {
        String(
            format: localized,
            locale: nil,
            arguments: arguments
        )
    }
}
