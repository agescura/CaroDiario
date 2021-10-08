//
//  Mocks.swift
//
//  Created by Albert Gil Escura on 28/7/21.
//

import Foundation

extension UIApplicationClient {
    
    public static let noop = Self(
        alternateIconName: nil,
        setAlternateIconName: { _ in .none },
        supportsAlternateIcons: { true },
        openSettings: { .fireAndForget {} },
        open: { _, _ in .fireAndForget {} },
        canOpen: { _ in true },
        share: { _, _ in .fireAndForget {} },
        showTabView: { _ in .fireAndForget {} }
    )
}
