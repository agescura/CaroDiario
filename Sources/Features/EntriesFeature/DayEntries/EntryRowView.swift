import DesignSystem
import Models
import SwiftUI

struct EntryRowView: View {
  let entry: EntryModel
  @Environment(\.entryRowStyle) var styleType
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(entry.updatedAt.stringHour)
        .adaptiveFont(.latoRegular, size: 6)
      Text(entry.message.removingAllExtraNewLines)
        .adaptiveFont(.latoRegular, size: 10)
        .lineLimit(3)
      HStack(spacing: 8) {
        HStack(spacing: 4) {
          //                  Text("\(entry.images.count)")
          //                    .adaptiveFont(.latoRegular, size: 6)
          Image(systemName: .photo)
            .resizable()
            .frame(width: 10, height: 10)
        }
        HStack(spacing: 4) {
          //                  Text("\(entry.videos.count)")
          //                    .adaptiveFont(.latoRegular, size: 6)
          Image(systemName: .video)
            .resizable()
            .frame(width: 14, height: 10)
        }
        HStack(spacing: 4) {
          //                  Text("\(entry.audios.count)")
          //                    .adaptiveFont(.latoRegular, size: 6)
          Image(systemName: .waveform)
            .resizable()
            .frame(width: 14, height: 10)
        }
        Spacer()
        Text("Entries.ReadMore".localized)
          .adaptiveFont(.latoRegular, size: 6)
      }
      .foregroundColor(.adaptiveGray)
    }
    .frame(maxWidth: .infinity)
    .padding(8)
    .foregroundColor(.chambray)
    .padding(styleType.padding)
    .border(styleType.boderColor)
    .background(styleType.backgroundColor)
    .cornerRadius(styleType.cornerRadius)
  }
}

fileprivate extension StringProtocol {
  var lines: [SubSequence] { split(whereSeparator: \.isNewline) }
  var removingAllExtraNewLines: String { lines.joined(separator: "\n") }
}
