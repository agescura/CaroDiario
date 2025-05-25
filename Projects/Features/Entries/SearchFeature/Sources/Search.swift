import Foundation
import ComposableArchitecture
import AVAssetClient
import Models
import EntriesFeature
import FileClient
import UserDefaultsClient
import UIApplicationClient
import EntryDetailFeature

@Reducer
public struct Search {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		public var searchText: String = ""
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		
		@Presents public var attachmentSearchState: AttachmentSearch.State?
		@Presents public var entryDetailState: EntryDetailFeature.State?
		
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
		case searching(newText: String)
		case searchResponse([[Entry]])
		case entries(IdentifiedActionOf<DayEntriesRow>)
		case remove(Entry)
		
		case attachmentSearchAction(PresentationAction<AttachmentSearch.Action>)
		case navigateImageSearch
		case navigateVideoSearch
		case navigateAudioSearch
		case navigateSearch(AttachmentSearchType, [[Entry]])
		
		case entryDetailAction(PresentationAction<EntryDetailFeature.Action>)
	}
	
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	@Dependency(\.uuid) private var uuid
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.fileClient) private var fileClient
	
	public var body: some ReducerOf<Self> {
		Reduce(self.core)
			.forEach(\.entries, action: \.entries) {
				DayEntriesRow()
			}
			.ifLet(\.$attachmentSearchState, action: \.attachmentSearchAction) {
				AttachmentSearch()
			}
			.ifLet(\.$entryDetailState, action: \.entryDetailAction) {
				EntryDetailFeature()
			}
		
	}
	
	private func core(
		state: inout State,
		action: Action
	) -> Effect<Action> {
		switch action {
			case let .searching(newText: newText):
				state.searchText = newText
				return .none
				
			case let .searchResponse(response):
				var dayResult: IdentifiedArrayOf<DayEntriesRow.State> = []
				
				for entries in response {
					let day = DayEntriesRow.State(dayEntry: .init(
						entry: .init(uniqueElements: entries)), id: self.uuid())
					dayResult.append(day)
				}
				state.entries = dayResult
				return .none
				
			case let .entries(.element(id: _, action: .dayEntry(.navigateDetail(entry)))):
				state.entryDetailState = EntryDetailFeature.State(entry: entry)
				return .none
				
			case .entries:
				return .none
				
			case .attachmentSearchAction:
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
						entry: .init(uniqueElements: entries)), id: self.uuid())
					dayResult.append(day)
				}
				
				state.attachmentSearchState = .init(type: type, entries: dayResult)
				return .none
				
			case .remove:
				return .none
				
			case let .entryDetailAction(.presented(.alert(.presented(.remove(entry))))):
				state.entryDetailState = nil
				return .run { send in
					_ = await self.fileClient.removeAttachments(entry.attachments.urls)
					 await send(.remove(entry))
				 }
				
			case .entryDetailAction:
				return .none
		}
	}
}
