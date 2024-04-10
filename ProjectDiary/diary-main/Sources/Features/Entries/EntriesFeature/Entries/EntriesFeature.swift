import Foundation
import ComposableArchitecture
import UIApplicationClient
import UserDefaultsClient
import FileClient
import Models
import AddEntryFeature
import EntryDetailFeature
import CoreDataClient

@Reducer
public struct EntriesFeature {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		public var isLoading: Bool
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		@Presents public var addEntryState: AddEntryFeature.State?
		@Presents public var entryDetailState: EntryDetailFeature.State?
		public var entryDetailSelected: Entry?
		
		public init(
			isLoading: Bool = true,
			entries: IdentifiedArrayOf<DayEntriesRow.State> = [],
			addEntryState: AddEntryFeature.State? = nil,
			entryDetailState: EntryDetailFeature.State? = nil,
			entryDetailSelected: Entry? = nil
		) {
			self.isLoading = isLoading
			self.entries = entries
			self.addEntryState = addEntryState
			self.entryDetailState = entryDetailState
			self.entryDetailSelected = entryDetailSelected
		}
	}
	
	public enum Action: Equatable {
		case onAppear
		case coreDataClientAction(CoreDataClient.Action)
		case fetchEntriesResponse([[Entry]])
		case addEntryButtonTapped
		case addEntryAction(PresentationAction<AddEntryFeature.Action>)
		case presentAddEntryCompleted
		case entries(IdentifiedActionOf<DayEntriesRow>)
		case remove(Entry)
		case entryDetailButtonTapped
		case entryDetailAction(PresentationAction<EntryDetailFeature.Action>)
	}
	
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.uuid) private var uuid
	@Dependency(\.mainRunLoop.now.date) private var now
	@Dependency(\.applicationClient) private var applicationClient
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	@Dependency(\.fileClient) private var fileClient
	private struct CoreDataId: Hashable {}
	
	public var body: some ReducerOf<Self> {
		Reduce(self.core)
			.forEach(\.entries, action: \.entries) {
				DayEntriesRow()
			}
			.ifLet(\.$addEntryState, action: \.addEntryAction) {
				AddEntryFeature()
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
				
			case .onAppear:
				return .none
				
			case let .coreDataClientAction(.entries(response)):
				return .send(.fetchEntriesResponse(response))
				
			case let .fetchEntriesResponse(response):
				var dayResult: IdentifiedArrayOf<DayEntriesRow.State> = []
				
				for entries in response {
					let day = DayEntriesRow.State(
						dayEntry: .init(entry: .init(uniqueElements: entries),
														style: self.userDefaultsClient.styleType,
														layout: self.userDefaultsClient.layoutType),
						id: self.uuid())
					dayResult.append(day)
				}
				
				state.entries = dayResult
				state.isLoading = false
				return .none
				
			case .addEntryAction:
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
				state.addEntryState = AddEntryFeature.State(entry: newEntry, type: .add)
				return .send(.addEntryAction(.presented(.createDraftEntry)))
				
//			case .presentAddEntry(false):
//				state.presentAddEntry = false
//				return .run { send in
//					try await self.mainQueue.sleep(for: .seconds(0.3))
//					await send(.presentAddEntryCompleted)
//				}
				
			case .presentAddEntryCompleted:
				state.addEntryState = nil
				return .none
				
			case let .entries(.element(id: _, action: .dayEntry(.navigateDetail(entry)))):
				state.entryDetailSelected = entry
				return .send(.entryDetailButtonTapped)
				
			case .entries:
				return .none
				
			case .remove:
				return .none
				
			case .entryDetailButtonTapped:
				guard let entry = state.entryDetailSelected else { return .none }
				state.entryDetailState = EntryDetailFeature.State(entry: entry)
				return .none
				
//			case let .entryDetailAction(.alert(.presented(.remove(entry)))):
//				return .merge(
//					.run { send in
//						_ = await self.fileClient.removeAttachments(entry.attachments.urls)
//						await send(.remove(entry))
//					},
//					.send(.navigateEntryDetail(false))
//				)
				
			case .entryDetailAction:
				return .none
		}
	}
}
