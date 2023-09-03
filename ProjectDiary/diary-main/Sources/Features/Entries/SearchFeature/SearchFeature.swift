import ComposableArchitecture
import Foundation
import EntriesFeature
import EntryDetailFeature
import Models

public struct SearchFeature: Reducer {
	public init() {}
	
	public struct State: Equatable {
		@PresentationState public var destination: Destination.State?
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		public var searchText: String = ""
		
		public var entriesCount: Int {
			entries.map(\.dayEntries.entries.count).reduce(0, +)
		}
		
		public init(
			entries: IdentifiedArrayOf<DayEntriesRow.State> = [],
			searchText: String = ""
		) {
			self.entries = entries
			self.searchText = searchText
		}
	}
	
	public enum Action: Equatable {
		case destination(PresentationAction<Destination.Action>)
		case entries(id: UUID, action: DayEntriesRow.Action)
		case navigateAudioSearch
		case navigateImageSearch
		case navigateVideoSearch
		case navigateSearch(AttachmentSearchType, [[Entry]])
		case remove(Entry)
		case searching(newText: String)
		case searchResponse([[Entry]])
	}
	
	@Dependency(\.fileClient) private var fileClient
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	@Dependency(\.uuid) private var uuid
	
	public struct Destination: Reducer {
		public enum State: Equatable {
			case attachmentSearch(AttachmentSearch.State)
			case entryDetail(EntryDetail.State)
		}
		
		public enum Action: Equatable {
			case attachmentSearch(AttachmentSearch.Action)
			case entryDetail(EntryDetail.Action)
		}
		
		public var body: some ReducerOf<Self> {
			Scope(state: /State.attachmentSearch, action: /Action.attachmentSearch) {
				AttachmentSearch()
			}
			Scope(state: /State.entryDetail, action: /Action.entryDetail) {
				EntryDetail()
			}
		}
	}
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
					
				case let .destination(.presented(.entryDetail(.remove(entry)))):
					return .run { send in
						await self.fileClient.removeAttachments(entry.attachments.urls)
						await send(.remove(entry))
					}
					
				case .destination:
					return .none
					
				case let .entries(id: _, action: .dayEntry(.navigateDetail(entry))):
					state.destination = .entryDetail(EntryDetail.State(entry: entry))
					return .none
					
				case .entries:
					return .none

				case .navigateAudioSearch:
					return .none
					
				case .navigateImageSearch:
					return .none

				case .navigateVideoSearch:
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
					
			}
		}
		.ifLet(\.$destination, action: /Action.destination) {
			Destination()
		}
		.forEach(\.entries, action: /Action.entries) {
			DayEntriesRow()
		}
	}
}
