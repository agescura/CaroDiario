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
    
    public var createDraft: (Entry) -> EffectTask<Void>
    public var publishEntry: (Entry) -> EffectTask<Void>
    public var removeEntry: (UUID) -> EffectTask<Void>
    public var fetchEntry: (Entry) -> EffectTask<Entry>
    public var fetchAll: () -> EffectTask<[[Entry]]>
    public var updateMessage: (EntryText, Entry) -> EffectTask<Void>
    public var addAttachmentEntry: (EntryAttachment, UUID) -> EffectTask<Void>
    public var removeAttachmentEntry: (UUID) -> EffectTask<Void>
    public var searchEntries: (String) -> EffectTask<[[Entry]]>
    public var searchImageEntries: () -> EffectTask<[[Entry]]>
    public var searchVideoEntries: () -> EffectTask<[[Entry]]>
    public var searchAudioEntries: () -> EffectTask<[[Entry]]>
    
    public init(
        create: @escaping  (AnyHashable) -> EffectTask<Action>,
        destroy: @escaping (AnyHashable) -> EffectTask<Never>,
        createDraft: @escaping (Entry) -> EffectTask<Void>,
        publishEntry: @escaping (Entry) -> EffectTask<Void>,
        removeEntry: @escaping (UUID) -> EffectTask<Void>,
        fetchEntry: @escaping (Entry) -> EffectTask<Entry>,
        fetchAll: @escaping () -> EffectTask<[[Entry]]>,
        updateMessage: @escaping (EntryText, Entry) -> EffectTask<Void>,
        addAttachmentEntry: @escaping (EntryAttachment, UUID) -> EffectTask<Void>,
        removeAttachmentEntry: @escaping (UUID) -> EffectTask<Void>,
        searchEntries: @escaping (String) -> EffectTask<[[Entry]]>,
        searchImageEntries: @escaping () -> EffectTask<[[Entry]]>,
        searchVideoEntries: @escaping () -> EffectTask<[[Entry]]>,
        searchAudioEntries: @escaping () -> EffectTask<[[Entry]]>
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
