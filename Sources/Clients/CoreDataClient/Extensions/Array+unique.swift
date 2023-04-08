//
//  Array+unique.swift
//
//  Created by Albert Gil Escura on 21/9/21.
//

import Foundation

extension Array {
    func unique(selector:(Element,Element) -> Bool) -> Array<Element> {
        reduce(Array<Element>()){
            if let last = $0.last {
                return selector(last,$1) ? $0 : $0 + [$1]
            } else {
                return [$1]
            }
        }
    }
}
