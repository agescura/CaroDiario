import Foundation
import ComposableArchitecture
import Models
import Dependencies

extension DependencyValues {
  public var coreDataClient: CoreDataClient {
    get { self[CoreDataClient.self] }
    set { self[CoreDataClient.self] = newValue }
  }
}

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
    
    public var create: (AnyHashable) -> EffectTask<Action>
    public var destroy: (AnyHashable) -> EffectTask<Never>
    
    public var createDraft: (Entry) async -> Void
    public var publishEntry: (Entry) async -> Void
    public var removeEntry: (UUID) async -> Void
    public var fetchEntry: (Entry) async -> Entry
    public var fetchAll: () async -> [[Entry]]
    public var updateMessage: (EntryText, Entry) async -> Void
    public var addAttachmentEntry: (EntryAttachment, UUID) async -> Void
    public var removeAttachmentEntry: (UUID) async -> Void
    public var searchEntries: (String) async -> [[Entry]]
    public var searchImageEntries: () async -> [[Entry]]
    public var searchVideoEntries: () async -> [[Entry]]
    public var searchAudioEntries: () async -> [[Entry]]
    
    public init(
        create: @escaping  (AnyHashable) -> EffectTask<Action>,
        destroy: @escaping (AnyHashable) -> EffectTask<Never>,
        createDraft: @escaping (Entry) async -> Void,
        publishEntry: @escaping (Entry) async -> Void,
        removeEntry: @escaping (UUID) async -> Void,
        fetchEntry: @escaping (Entry) async -> Entry,
        fetchAll: @escaping () async -> [[Entry]],
        updateMessage: @escaping (EntryText, Entry) async -> Void,
        addAttachmentEntry: @escaping (EntryAttachment, UUID) async -> Void,
        removeAttachmentEntry: @escaping (UUID) async -> Void,
        searchEntries: @escaping (String) async -> [[Entry]],
        searchImageEntries: @escaping () async -> [[Entry]],
        searchVideoEntries: @escaping () async -> [[Entry]],
        searchAudioEntries: @escaping () async -> [[Entry]]
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
    
    func create(id: AnyHashable) -> EffectTask<Action> {
        create(id)
    }
    
    func destroy(id: AnyHashable) -> EffectTask<Never> {
        destroy(id)
    }
}
