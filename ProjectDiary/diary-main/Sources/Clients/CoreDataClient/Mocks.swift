//
//  Mock.swift
//  CoredataClient
//
//  Created by Albert Gil Escura on 28/6/21.
//

import Foundation
import ComposableArchitecture
import Models

extension CoreDataClient {
    public static let noop = Self(
        create: { _ in .fireAndForget {} },
        destroy: { _ in .fireAndForget {} },
        createDraft: { entry in
            return .fireAndForget {}
        },
        publishEntry: { _ in .fireAndForget {} },
        removeEntry: { _ in .fireAndForget {} },
        fetchEntry: { _ in .fireAndForget {} },
        fetchAll: { .fireAndForget {} },
        updateMessage: { _, _ in .fireAndForget {} },
        addAttachmentEntry: { _, _ in .fireAndForget {} },
        removeAttachmentEntry: { _  in .fireAndForget {} },
        searchEntries: { _ in .fireAndForget {} },
        searchImageEntries: { .fireAndForget {} },
        searchVideoEntries: { .fireAndForget {} },
        searchAudioEntries: { .fireAndForget {} }
    )
}
