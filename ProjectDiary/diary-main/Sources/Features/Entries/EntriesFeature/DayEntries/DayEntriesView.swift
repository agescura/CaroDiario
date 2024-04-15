import SwiftUI
import ComposableArchitecture
import Models
import Styles
import SwiftUIHelper

@Reducer
public struct DayEntries {
  public init() {}
  
	@ObservableState
  public struct State: Equatable {
    public var entries: IdentifiedArrayOf<Entry>
    public var showLongDate: Bool = false
    @Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
		
    public init(
      entry: IdentifiedArrayOf<Entry>
    ) {
      self.entries = entry
    }
  }
  
  public enum Action: Equatable {
    case toggleLongDate
    case navigateDetail(Entry)
  }
  
  public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case .toggleLongDate:
				state.showLongDate = !state.showLongDate
				return .none
			case .navigateDetail:
				return .none
			}
		}
  }
}

public struct DayEntriesView: View {
  let store: StoreOf<DayEntries>
  
  public init(
    store: StoreOf<DayEntries>
  ) {
    self.store = store
  }
  
  public var body: some View {
		WithPerceptionTracking {
			AppearanceMainStack(layout: self.store.userSettings.appearance.layoutType, spacing: 4) {
				WithPerceptionTracking {
					Group {
						AppearanceDayStack(layout: self.store.userSettings.appearance.layoutType, spacing: 4) {
							WithPerceptionTracking {
								Group {
									Text(self.store.entries.first?.numberDay ?? "")
										.adaptiveFont(.latoRegular, size: 10)
										.foregroundColor(.adaptiveGray)
										.frame(width: 48, height: 48)
										.modifier(StyleModifier(style: self.store.userSettings.appearance.styleType))
									
									Text(self.store.entries.first?.stringDay ?? "")
										.adaptiveFont(.latoRegular, size: 10)
										.foregroundColor(.adaptiveGray)
										.frame(width: 48, height: 48)
										.modifier(StyleModifier(style: self.store.userSettings.appearance.styleType))
									
									if self.store.showLongDate {
										Text(self.store.entries.first?.stringMonth ?? "")
											.adaptiveFont(.latoRegular, size: 10)
											.foregroundColor(.adaptiveGray)
											.minimumScaleFactor(0.01)
											.frame(width: 48, height: 48)
											.modifier(StyleModifier(style: self.store.userSettings.appearance.styleType))
										
										Text(self.store.entries.first?.stringYear ?? "")
											.adaptiveFont(.latoRegular, size: 10)
											.foregroundColor(.adaptiveGray)
											.minimumScaleFactor(0.01)
											.frame(width: 48, height: 48)
											.modifier(StyleModifier(style: self.store.userSettings.appearance.styleType))
									}
								}
								.onTapGesture {
									self.store.send(.toggleLongDate, animation: .default)
								}
							}
						}
						VStack(spacing: 4) {
							ForEach(self.store.entries) { entry in
								WithPerceptionTracking {
									VStack(alignment: .leading, spacing: 8) {
										Text(entry.stringHour)
											.adaptiveFont(.latoRegular, size: 6)
											.foregroundColor(.chambray)
										Text(entry.text.message.removingAllExtraNewLines)
											.adaptiveFont(.latoRegular, size: 10)
											.foregroundColor(.chambray)
											.lineLimit(3)
										HStack(spacing: 8) {
											HStack(spacing: 4) {
												Text("\(entry.images.count)")
													.adaptiveFont(.latoRegular, size: 6)
													.foregroundColor(.adaptiveGray)
												Image(.photo)
													.resizable()
													.foregroundColor(.adaptiveGray)
													.frame(width: 10, height: 10)
											}
											HStack(spacing: 4) {
												Text("\(entry.videos.count)")
													.adaptiveFont(.latoRegular, size: 6)
													.foregroundColor(.adaptiveGray)
												Image(.video)
													.resizable()
													.foregroundColor(.adaptiveGray)
													.frame(width: 14, height: 10)
											}
											HStack(spacing: 4) {
												Text("\(entry.audios.count)")
													.adaptiveFont(.latoRegular, size: 6)
													.foregroundColor(.adaptiveGray)
												Image(.waveform)
													.resizable()
													.foregroundColor(.adaptiveGray)
													.frame(width: 14, height: 10)
											}
											Spacer()
											Text("Entries.ReadMore".localized)
												.adaptiveFont(.latoRegular, size: 6)
												.foregroundColor(.adaptiveGray)
										}
									}
									.frame(maxWidth: .infinity)
									.padding(8)
									.modifier(StyleModifier(style: self.store.userSettings.appearance.styleType))
									.contentShape(Rectangle())
									.onTapGesture {
										self.store.send(.navigateDetail(entry))
									}
								}
							}
						}
					}
				}
      }
    }
  }
}

struct AppearanceMainStack<Content: View>: View {
  let layout: LayoutType
  let spacing: CGFloat?
  let content: () -> Content
  
  var body: some View {
    Group {
      if layout == .horizontal {
        HStack(alignment: .top, spacing: spacing, content: content)
      } else {
        VStack(alignment: .leading, spacing: spacing, content: content)
      }
    }
  }
}

struct AppearanceDayStack<Content: View>: View {
  let layout: LayoutType
  let spacing: CGFloat?
  let content: () -> Content
  
  var body: some View {
    Group {
      if layout == .horizontal {
        VStack(alignment: .leading, spacing: spacing, content: content)
      } else {
        HStack(alignment: .top, spacing: spacing, content: content)
      }
    }
  }
}

fileprivate extension StringProtocol {
  var lines: [SubSequence] { split(whereSeparator: \.isNewline) }
  var removingAllExtraNewLines: String { lines.joined(separator: "\n") }
}
