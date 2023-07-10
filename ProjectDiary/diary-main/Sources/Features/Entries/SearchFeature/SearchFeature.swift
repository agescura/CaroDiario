import ComposableArchitecture
import Foundation
import EntriesFeature
import EntryDetailFeature
import Models

public struct SearchFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		@PresentationState public var destination: Destination.State?
		public var searchText: String = ""
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		
		public var attachmentSearchState: AttachmentSearch.State?
		public var navigateAttachmentSearch = false
		
		public var entryDetailState: EntryDetail.State?
		public var navigateEntryDetail = false
		public var entryDetailSelected: Entry?
		
		public var entriesCount: Int {
			entries.map(\.dayEntries.entries.count).reduce(0, +)
		}
		
		public init(
			searchText: String = "",
			entries: IdentifiedArrayOf<DayEntriesRow.State> = []
		) {
			self.searchText = searchText
			self.entries = entries
		}
	}
	
	public enum Action: Equatable {
		case destination(PresentationAction<Destination.Action>)
		case searching(newText: String)
		case searchResponse([[Entry]])
		case entries(id: UUID, action: DayEntriesRow.Action)
		case remove(Entry)
		
		case attachmentSearchAction(AttachmentSearch.Action)
		case navigateAttachmentSearch(Bool)
		case navigateImageSearch
		case navigateVideoSearch
		case navigateAudioSearch
		case navigateSearch(AttachmentSearchType, [[Entry]])
		
		case entryDetailAction(EntryDetail.Action)
	}
	
	@Dependency(\.backgroundQueue) private var backgroundQueue
	@Dependency(\.fileClient) private var fileClient
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	@Dependency(\.uuid) private var uuid
	
	public struct Destination: ReducerProtocol {
		public enum State: Equatable {
			case attachmentSearch(AttachmentSearch.State)
			case entryDetail(EntryDetail.State)
		}
		
		public enum Action: Equatable {
			case attachmentSearch(AttachmentSearch.Action)
			case entryDetail(EntryDetail.Action)
		}
		
		public var body: some ReducerProtocolOf<Self> {
			Scope(state: /State.attachmentSearch, action: /Action.attachmentSearch) {
				AttachmentSearch()
			}
			Scope(state: /State.entryDetail, action: /Action.entryDetail) {
				EntryDetail()
			}
		}
	}
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
					
				case let .destination(.presented(.entryDetail(.remove(entry)))):
					return self.fileClient.removeAttachments(entry.attachments.urls, self.backgroundQueue)
						.receive(on: self.mainQueue)
						.eraseToEffect()
						.map({ SearchFeature.Action.remove(entry) })
					
				case .destination:
					return .none
					
				case let .searching(newText: newText):
					state.searchText = newText
					return .none
					
				case let .searchResponse(response):
					var dayResult: IdentifiedArrayOf<DayEntriesRow.State> = []
					
					for entries in response {
						let day = DayEntriesRow.State(dayEntry: .init(
							entry: .init(uniqueElements: entries), style: self.userDefaultsClient.styleType, layout: self.userDefaultsClient.layoutType), id: self.uuid())
						dayResult.append(day)
					}
					state.entries = dayResult
					return .none
					
				case let .entries(id: _, action: .dayEntry(.navigateDetail(entry))):
					state.destination = .entryDetail(EntryDetail.State(entry: entry))
					return .none
					
				case .entries:
					return .none
					
				case .attachmentSearchAction:
					return .none
					
				case let .navigateAttachmentSearch(value):
					state.attachmentSearchState = value ? .init(type: .images, entries: []) : nil
					state.navigateAttachmentSearch = value
					return .none
					
				case .navigateImageSearch:
					return .none

				case .navigateVideoSearch:
					return .none

				case .navigateAudioSearch:
					return .none
					
				case let .navigateSearch(type, response):
					var dayResult: IdentifiedArrayOf<DayEntriesRow.State> = []
					
					for entries in response {
						let day = DayEntriesRow.State(dayEntry: .init(
							entry: .init(uniqueElements: entries), style: self.userDefaultsClient.styleType, layout: self.userDefaultsClient.layoutType), id: self.uuid())
						dayResult.append(day)
					}
					
					state.destination = .attachmentSearch(
						AttachmentSearch.State(type: type, entries: dayResult)
					)
					return .none
					
				case .remove:
					return .none
					
				case .entryDetailAction:
					return .none
			}
		}
		.forEach(\.entries, action: /Action.entries) {
			DayEntriesRow()
		}
		.ifLet(\.$destination, action: /Action.destination) {
			Destination()
		}
	}
}
