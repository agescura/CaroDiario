import Models
import SwiftUI

struct DayEntrySectionView: View {
  let day: Date
  @Environment(\.dayEntrySectionStyle) var styleType
  @Environment(\.dayEntrySectionIsExpanded) var isExpanded: Bool
  
  var body: some View {
    Text(day.numberDay)
      .adaptiveFont(.latoRegular, size: 10)
      .foregroundColor(.adaptiveGray)
      .frame(width: 48, height: 48)
      .modifier(StyleModifier(style: styleType))
    
    Text(day.stringDay)
      .adaptiveFont(.latoRegular, size: 10)
      .foregroundColor(.adaptiveGray)
      .frame(width: 48, height: 48)
      .modifier(StyleModifier(style: styleType))
    
    if isExpanded {
      Text(day.stringMonth)
        .adaptiveFont(.latoRegular, size: 10)
        .foregroundColor(.adaptiveGray)
        .minimumScaleFactor(0.01)
        .frame(width: 48, height: 48)
        .modifier(StyleModifier(style: styleType))
      
      Text(day.stringYear)
        .adaptiveFont(.latoRegular, size: 10)
        .foregroundColor(.adaptiveGray)
        .minimumScaleFactor(0.01)
        .frame(width: 48, height: 48)
        .modifier(StyleModifier(style: styleType))
    }
  }
}
