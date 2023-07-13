import Foundation

public struct Entry: Identifiable {
    public var id: UUID
    public var date: Date
    public var startDay: Date
    public var text: EntryText
    public var attachments: [EntryAttachment]
    
    public init(
        id: UUID,
        date: Date,
        startDay: Date,
        text: EntryText,
        attachments: [EntryAttachment] = []
    ) {
        self.id = id
        self.date = date
        self.startDay = startDay
        self.text = text
        self.attachments = attachments
    }
}

extension Entry: Equatable {
    public static func == (lhs: Entry, rhs: Entry) -> Bool {
        lhs.id == rhs.id
    }
}

extension Entry: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Entry {
    public var numberDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    public var stringDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    public var stringMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
    
    public var stringYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
    
    public var stringHour: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    public var stringLongDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy HH:mm"
        return formatter.string(from: date)
    }
}

extension Entry {
    public var images: [EntryImage] {
        attachments.filter { $0 is EntryImage }.compactMap { $0 as? EntryImage }
    }
    
    public var videos: [EntryVideo] {
        attachments.filter { $0 is EntryVideo }.compactMap { $0 as? EntryVideo }
    }
    
    public var audios: [EntryAudio] {
        attachments.filter { $0 is EntryAudio }.compactMap { $0 as? EntryAudio }
    }
}

extension Entry {
	public static var mock: Self {
		Entry(
			id: UUID(),
			date: Date(),
			startDay: Date(),
			text: EntryText(
				id: UUID(),
				message: "Message",
				lastUpdated: .init()
			)
		)
	}
}

extension Entry {
	public static var add: Self {
		Entry(
			id: UUID(),
			date: Date(),
			startDay: Date(),
			text: EntryText(
				id: UUID(),
				message: "",
				lastUpdated: Date()
			)
		)
	}
}
