import Foundation

public struct EntryText: Equatable, Identifiable, Hashable {
	public var id: UUID
	public var message: String
	public var lastUpdated: Date
	
	public init(
		id: UUID,
		message: String,
		lastUpdated: Date
	) {
		self.id = id
		self.message = message
		self.lastUpdated = lastUpdated
	}
}
