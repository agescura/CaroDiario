//
//  Interface.swift
//
//  Created by Albert Gil Escura on 28/7/21.
//

import ComposableArchitecture
import UIKit

public struct UIApplicationClient {
    public let alternateIconName: String?
    public let setAlternateIconName: (String?) -> Effect<Never, Error>
    public let supportsAlternateIcons: () -> Bool
    public let openSettings: () -> Effect<Never, Never>
    public var open: (URL, [UIApplication.OpenExternalURLOptionsKey: Any]) -> Effect<Never, Never>
    public var canOpen: (URL) -> Bool
    public let share: (Any) -> Effect<Never, Never>
    public let showTabView: (Bool) -> Effect<Never, Never>
    
    public init(
        alternateIconName: String?,
        setAlternateIconName: @escaping (String?) -> Effect<Never, Error>,
        supportsAlternateIcons: @escaping () -> Bool,
        openSettings: @escaping () -> Effect<Never, Never>,
        open: @escaping (URL, [UIApplication.OpenExternalURLOptionsKey: Any]) -> Effect<Never, Never>,
        canOpen: @escaping (URL) -> Bool,
        share: @escaping (Any) -> Effect<Never, Never>,
        showTabView: @escaping (Bool) -> Effect<Never, Never>
    ) {
        self.alternateIconName = alternateIconName
        self.setAlternateIconName = setAlternateIconName
        self.supportsAlternateIcons = supportsAlternateIcons
        self.openSettings = openSettings
        self.open = open
        self.canOpen = canOpen
        self.share = share
        self.showTabView = showTabView
    }
}
