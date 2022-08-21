//
//  DayEntryView.swift
//  AddEntryFeature
//
//  Created by Albert Gil Escura on 1/7/21.
//

import SwiftUI
import ComposableArchitecture
import Models
import Styles

public struct DayEntriesState: Equatable {
    public var entries: IdentifiedArrayOf<Entry>
    public var showLongDate: Bool = false
    public var style: StyleType
    public var layout: LayoutType
    
    public init(
        entry: IdentifiedArrayOf<Entry>,
        style: StyleType,
        layout: LayoutType
    ) {
        self.entries = entry
        self.style = style
        self.layout = layout
    }
}

public enum DayEntriesAction: Equatable {
    case toggleLongDate
    case navigateDetail(Entry)
}

public let dayEntriesReducer = Reducer<
    DayEntriesState,
    DayEntriesAction,
    Void
> { state, action, _ in
    switch action {
    case .toggleLongDate:
        state.showLongDate = !state.showLongDate
        return .none
        
    case .navigateDetail:
        return .none
    }
}

public struct DayEntriesView: View {
    let store: Store<DayEntriesState, DayEntriesAction>
    
    public init(
        store: Store<DayEntriesState, DayEntriesAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            AppearanceMainStack(layout: viewStore.layout, spacing: 4) {
                Group {
                    AppearanceDayStack(layout: viewStore.layout, spacing: 4) {
                        Group {
                            NavigationLink(destination: EmptyView()) {
                                EmptyView()
                            }
                            Text(viewStore.entries.first?.numberDay ?? "")
                                .adaptiveFont(.latoRegular, size: 10)
                                .foregroundColor(.adaptiveGray)
                                .frame(width: 48, height: 48)
                                .modifier(StyleModifier(style: viewStore.style))
                            
                            Text(viewStore.entries.first?.stringDay ?? "")
                                .adaptiveFont(.latoRegular, size: 10)
                                .foregroundColor(.adaptiveGray)
                                .frame(width: 48, height: 48)
                                .modifier(StyleModifier(style: viewStore.style))
                            
                            if viewStore.showLongDate {
                                Text(viewStore.entries.first?.stringMonth ?? "")
                                    .adaptiveFont(.latoRegular, size: 10)
                                    .foregroundColor(.adaptiveGray)
                                    .minimumScaleFactor(0.01)
                                    .frame(width: 48, height: 48)
                                    .modifier(StyleModifier(style: viewStore.style))
                                
                                Text(viewStore.entries.first?.stringYear ?? "")
                                    .adaptiveFont(.latoRegular, size: 10)
                                    .foregroundColor(.adaptiveGray)
                                    .minimumScaleFactor(0.01)
                                    .frame(width: 48, height: 48)
                                    .modifier(StyleModifier(style: viewStore.style))
                            }
                            NavigationLink(destination: EmptyView()) {
                                EmptyView()
                            }
                        }
                    }
                    .onTapGesture {
                        viewStore.send(.toggleLongDate, animation: .default)
                    }
                    
                    VStack(spacing: 4) {
                        ForEach(viewStore.entries) { entry in
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
                                        Image(systemName: "photo")
                                            .resizable()
                                            .foregroundColor(.adaptiveGray)
                                            .frame(width: 10, height: 10)
                                    }
                                    HStack(spacing: 4) {
                                        Text("\(entry.videos.count)")
                                            .adaptiveFont(.latoRegular, size: 6)
                                            .foregroundColor(.adaptiveGray)
                                        Image(systemName: "video")
                                            .resizable()
                                            .foregroundColor(.adaptiveGray)
                                            .frame(width: 14, height: 10)
                                    }
                                    HStack(spacing: 4) {
                                        Text("\(entry.audios.count)")
                                            .adaptiveFont(.latoRegular, size: 6)
                                            .foregroundColor(.adaptiveGray)
                                        Image(systemName: "waveform")
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
                            .modifier(StyleModifier(style: viewStore.style))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewStore.send(.navigateDetail(entry))
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
                    .offset(x: 0, y: -4)
            } else {
                HStack(alignment: .top, spacing: spacing, content: content)
                    .offset(x: -4, y: 0)
            }
        }
    }
}

fileprivate extension StringProtocol {
    var lines: [SubSequence] { split(whereSeparator: \.isNewline) }
    var removingAllExtraNewLines: String { lines.joined(separator: "\n") }
}
