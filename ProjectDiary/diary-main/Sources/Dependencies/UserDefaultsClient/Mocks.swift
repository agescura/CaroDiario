//
//  Mock.swift
//  UserdefaultsClient
//
//  Created by Albert Gil Escura on 29/6/21.
//

import Foundation

extension UserDefaultsClient {
    public static let noop = Self(
        boolForKey: { _ in false },
        setBool: { _, _ in .none },
        stringForKey: { _ in nil },
        setString: { _, _ in .none },
        intForKey: { _ in nil },
        setInt: { _, _ in .none },
        dateForKey: { _ in nil },
        setDate: { _, _ in .none },
        remove: { _ in .none }
    )
}
