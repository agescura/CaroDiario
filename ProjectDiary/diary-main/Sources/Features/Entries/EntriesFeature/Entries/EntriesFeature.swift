import AddEntryFeature
import ComposableArchitecture
import CoreDataClient
import EntryDetailFeature
import FileClient
import Foundation
import Models
import UIApplicationClient
import UserDefaultsClient

public struct EntriesFeature: Reducer {
	public init() {}
	
	public struct State: Equatable {
		@PresentationState public var destination: Destination.State?
		public var entries: IdentifiedArrayOf<DayEntriesRow.State> = []
		public var isLoading: Bool = true
		public var userSettings: UserSettings
		
		public init(
			destination: Destination.State? = nil,
			userSettings: UserSettings
		) {
			self.destination = destination
			self.userSettings = userSettings
		}
	}
	
	public enum Action: Equatable {
		case addEntryButtonTapped
		case destination(PresentationAction<Destination.Action>)
		case onAppear
		case coreDataClientAction(CoreDataClient.Action)
		case fetchEntriesResponse([[Entry]])
		case entries(id: UUID, action: DayEntriesRow.Action)
		case remove(Entry)
	}
	
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.uuid) private var uuid
	@Dependency(\.mainRunLoop.now.date) private var now
	@Dependency(\.applicationClient) private var applicationClient
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	@Dependency(\.fileClient) private var fileClient
	
	public struct Destination: Reducer {
		public init() {}
		
		public enum State: Equatable {
			case addEntry(AddEntryFeature.State)
			case detail(EntryDetailFeature.State)
		}
		
		public enum Action: Equatable {
			case addEntry(AddEntryFeature.Action)
			case detail(EntryDetailFeature.Action)
		}
		
		public var body: some ReducerOf<Self> {
			Scope(state: /State.addEntry, action: /Action.addEntry) {
				AddEntryFeature()
			}
			Scope(state: /State.detail, action: /Action.detail) {
				EntryDetailFeature()
			}
		}
	}
	
	public var body: some ReducerOf<Self> {
		Reduce(self.core)
			.forEach(\.entries, action: /Action.entries) {
				DayEntriesRow()
			}
			.ifLet(\.$destination, action: /Action.destination) {
				Destination()
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
				
			case .destination(.presented(.addEntry(.finishAddEntry))),
					.destination(.presented(.addEntry(.view(.addButtonTapped)))):
				state.destination = nil
				return .none
				
			case let .destination(.presented(.detail(.destination(.presented(.alert(.remove(entry))))))):
				state.destination = nil
				return .run { send in
					await self.fileClient.removeAttachments(entry.attachments.urls)
					await send(.remove(entry))
				}
				
			case .destination:
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
				state.destination = .addEntry(AddEntryFeature.State(entry: newEntry))
				return .send(.destination(.presented(.addEntry(.createDraftEntry))))
				
			case let .entries(id: _, action: .dayEntry(.navigateDetail(entry))):
				state.destination = .detail(EntryDetailFeature.State(entry: entry))
				return .none
				
			case .entries:
				return .none
				
			case .remove:
				return .none
		}
	}
}
