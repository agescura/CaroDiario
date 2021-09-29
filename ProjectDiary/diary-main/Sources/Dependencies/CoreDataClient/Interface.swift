//
//  Interface.swift
//  AddEntryFeature
//
//  Created by Albert Gil Escura on 28/6/21.
//

import Foundation
import ComposableArchitecture
import SharedModels

public struct CoreDataClient {
    public enum Action: Equatable {
        case entries([[Entry]])
    }
    
    public struct Error: Swift.Error, Equatable {
        public let error: NSError?
        
        public init(_ error: Swift.Error?) {
            self.error = error as NSError?
        }
    }
    
    public var create: (AnyHashable) -> Effect<Action, Never>
    public var destroy: (AnyHashable) -> Effect<Never, Never>
    
    public var createDraft: (Entry) -> Effect<Void, Never>
    public var publishEntry: (Entry) -> Effect<Void, Never>
    public var removeEntry: (UUID) -> Effect<Void, Never>
    public var fetchEntry: (Entry) -> Effect<Entry, Never>
    public var fetchAll: () -> Effect<[[Entry]], Never>
    public var updateMessage: (EntryText, Entry) -> Effect<Void, Never>
    public var addAttachmentEntry: (EntryAttachment, UUID) -> Effect<Void, Never>
    public var removeAttachmentEntry: (UUID) -> Effect<Void, Never>
    public var searchEntries: (String) -> Effect<[[Entry]], Never>
    public var searchImageEntries: () -> Effect<[[Entry]], Never>
    public var searchVideoEntries: () -> Effect<[[Entry]], Never>
    public var searchAudioEntries: () -> Effect<[[Entry]], Never>
    
    public init(
        create: @escaping  (AnyHashable) -> Effect<Action, Never>,
        destroy: @escaping (AnyHashable) -> Effect<Never, Never>,
        createDraft: @escaping (Entry) -> Effect<Void, Never>,
        publishEntry: @escaping (Entry) -> Effect<Void, Never>,
        removeEntry: @escaping (UUID) -> Effect<Void, Never>,
        fetchEntry: @escaping (Entry) -> Effect<Entry, Never>,
        fetchAll: @escaping () -> Effect<[[Entry]], Never>,
        updateMessage: @escaping (EntryText, Entry) -> Effect<Void, Never>,
        addAttachmentEntry: @escaping (EntryAttachment, UUID) -> Effect<Void, Never>,
        removeAttachmentEntry: @escaping (UUID) -> Effect<Void, Never>,
        searchEntries: @escaping (String) -> Effect<[[Entry]], Never>,
        searchImageEntries: @escaping () -> Effect<[[Entry]], Never>,
        searchVideoEntries: @escaping () -> Effect<[[Entry]], Never>,
        searchAudioEntries: @escaping () -> Effect<[[Entry]], Never>
    ) {
        self.create = create
        self.destroy = destroy
        self.createDraft = createDraft
        self.publishEntry = publishEntry
        self.removeEntry = removeEntry
        self.fetchEntry = fetchEntry
        self.fetchAll = fetchAll
        self.updateMessage = updateMessage
        self.addAttachmentEntry = addAttachmentEntry
        self.removeAttachmentEntry = removeAttachmentEntry
        self.searchEntries = searchEntries
        self.searchImageEntries = searchImageEntries
        self.searchVideoEntries = searchVideoEntries
        self.searchAudioEntries = searchAudioEntries
    }
    
    func create(id: AnyHashable) -> Effect<Action, Never> {
        create(id)
    }
    
    func destroy(id: AnyHashable) -> Effect<Never, Never> {
        destroy(id)
    }
}
