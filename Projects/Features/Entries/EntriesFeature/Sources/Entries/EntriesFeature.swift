import AddEntryFeature
import ComposableArchitecture
import CoreDataClient
import EntryDetailFeature
import FileClient
import Foundation
import Models
import UIApplicationClient
import UserDefaultsClient

@Reducer
public struct EntriesFeature {
	public init() {}
	
	@Reducer(state: .equatable, action: .equatable)
	public enum Path {
		case detail(EntryDetailFeature)
	}
	
	@ObservableState
	public struct State: Equatable {
		@Presents public var add: AddEntryFeature.State?
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		public var isLoading: Bool
		public var path: StackState<Path.State>
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
		
		public init(
			add: AddEntryFeature.State? = nil,
			entries: IdentifiedArrayOf<DayEntriesRow.State> = [],
			isLoading: Bool = true,
			path: StackState<Path.State> = StackState<Path.State>()
		) {
			self.isLoading = isLoading
			self.entries = entries
			self.add = add
			self.path = path
		}
	}
	
	public enum Action: Equatable {
		case add(PresentationAction<AddEntryFeature.Action>)
		case addEntryButtonTapped
		case entries(IdentifiedActionOf<DayEntriesRow>)
		case fetchEntriesResponse([[Entry]])
		case path(StackActionOf<Path>)
		case presentAddEntryCompleted
		case remove(Entry)
		case task
	}
	
	@Dependency(\.applicationClient) var applicationClient
	@Dependency(\.continuousClock) var clock
	@Dependency(\.coreDataClient) var coreDataClient
	@Dependency(\.fileClient) var fileClient
	@Dependency(\.mainRunLoop.now.date) var now
	@Dependency(\.uuid) var uuid
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .path:
					return .none
				case .task:
					return .run { send in
						for await entries in await self.coreDataClient.subscriber() {
							await send(.fetchEntriesResponse(entries))
						}
					}
					
				case let .fetchEntriesResponse(response):
					var dayResult: IdentifiedArrayOf<DayEntriesRow.State> = []
					
					for entries in response {
						let day = DayEntriesRow.State(
							dayEntry: .init(entry: .init(uniqueElements: entries)),
							id: self.uuid())
						dayResult.append(day)
					}
					
					state.entries = dayResult
					state.isLoading = false
					return .none
					
				case .add:
					return .none
					
				case .addEntryButtonTapped:
					let newEntry = Entry(
						id: self.uuid(),
						date: self.now,
						startDay: self.now,
						text: .init(
							id: self.uuid(),
							message: "",
							lastUpdated: self.now
						)
					)
					state.add = AddEntryFeature.State(entry: newEntry)
					return .run { _ in
						await self.coreDataClient.createDraft(newEntry)
					}
					
	//			case .presentAddEntry(false):
	//				state.presentAddEntry = false
	//				return .run { send in
	//					try await self.mainQueue.sleep(for: .seconds(0.3))
	//					await send(.presentAddEntryCompleted)
	//				}
					
				case .presentAddEntryCompleted:
					state.add = nil
					return .none
					
				case let .entries(.element(id: _, action: .dayEntry(.navigateDetail(entry)))):
					state.path.append(.detail(EntryDetailFeature.State(entry: entry)))
					return .none
					
				case .entries:
					return .none
					
				case .remove:
					return .none
					
	//			case let .entryDetailAction(.alert(.presented(.remove(entry)))):
	//				return .merge(
	//					.run { send in
	//						_ = await self.fileClient.removeAttachments(entry.attachments.urls)
	//						await send(.remove(entry))
	//					},
	//					.send(.navigateEntryDetail(false))
	//				)
			}
		}
		.ifLet(\.$add, action: \.add) {
			AddEntryFeature()
		}
		.forEach(\.entries, action: \.entries) {
			DayEntriesRow()
		}
		.forEach(\.path, action: \.path)
	}
}
