import ComposableArchitecture
import Models
import SwiftUI

public struct DayEntriesView: View {
  let dayEntriesRows: [GroupedEntries]
  let layoutType: LayoutType
  let styleType: StyleType
  let contentAction: (EntryModel) -> Void
  let labelAction: (GroupedEntries) -> Void
  
  public init(
    dayEntriesRows: [GroupedEntries],
    layoutType: LayoutType,
    styleType: StyleType,
    contentAction: @escaping (EntryModel) -> Void = { _ in },
    labelAction: @escaping (GroupedEntries) -> Void = { _ in }
  ) {
    self.dayEntriesRows = dayEntriesRows
    self.layoutType = layoutType
    self.styleType = styleType
    self.contentAction = contentAction
    self.labelAction = labelAction
  }
  
  public var body: some View {
    LazyVStack(alignment: .leading, spacing: 8) {
      ForEach(dayEntriesRows, id: \.self) { dayEntries in
        // MARK: - Contextual member reference to static method  requires 'Self' constraint in the protocol
        if layoutType == .horizontal {
          LabeledContent {
            LazyVStack(spacing: 8) {
              ForEach(dayEntries.entries) { entry in
                EntryRowView(entry: entry)
                  .entryRow(styleType: styleType)
                  .contentShape(Rectangle())
                  .onTapGesture {
                    contentAction(entry)
                  }
              }
            }
          } label: {
            DayEntrySectionView(day: dayEntries.date)
              .dayEntrySection(styleType: styleType)
              .dayEntrySection(isExpanded: dayEntries.isExpanded)
              .contentShape(Rectangle())
              .onTapGesture {
                labelAction(dayEntries)
              }
          }
          .labeledContentStyle(.horizontal)
          .padding(.horizontal)
        } else {
          LabeledContent {
            LazyVStack(spacing: 8) {
              ForEach(dayEntries.entries) { entry in
                EntryRowView(entry: entry)
                  .entryRow(styleType: styleType)
                  .onTapGesture {
                    contentAction(entry)
                  }
              }
            }
          } label: {
            DayEntrySectionView(day: dayEntries.date)
              .dayEntrySection(styleType: styleType)
              .dayEntrySection(isExpanded: dayEntries.isExpanded)
              .onTapGesture {
                labelAction(dayEntries)
              }
          }
          .labeledContentStyle(.vertical)
          .padding(.horizontal)
        }
      }
    }
  }
}
