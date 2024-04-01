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
    
    public var create: (AnyHashable) -> Effect<Action>
    public var destroy: (AnyHashable) -> Effect<Never>
    
    public var createDraft: (Entry) -> Effect<Void>
    public var publishEntry: (Entry) -> Effect<Void>
    public var removeEntry: (UUID) -> Effect<Void>
    public var fetchEntry: (Entry) -> Effect<Entry>
    public var fetchAll: () -> Effect<[[Entry]]>
    public var updateMessage: (EntryText, Entry) -> Effect<Void>
    public var addAttachmentEntry: (EntryAttachment, UUID) -> Effect<Void>
    public var removeAttachmentEntry: (UUID) -> Effect<Void>
    public var searchEntries: (String) -> Effect<[[Entry]]>
    public var searchImageEntries: () -> Effect<[[Entry]]>
    public var searchVideoEntries: () -> Effect<[[Entry]]>
    public var searchAudioEntries: () -> Effect<[[Entry]]>
    
    public init(
        create: @escaping  (AnyHashable) -> Effect<Action>,
        destroy: @escaping (AnyHashable) -> Effect<Never>,
        createDraft: @escaping (Entry) -> Effect<Void>,
        publishEntry: @escaping (Entry) -> Effect<Void>,
        removeEntry: @escaping (UUID) -> Effect<Void>,
        fetchEntry: @escaping (Entry) -> Effect<Entry>,
        fetchAll: @escaping () -> Effect<[[Entry]]>,
        updateMessage: @escaping (EntryText, Entry) -> Effect<Void>,
        addAttachmentEntry: @escaping (EntryAttachment, UUID) -> Effect<Void>,
        removeAttachmentEntry: @escaping (UUID) -> Effect<Void>,
        searchEntries: @escaping (String) -> Effect<[[Entry]]>,
        searchImageEntries: @escaping () -> Effect<[[Entry]]>,
        searchVideoEntries: @escaping () -> Effect<[[Entry]]>,
        searchAudioEntries: @escaping () -> Effect<[[Entry]]>
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
    
    func create(id: AnyHashable) -> Effect<Action> {
        create(id)
    }
    
    func destroy(id: AnyHashable) -> Effect<Never> {
        destroy(id)
    }
}
